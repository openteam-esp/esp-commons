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

  s.add_dependency 'active_attr'
  s.add_dependency 'amqp', '~> 0.9.8'
  s.add_dependency 'bunny', '~> 0.8.0'
  s.add_dependency 'daemons', '~> 1.1.9'
  s.add_dependency 'openteam-commons'
  s.add_dependency 'rails'
  s.add_dependency 'rest-client'

  s.add_development_dependency 'sqlite3'
end
