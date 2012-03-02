class EspCommons::Image < APISmith::Smash
  property :url
  property :description
  property :thumbnail

  property :id,         :transformer => :to_i
  property :width,      :transformer => :to_i
  property :height,     :transformer => :to_i
  property :filename


  attr_writer :aspect_ratio

  def parse_url
    self.tap do | image |
      image.id, image.width, image.height, image.filename = url.match(%r{files/(\d+)/(\d+)-(\d+)/(.*)})[1..-1]
    end
  end

  def build_url
    self.tap do | image |
      image.url = "#{Settings['vfs.url']}/files/#{image.id}/#{image.width}-#{image.height}/#{image.filename}"
    end
  end

  def image?
    width && height
  end

  def width?
    width && width > 0
  end

  def height?
    height && height > 0
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
      if height >= new_height
        self.height = new_height
      else
        self.width = new_width
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
    self.thumbnail = EspCommons::Image.new(options.merge(:id => id, :filename => filename, :description => description))
                                      .resize(aspect_ratio)
                                      .build_url
  end

  def as_json(options={})
    super(options.merge(:only => %w[url width height description]))
  end
end
