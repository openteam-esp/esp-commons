module EspCommons
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('..', __FILE__)

      def create_binaries
        template 'bin/start_site'
      end

      def create_configs
        template 'config/unicorn.rb'
      end
    end
  end
end

