require 'json'
module Hbx
  module Services

    class TransformService

      class ResponseInformation
        def initialize(properties)
          @reply_to = properties.reply_to
          @reply_to_exchange = properties.headers["reply_to_exchange"]
          @reply_exchange_type = parse_exchange_type(@reply_to_exchange)
          @correlation_id = properties.correlation_id
        end

        def parse_exchange_type(ex_name)
          if ex_name.nil?
            return :default
          end
          ex_name.split(".")[3].to_sym
        end

        def get_reply_exchange(chan)
          if @reply_exchange_type == :default
            return chan.default_exchange
          end
          chan.send(@reply_exchange_type, @reply_to_exchange, {:durable => true})
        end

        def response_properties(result_code)
          resp_props = {
            :routing_key => @reply_to,
            :persistent => true,
            :headers => {
              :result_code => result_code
            }
          }
          if @correlation_id
            resp_props[:correlation_id] = @correlation_id
          end
          resp_props
        end

      end

      def register(chan)
        chan.prefetch(1)
        ex = chan.direct(exchange_name)
        q = chan.queue(queue_name, :persistent => true)
        q.bind(ex, :routing_key => binding_key)
        q.subscribe(:block => true, :ack => true) do |di, prop, pay|
          begin
            message(chan, di, prop, pay)
          rescue => e
            $stderr.puts e.message
            $stderr.puts e.inspect
            $stderr.puts e.backtrace.join("\n")
            throw :terminate, e
          end
        end
      end

      def queue_name
        Hbx::Rabbit.exchange_name + "." + Hbx::Rabbit.environment + ".q.direct.xml.transform"
      end

      def binding_key
        "xml.transform"
      end

      def exchange_name
        Hbx::Rabbit.exchange_name + "." + Hbx::Rabbit.environment + ".e.direct.xml"
      end

      def message(chan, delivery_info, properties, payload)
        response_info = extract_response_information(properties)
        transformer = nil
        reply_exchange = response_info.get_reply_exchange(chan)
        begin
          transformer = Hbx::Transformer.transformer_for(properties.headers["transformer"])
        rescue Hbx::Errors::NoSuchTransformError => e
          reply_exchange.publish(e.message, response_info.response_properties("NO_SUCH_TRANSFORM"))
          chan.ack(delivery_info.delivery_tag)
          return
        end
        new_payload = transformer.transform(payload)
        validator = nil
        begin
          validator = Hbx::Validator.validator_for_document(new_payload)
        rescue Hbx::Errors::NoSuchSchemaError => e
          reply_exchange.publish(e.message, response_info.response_properties("NO_SUCH_SCHEMA"))
          chan.ack(delivery_info.delivery_tag)
          return
        end
        begin
          validator.validate(new_payload)
          reply_exchange.publish(
            new_payload,
            response_info.response_properties("OK")
          )
        rescue Hbx::Errors::ValidationFailedError => e
          reply_exchange.publish(
            JSON.dump({
              :document => new_payload,
              :errors => e.message
            }),
            response_info.response_properties("VALIDATION_FAILED")
          )
        end
        chan.ack(delivery_info.delivery_tag)
      end

      def extract_response_information(properties)
        ResponseInformation.new(properties)
      end

    end
  end
end
