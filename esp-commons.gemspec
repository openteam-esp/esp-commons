$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'esp-commons/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'esp-commons'
  s.version     = EspCommons::VERSION
  s.authors     = ['OpenTeam']
  s.email       = ['mail@openteam.ru']
  s.homepage    = 'http://github.com/openteam-esp/esp-commons'
  s.summary     = 'Summary of EspCommons.'
  s.description = 'Description of EspCommons.'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'airbrake'
  s.add_dependency 'ancestry'
  s.add_dependency 'annotate',            '>= 2.4.1.beta1'
  s.add_dependency 'configliere'
  s.add_dependency 'default_value_for'
  s.add_dependency 'formtastic',          '>= 2.1.0.beta1'
  s.add_dependency 'has_enum'
  s.add_dependency 'has_searcher'
  s.add_dependency 'inherited_resources'
  s.add_dependency 'kaminari'
  s.add_dependency 'rails'
  s.add_dependency 'russian'
  s.add_dependency 'sunspot_rails'
  s.add_dependency 'unicorn'
  s.add_dependency 'pg'
  s.add_dependency 'compass-rails',       '>= 1.0.0.rc2'

  s.add_development_dependency 'sqlite3'
end
