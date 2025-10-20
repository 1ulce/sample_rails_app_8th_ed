# @a:id "app/channels/application_cable/connection.rb#ApplicationCable::Connection"
# @a:summary "Base ActionCable connection class"
# @a:intent "Serve as hook to identify and authorize websocket connections"
# @a:contract {"requires":["inherit from ActionCable::Connection::Base"],"ensures":["future identification hooks run"]}
# @a:io {"input":{"websocket":"ActionCable::Server::Base"},"output":{"connection":"ActionCable::Connection"}}
# @a:errors []
# @a:sideEffects "none"
# @a:security "Authentication logic to be added by project as needed"
# @a:perf "No overhead"
# @a:dependencies ["ActionCable::Connection::Base"]
# @a:example {"ok":"identified_by :current_user inside subclass","ng":"ApplicationCable::Connection.new(nil, nil) # raises ArgumentError"}
# @a:cases []
module ApplicationCable
  class Connection < ActionCable::Connection::Base
  end
end
