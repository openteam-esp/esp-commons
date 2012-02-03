Settings.read(Rails.root.join('config', 'settings.yml')) if Rails.root.join('config', 'settings.yml').exist?

Settings.defaults Settings.extract!(Rails.env)[Rails.env] || {}
Settings.extract!(:test, :development, :production)

Settings.define 'app.secret',       :env_var => 'APP_SECRET',     :required => true

Settings.define 'errors.key',       :env_var => 'ERRORS_KEY',     :required => Rails.env.production?
Settings.define 'errors.url',       :env_var => 'ERRORS_URL',     :required => Rails.env.production?

Settings.define 'solr.url',         :env_var => 'SOLR_URL'

Settings.define 'sso.url',          :env_var => 'SSO_URL'
Settings.define 'sso_key',          :env_var => 'SSO_KEY'
Settings.define 'sso_secret',       :env_var => 'SSO_SECRET'
Settings.define 'cms.url',          :env_var => 'CMS_URL'
Settings.define 'blue-pages.url',   :env_var => 'BLUE_PAGES_URL'
Settings.define 'news.url',         :env_var => 'NEWS_URL'
Settings.define 'vfs.url',          :env_var => 'VFS_URL'
Settings.define 'appeals.url',      :env_var => 'APPEALS_URL'

Settings.resolve!
