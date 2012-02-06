require 'configliere'
require 'airbrake'
require 'russian'

module EspCommons
  class Engine < ::Rails::Engine
    isolate_namespace EspCommons

    config.after_initialize do
      Rails.application.config.secret_token = Settings['app.secret']
      Rails.application.config.log_path = Settings['/var/log/esp/']
    end
  end
end
