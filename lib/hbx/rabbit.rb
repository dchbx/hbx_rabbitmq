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

      def self.connection
        self.instance.connection
      end
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
