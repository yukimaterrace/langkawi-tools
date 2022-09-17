require './lib/api'
require './lib/processor'

class RelationGenerator

  def initialize(account, counter_account)
    @processor = Processor.new
    @api = API.new
    
    @processor.state.update(email_password: extract_email_password(account))
    @processor.state.update(counter_email_password: extract_email_password(counter_account))
    @processor.state.update(user_id: extract_user_id(account))
    @processor.state.update(counter_user_id: extract_user_id(counter_account))
  end

  def build_for_pending
    @processor
      .proc { login(false) }
      .proc { create_relation }
  end

  def build_for_withdraw
    build_for_pending
      .proc { update_relation(:withdraw, false) }
  end

  def build_for_accepted
    build_for_pending
      .proc { login(true) }
      .proc { update_relation(:accepted, true) }
  end

  def build_for_declined
    build_for_pending
      .proc { login(true) }
      .proc { update_relation(:declined, true) }
  end

  def build_for_disconnected
    build_for_accepted
      .proc { login(false) }
      .proc { update_relation(:disconnected, false) }
  end

  def build_for_refused
    build_for_accepted
      .proc { update_relation(:refused, true) }
  end

  private

  def extract_email_password(account)
    { email: account['email'], password: account['password'] }
  end
  
  def extract_user_id(account)
    account['user']['id']
  end

  def login(by_counter)
    key = by_counter ? :counter_email_password : :email_password
    resp = @api.login(@processor.state[key])
    @api.token = resp['token']
  end

  def create_relation
    @api.create_relation({ user_id: @processor.state[:counter_user_id] })
  end

  def update_relation(status, by_counter)
    id_key = by_counter ? :user_id : :counter_user_id
    @api.update_relation(@processor.state[id_key], { status: status })
  end
end
