require 'amqp'

class Subscriber
  def start
    subscribers.each do |subscriber|
      AMQP.start(Settings['amqp.url']) do |connection|
        channel = AMQP::Channel.new(connection)
        channel.prefetch(1)

        exchange = channel.topic('esp')
        queue = channel.queue(queue_name(subscriber), :durable => true)

        queue.bind(exchange, :routing_key => '*')

        Signal.trap("TERM") do
          connection.close do
            logger.info "#{subscriber.class} stopped"
            EM.stop { exit }
          end
        end

        queue.subscribe(:ack => true) do |header, message|
          method = header.routing_key
          if subscriber.respond_to?(method)
            logger.debug("#{subscriber.class} receive #{method}: #{message}")
            subscriber.send(method, message)
            header.ack
          else
            logger.warn "#{subscriber.class} not respond to #{method}"
          end
        end

        logger.info "#{subscriber.class} started"
      end
    end
  end

  def subscribers
    Dir.glob("#{Rails.root}/lib/subscribers/*").map do |subscriber_path|
      require subscriber_path
      File.basename(subscriber_path, '.rb').classify.constantize.new
    end
  end

  def logger
    @@logger ||= ActiveSupport::BufferedLogger.new("#{Rails.root}/log/subscriber.log")
  end

  private
    def queue_name(subscriber)
      from = subscriber.class.name.sub(/Subscriber$/, '').underscore
      to = Rails.application.class.name.sub('::Application', '').underscore

      "esp.#{from}.#{to}"
    end
end
