require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "hbx"))

session = Hbx::Rabbit.session
channel = session.create_channel
service = Hbx::Services::TransformService.new
service.register(channel)
