require 'bunny'

class MessageMaker
  def self.make_message(queue_name, routing_key, *message)
    if Settings['amqp.url']
      amqp_client = Bunny.new(Settings['amqp.url'], :logging => false)
      amqp_client.start

      exchange = amqp_client.exchange(queue_name, :type => :topic)

      queue = amqp_client.queue(queue_name, :durable => true)
      queue.bind(exchange, :key => '*')

      exchange.publish(message.as_json.to_json, :key => routing_key, :persistent => true)

      amqp_client.stop
    else
      if Rails.env.production?
        raise 'Define amqp.url in config/settings.yml'
      else
        ActiveSupport::Deprecation.warn 'Define amqp.url in config/settings.yml'
      end
    end
  end
end
