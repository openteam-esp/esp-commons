require 'amqp'

class Subscriber
  def start
    logger.debug "Subscribers runned in #{Rails.env} environment"
    AMQP.start(Settings['amqp.url']) do |connection|
      Signal.trap("TERM") do
        logger.info "All subscribers stopped"
        connection.close do
          EM.stop { exit }
        end
      end
      subscribers.each do |subscriber|
        channel = AMQP::Channel.new(connection)
        channel.prefetch(1)

        topic = routing_prefix(subscriber)

        exchange = channel.topic(topic)
        queue = channel.queue(topic, :durable => true)

        queue.bind(exchange, :routing_key => "*")

        queue.subscribe(:ack => true) do |header, message|
          method = header.routing_key
          logger.debug "#{subscriber.class} receive #{method}: #{message}"
          if subscriber.respond_to?(method)
            begin
              defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
              subscriber.send(method, message)
              logger.debug "#{subscriber.class} successfully executed #{method}"
            rescue => e
              logger.warn "#{subscriber.class} error while executing #{method} - #{e.message}"
            end
          else
            logger.warn "#{subscriber.class} cann't execute #{method} due #{subscriber.class} not respond to #{method}"
          end
          header.ack
        end

        logger.info "#{subscriber.class} listen #{queue.name}"
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
    @@logger ||= ActiveSupport::BufferedLogger.new("#{Rails.root}/log/subscriber.log")
  end

  private
    def routing_prefix(subscriber)
      from = subscriber.class.name.sub(/Subscriber$/, '').underscore
      to = Rails.application.class.name.sub('::Application', '').underscore

      "esp.#{from}.#{to}"
    end
end
