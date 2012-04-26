module EspCommons
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def create_scripts
        copy_file 'script/subscriber'
        chmod 'script/subscriber', 0755
      end
    end
  end
end

