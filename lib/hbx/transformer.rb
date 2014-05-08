require 'singleton'
require 'nokogiri'

module Hbx
  class TransformRegistry
    include Singleton

    # Load the registered transformations from the configuration
    def initialize
        config_file_location = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "transforms.yml"))
        @transform_map = YAML.load(File.read(config_file_location))
    end

    def transform_location_for(uri)
      @transform_map.fetch(uri) { |k| raise Hbx::Errors::NoSuchTransformError, k }
    end

    def self.transform_location_for(uri)
      self.instance.transform_location_for(uri)
    end
  end

  class Transformer
    def initialize(transform_location)
      transform_directory = File.join(File.dirname(__FILE__), "..", "..", "transforms")
      raw_transform = File.open(File.join(transform_directory, transform_location))
      @transform = Nokogiri::XSLT(raw_transform)
    end

    def transform(doc_string, params = [])
      doc = Nokogiri::XML(doc_string)
      safe_params = Nokogiri::XSLT.quote_params(params)
      @transform.transform(doc, safe_params).to_xml(:indent => 2)
    end

    def self.transformer_for(namespace)
      self.new(TransformRegistry.transform_location_for(namespace))
    end
  end
end
