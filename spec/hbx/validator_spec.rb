require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Hbx::SchemaRegistry do

  describe "with a schema for http://dchealthlink.com/vocabularies/2.0/policy" do
    it "should return the schema for the namespace" do
      expect(
        Hbx::SchemaRegistry.schema_location_for(
         "http://dchealthlink.com/vocabularies/2.0/policy"
        )
      ).to eq("cv/2.0/policy.xsd")
    end
  end
end

describe Hbx::Validator, "
given:
- a namespace of http://dchealthlink.com/vocabularies/2.0/policy
- an invalid policy xml
" do
  let(:document) { Nokogiri::XML::Document.new("") }
  subject { Hbx::Validator.validator_for("http://dchealthlink.com/vocabularies/2.0/policy") }

  it "should mark invalid a valid policy document" do
    expect(subject.valid?(document)).to be_false
  end
end
