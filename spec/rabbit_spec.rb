require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "hbx", "rabbit"))


describe Hbx::Rabbit do

  subject { Hbx::Rabbit }

  its(:connection_settings) { should_not be_nil }
  its(:connection_settings) { should include("host") }

end
