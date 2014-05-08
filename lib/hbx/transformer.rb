require 'singleton'
require 'nokogiri'

module Hbx
  class TransformRegistry
    include Singleton

    # Load the registered transformations from the configuration
    def initialize
    end

    def transform_for(uri)
    end

    def self.transform_for(uri)
      self.instance.transform_for(uri)
    end
  end

  class Transformer
  end
end
