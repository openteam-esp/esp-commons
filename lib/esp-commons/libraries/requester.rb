require 'curb'

class RequesterException < Exception
end

class Requester
  def initialize(url, headers_accept = nil)
    @response ||= RestClient::Request.execute(
      :method => :get,
      :url => url,
      :timeout => nil,
      :headers => {
        :Accept => headers_accept
      }
    ) do |response, request, result, &block|
      response
    end
  end

  def response
    @response
  end

  def stringify_headers(headers)
    headers.map do |k, v|
      {
        k.to_s.split('_').map do |s|
          s.capitalize.gsub('Etag', 'ETag').gsub('Ua', 'UA')
        end.join('-') => v
      }
    end.reduce Hash.new, :merge
  end

  def response_headers
    @response_headers ||= stringify_headers response.headers
  end

  def response_status
    @response_status ||= response.code
  end

  def response_body
    @response_body ||= response.body.force_encoding('UTF-8')
  end

  def response_hash
    @response_hash ||= ActiveSupport::JSON.decode(response_body) rescue {}
  end
end
