require 'faker'
require 'faraday'
require './lib/processor'
require './lib/api'

class AccountGenerator

  def initialize(password, avators)
    @processor = Processor.new
    @api = API.new
    @password = password
    @avators = avators
  end

  def build
    @processor
      .proc { create_account }
      .proc { do_login }
      .proc { register_name_gender_age }
      .proc { create_user_detail }
      .proc { register_picture_a }
    self
  end

  def generate
    @processor
      .execute
      .reset
  end

  private

  def create_account
    email = Faker::Internet::email
    password = @password
    email_password = {email: email, password: password}
    @processor.state.update(email_password)

    resp = @api.create_account(email_password.merge(:account_type => :owned))
    @processor.state.update(:user_id => resp['user']['id'])
  end

  def do_login
    params = @processor.state.slice(:email, :password)
    @api.token = @api.login(params)['token']
  end

  def register_name_gender_age
    gender = Faker::Gender.binary_type == '男性' ? :male : :female
    first_name = gender == :male ? Faker::Name.male_first_name : Faker::Name.female_first_name
    last_name = Faker::Name.last_name
    age = Faker::Number.within(range: 20..50)

    params = {first_name: first_name, last_name: last_name, gender: gender, age: age}
    @api.update_user(@processor.state[:user_id], params)

    @processor.state.update(:gender => gender)
  end

  def create_user_detail
    user_id = @processor.state[:user_id]
    description = Faker::Lorem.paragraph(sentence_count: 4, supplemental: true, random_sentences_to_add: 4)
    params = {user_id: user_id, description_a: description}

    resp = @api.create_user_detail(params)
    @processor.state.update(:user_detail_id => resp['id'])
  end

  def register_picture_a
    id = @processor.state[:user_detail_id]
    filename = resolve_avator(@processor.state[:gender])

    params = {picture_a: Faraday::UploadIO.new(filename, 'image/png')}
    @api.upload_picture_a(id, params)
  end

  def resolve_avator(gender)
    avators = @avators[gender.to_s]
    avator = avators[rand(0...avators.count)]
    "#{@avators['root_dir']}/#{avator}"
  end
end
