require 'bunny'

class MessageMaker
  def self.make_message(queue_name, routing_key, message)
    amqp_client = Bunny.new(Settings['amqp.url'], :logging => false)

    amqp_client.start

    exchange = amqp_client.exchange(queue_name, :type => :topic)

    queue = amqp_client.queue(queue_name, :durable => true)

    queue.bind(exchange, :key => '*')

    message = message.as_json.to_json unless message.is_a? String

    exchange.publish(message, :key => routing_key, :persistent => true)

    amqp_client.stop
  end
end
