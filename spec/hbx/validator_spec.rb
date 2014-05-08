require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Hbx::SchemaRegistry do
  describe "given a bogus namespace" do
    it "should raise an error describing the missing schema" do
      expect { Hbx::SchemaRegistry.schema_location_for("abacde") }.to raise_error(Hbx::Errors::NoSuchSchemaError, "abacde")
    end
  end

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

  it "should raise a validation failed error on validation" do
    expect { subject.validate(document) }.to raise_error(Hbx::Errors::ValidationFailedError.new(["The document has no document element."]))
  end
end

describe Hbx::Validator do
  let(:document_prefixed) { 
<<XMLDOC
<?xml version="1.0"?>
     <pol:policy xmlns:pol="http://dchealthlink.com/vocabularies/2.0/policy"></pol:policy>
XMLDOC
 }
  let(:document_no_prefix) { 
<<XMLDOC
     <policy xmlns="http://dchealthlink.com/vocabularies/2.0/policy"></policy>
XMLDOC
 }

  subject { Hbx::Validator }

  it "should find the proper schema for a ns-prefixed document" do
    expect(subject.validator_for_document(document_prefixed)).not_to be_nil
  end
  it "should find the proper schema for a ns-unprefixed document" do
    expect(subject.validator_for_document(document_no_prefix)).not_to be_nil
  end
end
