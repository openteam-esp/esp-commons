require 'active_attr'

class EspCommons::Image
  include ActiveAttr::Attributes
  include ActiveAttr::MassAssignment
  include ActiveAttr::QueryAttributes
  include ActiveAttr::TypecastedAttributes

  attribute :url
  attribute :description
  attribute :thumbnail

  attribute :vfs_url
  attribute :id,          :type => Integer
  attribute :width,       :type => Integer
  attribute :height,      :type => Integer
  attribute :crop,        :type => Boolean
  attribute :filename


  attr_writer :aspect_ratio

  def parse_url
    self.tap do | image |
      image.vfs_url, image.id, image.width, image.height, image.crop, image.filename =
        url.match(%r{(.*)/files/(\d+)/(?:(\d+)-(\d+)(\!)?/)?(.*)})[1..-1]
    end
  end

  def build_url
    self.tap do | image |
      if image?
        image.url = "#{vfs_url}/files/#{image.id}/#{image.width}-#{image.height}#{image.crop ? '!' : ''}/#{image.filename}"
      else
        image.url = "#{vfs_url}/files/#{image.id}/#{image.filename}"
      end
    end
  end

  def image?
    width? && height?
  end

  def aspect_ratio
    @aspect_ratio ||= width.to_f / height
  end

  def resize(aspect_ratio)
    self.aspect_ratio = aspect_ratio
    if width? && !height?
      self.height = new_height
    elsif !width? && height?
      self.width = new_width
    else
      self.width = self.height = 100 if !width? && !height?
      unless crop
        if height >= new_height
          self.height = new_height
        else
          self.width = new_width
        end
      end
    end
    self
  end

  def new_height
    @new_height ||= width / aspect_ratio
  end

  def new_width
    @new_width ||= height * aspect_ratio
  end

  def create_thumbnail(options)
    return unless image?
    self.thumbnail = EspCommons::Image.new(options.reverse_merge(:vfs_url => vfs_url,  :id => id, :filename => filename, :description => description))
                                      .resize(aspect_ratio)
                                      .build_url
  end

  def as_json(options={})
    super(options.merge(:only => %w[url width height description]))
  end
end
