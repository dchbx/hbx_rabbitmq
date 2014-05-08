require 'singleton'
require 'nokogiri'

module Hbx
  class SchemaRegistry 
    include Singleton

    # Load the registered schemas from the configuration
    def initialize
    end

    def schema_for(namespace)
    end

    def self.schema_for(namespace)
      self.instance.schema_for(namespace)
    end
  end

  class Validator
  end
end
