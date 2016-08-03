--
-- https://github.com/grzeg1/websocket_deflate_postdissector
--

local zlib=require 'zlib'

zlibPrefix = "\x78\x01"

tcp_stream = Field.new("tcp.stream")
websocket_payld = Field.new("websocket.payload")

socketio_proto = Proto("socketio", "WebSocket permessage-deflate postdissector")
type_F = ProtoField.string("socketio.type", "Text")
socketio_proto.fields = {type_F}

local streams

function socketio_proto.init()
  streams = {}
end

-- create a function to "postdissect" each frame
function socketio_proto.dissector(buffer, pinfo, tree)
    -- obtain the current values the protocol fields
    local websocket_payload = websocket_payld()
    if websocket_payload then
	local data = zlibPrefix..websocket_payload.range:bytes():raw()
	local inflateStream = zlib.inflate()
	local inflated = inflateStream(data)
        local subtree = tree:add(socketio_proto, "Inflated payload")
        subtree:add(type_F, inflated)
    end
end

register_postdissector(socketio_proto)
