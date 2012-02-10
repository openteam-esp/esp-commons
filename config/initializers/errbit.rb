if Settings['errors.key'].present?
  require 'airbrake'
  Airbrake.configure do |config|
    config.api_key = Settings['errors.key']
    URI.parse(Settings['errors.url']).tap do | url |
      config.host = url.host
      config.port = url.port
      config.secure = url.scheme.inquiry.https?
    end
  end
end
