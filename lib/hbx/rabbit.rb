require 'yaml'
require 'singleton'

module Hbx
  class Rabbit
    class Configuration
      include Singleton

      def initialize
        rabbit_config_location = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "rabbit.yml"))
        @rabbit_configuration = YAML.load(File.read(rabbit_config_location))
      end

      def connection
        @rabbit_configuration['connection']
      end

      def exchange_name
        @rabbit_configuration['exchange_name']
      end

      def environment
        @rabbit_configuration['environment'] || "dev"
      end

      def self.connection
        self.instance.connection
      end

      def self.exchange_name
        self.instance.exchange_name
      end

      def self.environment
        self.instance.environment
      end
    end

    def self.environment
      Configuration.environment
    end

    def self.exchange_name
      Configuration.exchange_name
    end

    def self.connection_settings
      Configuration.connection
    end

    # Return a new session.
    def self.session
      bun = Bunny.new(connection_settings)
      bun.start
      bun
    end
  end
end
