require 'faraday'
require 'faraday/multipart'

class APIError < StandardError
  def initialize(status, exception)
    @message = "#{status} #{exception}"
  end

  def message
    @message
  end
end

class API
  attr_accessor :token

  def initialize
    @base_url = 'http://localhost:3000'
    
    @conn = conn do |f|
      f.request :json
    end

    @multipart_conn = conn do |f|
      f.request :multipart
    end
  end
  
  def create_account(params)
    request do
      @conn.post('api/accounts') do |r|
        r.body = params
      end
    end
  end

  def list_account(params)
    request do
      @conn.get('api/accounts') do |r|
        r.params = params
      end
    end
  end

  def login(params)
    request do
      @conn.post('api/login') do |r|
        r.body = params
      end
    end
  end

  def update_user(id, params)
    request do 
      @conn.put("api/users/#{id}") do |r|
        r.body = params
      end
    end
  end

  def create_user_detail(params)
    request do
      @conn.post('api/user_details') do |r|
        r.body = params
      end
    end
  end

  def upload_picture_a(id, params)
    request do
      @multipart_conn.post("api/user_details/#{id}/picture_a") do |r|
        r.body = params
      end
    end
  end

  def index_relation(params)
    request do
      @conn.get('api/relations') do |r|
        r.params = params
      end
    end
  end

  def create_relation(params)
    request do
      @conn.post('api/relations') do |r|
        r.body = params
      end
    end
  end

  def update_relation(id, params)
    request do
      @conn.put("api/relations/#{id}") do |r|
        r.body = params
      end
    end
  end

  def create_talk(params)
    request do
      @conn.post('api/talks') do |r|
        r.body = params
      end
    end
  end
  
  private 
  
  def conn(&config)
    Faraday.new(@base_url) do |f|
      f.request :authorization, 'Bearer', -> { @token }
      f.response :json
      config&.call(f)
    end
  end

  def request(&block)
    resp = block.call
    unless resp.status == 200
      raise APIError.new(resp.status, resp.body['exception'])
    end
    resp.body
  end
end
