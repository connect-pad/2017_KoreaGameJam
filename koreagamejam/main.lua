local composer = require "composer"
local WebSockets = require 'dmc_corona.dmc_websockets'
local ws

-- ws:send( str )
-- ws:close()

local function webSocketsEvent_handler( event )
	-- print( "webSocketsEvent_handler", event.type )
	local evt_type = event.type

	if evt_type == ws.ONOPEN then
		print( 'Received event: ONOPEN' )


	elseif evt_type == ws.ONMESSAGE then
		local msg = event.message
		

		print( "Received event: ONMESSAGE" )
		print( "echoed message: '" .. tostring( msg.data ) .. "'\n\n" )

	elseif evt_type == ws.ONCLOSE then
		print( "Received event: ONCLOSE" )
		print( 'code:reason', event.code, event.reason )

	elseif evt_type == ws.ONERROR then
		print( "Received event: ONERROR" )
		-- Utils.print( event )

	end
end


ws = WebSockets{
	uri='ws://192.168.21.190:1337'
}
ws:addEventListener( ws.EVENT, webSocketsEvent_handler )



composer.gotoScene( "inGame" )

