require 'singleton'
require 'nokogiri'

module Hbx
  class SchemaRegistry 
    include Singleton

    # Load the registered schemas from the configuration
    def initialize
        config_file_location = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "schemas.yml"))
        @schema_map = YAML.load(File.read(config_file_location))
    end

    def schema_location_for(namespace)
      @schema_map.fetch(namespace) { |k| raise Hbx::Errors::NoSuchSchemaError, k }
    end

    def self.schema_location_for(namespace)
      self.instance.schema_location_for(namespace)
    end
  end

  class Validator

    def initialize(schema_location)
      schema_directory = File.join(File.dirname(__FILE__), "..", "..", "schemas")
      raw_schema = File.open(File.join(schema_directory, schema_location))
      @schema = Nokogiri::XML::Schema.new(raw_schema)
    end

    def validate(thing)
      errors = @schema.validate(thing)
      if errors.any?
        raise Hbx::Errors::ValidationFailedError.new(errors.map(&:message))
      end
    end

    def self.validator_for(namespace)
      self.new(SchemaRegistry.schema_location_for(namespace))
    end
  end
end
