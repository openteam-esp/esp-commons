require 'openteam-commons'

module EspCommons
  class Engine < ::Rails::Engine
    isolate_namespace EspCommons

    config.before_configuration do
      Settings.define 'appeals.url',      :env_var => 'APPEALS_URL'
      Settings.define 'blue-pages.url',   :env_var => 'BLUE_PAGES_URL'
      Settings.define 'cms.url',          :env_var => 'CMS_URL'
      Settings.define 'news.url',         :env_var => 'NEWS_URL'
    end

    config.to_prepare do
      ActionController::Base.class_eval do
        helper_method :image_tag_for, :thumbnail_tag

        protected
          def image_tag_for(image)
            view_context.image_tag(image.url, :width => image.width, :height => image.height, :alt => image.description) if image
          end

          def thumbnail_tag(url, options={})
            if url.is_a?(String) && image = EspCommons::Image.new(:url => url).parse_url
              image_tag_for image.create_thumbnail(options)
            end
          end
      end
    end
  end
end
