require "net/https"
require "uri"

class WunderlistApi
  attr_accessor :user, :access_token
  def initialize(access_token)
    @user = Authorization.find_by_access_token(access_token).user
    @access_token = access_token
  end

  def self.get_access_token(code)

    sending_data = { client_id: ENV['WUNDERLIST_CLIENT_ID'],
                     client_secret: ENV['WUNDERLIST_CLIENT_SECRET'],
                     code: code }

    uri = URI.parse("https://www.wunderlist.com/oauth/access_token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' =>'application/json'})
    request.body = sending_data.to_json
    response = http.request(request)

    return JSON.parse(response.body)["access_token"]

  end


  def get(endpoint, request_data)
    if @access_token


      uri = URI.parse("https://a.wunderlist.com/api/v1/" + endpoint)
      uri.query = URI.encode_www_form( request_data ) if request_data

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)
      request['X-Access-Token'] = @access_token
      request['X-Client-ID'] = ENV['WUNDERLIST_CLIENT_ID']

      response = http.request(request)
      JSON.parse(response.body, {symbolize_names: true})
    else
      raise "Please initialize the class"
    end
  end

  def patch(endpoint, request_data)

    if @access_token

      uri = URI.parse("https://a.wunderlist.com/api/v1/" + endpoint)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Patch.new(uri.request_uri, {'Content-Type' =>'application/json'})
      request['X-Access-Token'] = @access_token
      request['X-Client-ID'] = ENV['WUNDERLIST_CLIENT_ID']
      request.body = request_data.to_json

      response = http.request(request)
      JSON.parse(response.body, {symbolize_names: true})
    else
      raise "Please initialize the class"
    end

  end

  def post(endpoint, request_data)

    if @access_token

      uri = URI.parse("https://a.wunderlist.com/api/v1/" + endpoint)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' =>'application/json'})
      request['X-Access-Token'] = @access_token
      request['X-Client-ID'] = ENV['WUNDERLIST_CLIENT_ID']
      request.body = request_data.to_json

      response = http.request(request)
      JSON.parse(response.body, {symbolize_names: true})
    else
      raise "Please initialize the class"
    end

  end
end

