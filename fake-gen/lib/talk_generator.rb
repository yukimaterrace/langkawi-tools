# frozen_string_literal: true

require 'faker'
require './lib/processor'
require './lib/api'

class TalkGenerator
  def initialize
    @api = API.new
  end

  def generate(admin, talk_count)
    accounts = list_account(admin)
    user_id_account_hash = create_user_id_account_hash(accounts)
    admin_account = accounts.find do |account|
      account.slice('email', 'password') == admin
    end

    create_talks(admin, admin_account, user_id_account_hash, talk_count)
  end

  private

  def create_user_id_account_hash(accounts)
    accounts.map { |account| [account['user']['id'], account] }.to_h
  end

  def list_account(admin)
    with_login(admin) do
      fetch_all do |page, page_size|
        @api.list_account({ page:, page_size: })
      end
    end
  end

  def create_talks(admin, admin_account, user_id_account_hash, talk_count)
    list_accepted_relation(admin).each_with_index do |relation, i|
      next unless i.even?

      talk_count.times do
        create_talk(relation, admin_account['user']['id'], user_id_account_hash)
      end
    end
  end

  def list_accepted_relation(account)
    with_login(account) do
      accepted_me_list = fetch_all do |page, page_size|
        index_relation(:accepted_me, page, page_size)
      end
      accepted_you_list = fetch_all do |page, page_size|
        index_relation(:accepted_you, page, page_size)
      end
      accepted_me_list + accepted_you_list
    end
  end

  def index_relation(position_status, page, page_size)
    @api.index_relation({
                          position_status:,
                          page:,
                          page_size:
                        })
  end

  def create_talk(relation, admin_user_id, user_id_account_hash)
    submitter_user_id = rand(0..1).zero? ? admin_user_id : relation['user']['id']
    submitter_account = user_id_account_hash[submitter_user_id]

    with_login(submitter_account) do
      message = Faker::Lorem.paragraph(
        sentence_count: 2, supplemental: true, random_sentences_to_add: 2
      )
      @api.create_talk({ relation_id: relation['id'], message: })
    end
  end

  def with_login(account, &block)
    resp = @api.login({ email: account['email'], password: account['password'] })
    @api.token = resp['token']
    block.call
  end

  def fetch_all(&requester)
    list = []
    page = 0
    page_size = 10
    loop do
      resp = requester.call(page, page_size)
      list.concat(resp['list'])
      break if (resp['count']).zero?

      page += 1
    end
    list
  end
end
