require 'amqp'

class Subscriber
  def start
    AMQP.start(Settings['amqp.url']) do |connection|
      logger.debug "Subscribers runned in #{Rails.env} environment"
      subscribers.each do |subscriber|
        channel = AMQP::Channel.new(connection)
        channel.prefetch(1)

        topic = routing_prefix(subscriber)

        exchange = channel.topic(topic)
        queue = channel.queue(topic, :durable => true)

        queue.bind(exchange, :routing_key => "*").subscribe(:ack => true) do |header, message|
          method = header.routing_key
          message = JSON.parse(message)
          logger.debug "DEBUG: #{Time.zone.now}: #{subscriber.class} receive #{method}: #{message}"
          if subscriber.respond_to?(method)
            begin
              subscriber.send(method, *message)
              logger.debug "DEBUG: #{Time.zone.now}: #{subscriber.class} successfully executed #{method}"
            rescue => e
              logger.warn "WARN: #{Time.zone.now}: #{subscriber.class} error while executing #{method} - #{e.message}"
            end
          else
            logger.warn "WARN: #{Time.zone.now}: #{subscriber.class} cann't execute #{method} due #{subscriber.class} not respond to #{method}"
          end
          header.ack
        end
        logger.info "INFO: #{Time.zone.now}: #{subscriber.class} listen #{queue.name}"
      end
    end
  end

  def subscribers
    Dir.glob("#{Rails.root}/lib/subscribers/*_subscriber.rb").map do |subscriber_path|
      require subscriber_path
      File.basename(subscriber_path, '.rb').classify.constantize.new.tap do |subscriber|
        subscriber.logger = logger if subscriber.respond_to? :logger=
      end
    end
  end

  def logger
    @logger ||= ActiveSupport::BufferedLogger.new("#{Rails.root}/log/subscriber.log")
  end

  private
    def routing_prefix(subscriber)
      from = subscriber.class.name.sub(/Subscriber$/, '').underscore
      to = Rails.application.class.name.sub('::Application', '').underscore

      "esp.#{from}.#{to}".gsub /_/, '-'
    end
end
