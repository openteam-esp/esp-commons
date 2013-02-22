require 'curb'

class RequesterException < Exception
end

class Requester
  def initialize(url, headers_accept = nil)
    @response = Curl::Easy.perform(url) do |curl|
      curl.on_success { curl.headers['Accept'] = headers_accept if headers_accept }
      curl.on_failure { raise RequesterException, "Unable to get data from #{url}" }
    end
  end

  def response
    @response
  end

  def response_headers
    @response_headers ||= Hash[response.header_str.split("\r\n").map { |s| s.split(': ').map(&:strip) }]
  end

  def response_status
    @response_status ||= response.response_code
  end

  def response_body
    @response_body ||= response.body_str.force_encoding 'UTF-8'
  end

  def response_hash
    @response_hash ||= ActiveSupport::JSON.decode(response_body)
  end
end
