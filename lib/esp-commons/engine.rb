module EspCommons
  class Engine < ::Rails::Engine
    isolate_namespace EspCommons

    config.before_configuration do
      require 'configliere'
      Settings.read(Rails.root.join('config', 'settings.yml')) if Rails.root.join('config', 'settings.yml').exist?
      Settings.defaults Settings.extract!(Rails.env)[Rails.env] || {}
      Settings.extract!(:test, :development, :production)
      Settings.define 'app.secret',       :env_var => 'APP_SECRET'
      Settings.define 'app.url',          :env_var => 'APP_URL'
      Settings.define 'appeals.url',      :env_var => 'APPEALS_URL'
      Settings.define 'blue-pages.url',   :env_var => 'BLUE_PAGES_URL'
      Settings.define 'cms.url',          :env_var => 'CMS_URL'
      Settings.define 'errors.key',       :env_var => 'ERRORS_KEY'
      Settings.define 'errors.url',       :env_var => 'ERRORS_URL'
      Settings.define 'news.url',         :env_var => 'NEWS_URL'
      Settings.define 'solr.url',         :env_var => 'SOLR_URL'
      Settings.define 'sso.key',          :env_var => 'SSO_KEY'
      Settings.define 'sso.secret',       :env_var => 'SSO_SECRET'
      Settings.define 'sso.url',          :env_var => 'SSO_URL'
      Settings.define 'storage.url',      :env_var => 'STORAGE_URL'
    end

    config.before_configuration do
      if ENV['UNICORN']
        log_path = Settings['unicorn.logs_dir'] || "/var/log/esp/#{Rails.root.basename}"
        Rails.application.config.logger = ActiveSupport::BufferedLogger.new("#{log_path}/application.log")
      end
    end

    config.before_initialize do
      require 'ancestry'
      require 'default_value_for'
      require 'formtastic'
      require 'has_enum'
      require 'has_scope'
      require 'has_searcher'
      require 'kaminari'
      require 'inherited_resources'
      require 'russian'
      require 'sunspot/rails'
    end

    config.after_initialize do
      Rails.logger.level = ActiveSupport::BufferedLogger::Severity::WARN if Rails.env.production?
    end

    config.after_initialize do
      Rails.application.config.secret_token = Settings['app.secret']
    end
  end
end
