# @a:id "app/channels/application_cable/channel.rb#ApplicationCable::Channel"
# @a:summary "Base ActionCable channel for real-time features"
# @a:intent "Provide namespace and inheritance point for future channels"
# @a:contract {"requires":["inherit from ActionCable::Channel::Base"],"ensures":["shared behaviour configured centrally"]}
# @a:io {"input":{"subscription":"ActionCable connection"},"output":{"stream":"ActionCable"}}
# @a:errors []
# @a:sideEffects "none"
# @a:security "Authentication enforced in concrete channel subclasses"
# @a:perf "No overhead beyond ActionCable base"
# @a:dependencies ["ActionCable::Channel::Base"]
# @a:example {"ok":"class ChatChannel < ApplicationCable::Channel; end","ng":"ApplicationCable::Channel.new # raises TypeError"}
# @a:cases []
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
