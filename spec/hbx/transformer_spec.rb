require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Hbx::TransformRegistry do

  describe "given a bogus namespace" do
    it "should raise an error describing the missing transform" do
      expect { Hbx::TransformRegistry.transform_location_for("") }.to raise_error(Hbx::Errors::NoSuchTransformError)
    end
  end

  describe "with a transform for uri:gluedb:v0.1.0:person:update" do
    it "should return the schema for the namespace" do
      expect(
        Hbx::TransformRegistry.transform_location_for(
         "uri:gluedb:v0.1.0:person:update"
        )
      ).to eq("gluedb/individual_update.xsl")
    end
  end
end

describe Hbx::Transformer, "
given:
- a namespace of uri:gluedb:v0.1.0:person:update
- an initial xml string
" do
  let(:document) { "" }
  subject { Hbx::Transformer.transformer_for("uri:gluedb:v0.1.0:person:update") }

  it "should be able to transform the document" do
    expect(subject.transform(document)).not_to be_nil
  end
end
