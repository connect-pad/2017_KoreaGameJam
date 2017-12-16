-- -----------------------------------------------------------------------------------------------------------------------------------
-- modules
-- -----------------------------------------------------------------------------------------------------------------------------------
local composer = require "composer"
local physcis = require "physics"
local WebSockets = require 'dmc_corona.dmc_websockets'
local json = require "json"
local ws
local json = require( "json" )

local scene = composer.newScene()

local _W, _H = display.contentWidth, display.contentHeight
local content = {}
local character_image, character_stat, character_move, character_id = {}, {}, {}, {}
local showUI, makeCharacter
local isGameStart = false
local maxHP = 100

-- convert color:hex to rgb
local function CC(hex)
	local r = tonumber( hex:sub(1,2), 16) / 255
	local g = tonumber( hex:sub(3,4), 16) / 255
	local b = tonumber( hex:sub(5,6), 16) / 255
	local a = 255/255
	if #hex == 8 then a = tonumber( hex:sub(7,8), 16) / 255 end
	return r,g,b,a
end



-- -----------------------------------------------------------------------------------------------------------------------------------
-- collision filter
-- -----------------------------------------------------------------------------------------------------------------------------------

local playerCollisionFilter = { categoryBits = 1, maskBits = 28 }
local playerBulletCollisionFilter = { categoryBits = 2, maskBits = 28 }
local enemyCollisionFilter = { categoryBits = 4, maskBits = 19 }
local enemyBulletCollisionFilter = { categoryBits = 8, maskBits = 19 }
local wallCollisionFilter = { categoryBits = 16, maskBits = 15 }



-- -----------------------------------------------------------------------------------------------------------------------------------
-- socket
-- -----------------------------------------------------------------------------------------------------------------------------------

-- ws:send( str )
-- ws:close()

-- web socket event handler
function webSocketsEvent_handler( event )
	-- print( "webSocketsEvent_handler", event.type )
	local evt_type = event.type

	if evt_type == ws.ONOPEN then
		print( 'Received event: ONOPEN' )

	elseif evt_type == ws.ONMESSAGE then
		local msg = event.message

		print( "Received event: ONMESSAGE" )
    print( "echoed message: '" .. tostring( msg.data ) .. "'\n\n" )

    resultTable = json.decode(msg.data)

    if resultTable.event == "arrowKeyDown" then
      eventArrowKeyDown(resultTable)
    elseif resultTable.event == "arrowKeyUp" then
      eventArrowKeyUp(resultTable)
    elseif resultTable.event == "rotationKeyDown" then
      eventRotationKeyDown(resultTable)
    elseif resultTable.event == "rotationKeyUp" then
      eventRotationKeyUp(resultTable)
    elseif resultTable.event == "gameStart" then
      eventGameStart(resultTable)
    end


	elseif evt_type == ws.ONCLOSE then
		print( "Received event: ONCLOSE" )
		print( 'code:reason', event.code, event.reason )

	elseif evt_type == ws.ONERROR then
		print( "Received event: ONERROR" )
		-- Utils.print( event )

	end
end

--[[
  data 형태
  {
    "uid":"mnLE33vu9FUsp8DUAAAD",
    "arrow": "W"
  }
]]
function eventArrowKeyDown(data)
	local id = data.uid
	local ar = data.arrow

	if ar == "N" then
		character_move["id"].UD = -1
		character_move["id"].LR = 0
	elseif ar == "W" then
		character_move["id"].UD = 0
		character_move["id"].LR = -1
	elseif ar == "E" then
		character_move["id"].UD = 0
		character_move["id"].LR = 1
	elseif ar == "S" then
		character_move["id"].UD = 1
		character_move["id"].LR = 0
	elseif ar == "NE" then
		character_move["id"].UD = -1
		character_move["id"].LR = 1
	elseif ar == "SE" then
		character_move["id"].UD = 1
		character_move["id"].LR = 1
	elseif ar == "NW" then
		character_move["id"].UD = -1
		character_move["id"].LR = -1
	elseif ar == "SW" then
		character_move["id"].UD = 1
		character_move["id"].LR = -1
	end
end

function eventArrowKeyUp(data)
  local id = data.uid
	if id == "6riLhW7R-9q3rF9RAAAG" then
		local ar = data.arrow

		character_move["id"].UD = 0
		character_move["id"].LR = 0
	end
end

--[[
  data 형태
  {
    "uid":"mnLE33vu9FUsp8DUAAAD",
    "angle": "210"
  }
]]
function eventRotationKeyDown(data)
  print("eventRotationKeyDown")
end

function eventRotationKeyUp(data)
  print("eventRotationKeyUp")
end

--[[
  data 형태
  {
    "userlist":[
      {
        "uid":""
        ...(미정)
      }
    ]
  }
]]

function eventGameStart(data)
	while true do
		table.insert( character_id , data.userlist.uid )
		character_move.id["UD"], character_move.id["LR"] = 0, 0
		makeCharacter(id)
	end
end

function sendSoundEffect(uid, file)
  print("sendSoundEffect")
end

function sendVibration(uid, array)
  print("sendVibration")
end

function sendGameEnd()
  print("sendGameEnd")
end



-- -----------------------------------------------------------------------------------------------------------------------------------
-- inGame
-- -----------------------------------------------------------------------------------------------------------------------------------

function showUI()
  content[1] = display.newRect( 0, 0, _W, _H*0.8 )
  content[1].anchorX, content[1].anchorY = 0, 0
  content[1]:setFillColor( CC("555555") )

	content[2] = display.newRect( 0, _H*0.8, _W, 30 )
	content[2].anchorX = 0
	content[2]:setFillColor( CC("ffff00") )

	content[3] = display.newRect( 0, _H*0.8, _W, 30 )
	content[3].anchorX = 0
	content[3]:setFillColor( CC("ff0000") )

end

function makeCharacter()
	for i = 1, table.maxn(character_id), 1 do
		local id = character_id[i]
		character_image.id = display.newCircle( _W*0.5, _H*0.35, 30 )
		character_image.id.anchorX, character_image.id.anchorY = 0, 0
		character_image.id.name = "char"

		physics.addBody( character_image.id, "static", { radius = 30, filter = playerCollisionFilter } )
		timer.performWithDelay( character_stat.id.ats, makeBullet, -1 )
	end
end


--[[
  function onMouse(e)
    bx = 800 * ( e.x - character_image.id.x ) / ( math.sqrt( math.pow( e.x - character_image.id.x , 2 ) + math.pow( e.y - character_image["id"].y, 2 ) ) )
    by = 800 * ( e.y - character_image.id.y ) / ( math.sqrt( math.pow( e.x - character_image.id.x , 2 ) + math.pow( e.y - character_image["id"].y, 2 ) ) )

    -- print("x : "..bx.."   y : "..by)
  end
]]--

local user
local monster
local monsterMaxHP, monsterHP

function makeMonster(type)

	function monsterTimer(e)
		function targetPoint(type)
			if type == 1 then return _W*0.5, _H*0.5
			else return character_image.character_id[type].x, character_image.character_id[type].y
			end
		end

		function monsterMoving()
			local x, y = targetPoint(type)
			--local x, y = user.x, user.y
			monster["LR"] = monster.x - x > 0 and -1 or monster.x == x and 0 or 1
			monster["UD"] = monster.y - y > 0 and -1 or monster.y == x and 0 or 1

			monster.x = monster.x + monster["LR"] * 1
			monsterMaxHP.x = monsterMaxHP.x + monster["LR"] * 1
			monsterHP.x = monsterHP.x + monster["LR"] * 1
			monster.y = monster.y + monster["UD"] * 1
			monsterMaxHP.y = monsterMaxHP.y + monster["UD"] * 1
			monsterHP.y = monsterHP.y + monster["UD"] * 1
		end

		local x = math.random( 0, 200 ) * math.pow( -1, math.random( 1, 2 ) )
		monster = display.newCircle( x < 0 and x or _W + x , math.random(0, _H), 25 )
		monster.x, monster.y = _W*0.5, _H*0.5
		monster.name = "monster"
		monster.hp = 30
		monster.max = 30
		monster:setFillColor(CC("111111"))
		physics.addBody( monster, "static", { radius = 25, filter = enemyCollisionFilter } )

		monsterMaxHP = display.newRect( monster.x, monster.y - 45, 70, 10 )
		monsterHP = display.newRect( monster.x - 35, monster.y - 45, 70, 10 )
		monsterHP.anchorX = 0
		monsterHP:setFillColor( CC("FF0000") )
		Runtime:addEventListener("enterFrame", monsterMoving )
	end

	timer.performWithDelay( math.random( 0, 500 ) + 750, monsterTimer, 1 )
end

function exampleUser()
	function moveUser(e)
		user.x, user.y = e.x, e.y
	end
	function shooting(e)
		local bullet = {}
		local max = 24
		for i = 1, max, 1 do
			bullet[i] = display.newCircle( user.x, user.y, 10 )
			physics.addBody( bullet[i], "dynamic", { radius = 10, filter = playerBulletCollisionFilter } )

			bullet[i].isBullet = true

			bx, by = 800 * math.cos(360*i/max), 800 * math.sin(360*i/max)
			-- print("bx : ".. bx.. "   by : "..by)

			bullet[i]:setLinearVelocity( bx, by )
			bullet[i].name = "bullet"
		end
	end
	user = display.newCircle( _W*0.5, _H*0.5, 30 )
	user:setFillColor(CC("777777"))
	user.name = "user"
	physcis.addBody( user, "dynamic", { radius = 30, filter = playerCollisionFilter } )
	Runtime:addEventListener("mouse", moveUser)
	Runtime:addEventListener("tap",shooting)
end

-- collision
function onGlobalCollision( e )
	function fadeout()
		monster:removeSelf()
		monsterHP:removeSelf()
		monsterMaxHP:removeSelf()
		Runtime:removeEventListener("enterFrame", monsterMoving )
	end
	print( "e.obj1 : " .. e.object1.name .. "   e.obj2 : " .. e.object2.name )
	if e.object1.name == "monster" and e.object2.name == "bullet" then
		e.object2:removeSelf()
		monsterHP:scale( monsterMaxHP.contentWidth / monsterHP.contentWidth , 1 )
		monster.hp = monster.hp - 1
		monsterHP:scale( monster.hp / monster.max, 1 )
		print( "monster hp : " .. monster.hp .. "   contentWidth : " .. monsterHP.contentWidth, 1 )
		if monster.hp == 0 then
			transition.to( monsterHP, { alpha = 0, time = 500 } )
			transition.to( monsterMaxHP, { alpha = 0, time = 500 } )
			transition.to( monster, { alpha = 0, time = 500, onComplete = fadeout } )
		end
	elseif e.object1.name == "user" and e.object2.name == "monster" then
		content[3]:scale( content[2].contentWidth / content[3].contentWidth , 1 )
		maxHP = maxHP - 1
		content[3]:scale( maxHP / 100, 1 )

		print(maxHP)

		if maxHP == 0 then
			Runtime:removeEventListener("collision", onGlobalCollision )
			Runtime:removeEventListener("enterFrames", enterFrameEvent )
		end
	end
end

Runtime:addEventListener( "collision", onGlobalCollision )


--[[
-- precollision
function onGlobalPreCollision( e )
	print("e.obj1 : "..e.object1.name.."   e.obj2 : "..e.object2.name)
	if e.object1.name == "monster" and e.object2.name == "bullet" then
		e.object2:removeSelf()
	end
end

Runtime:addEventListener( "preCollision", onGlobalPreCollision )
]]--

--[[
-- postcollision
function onGlobalPostCollision( e )
	print("e.obj1 : " .. e.object1.name .. "   e.obj2 : " .. e.object2.name )

	if e.object1.name == "monster" and e.object2.name == "bullet" then
		e.object2:removeSelf()
	end
end

Runtime:addEventListener("postCollision", onGlobalPostCollision)
]]--
-- -----------------------------------------------------------------------------------------------------------------------------------
-- enterFrameEvent
-- -----------------------------------------------------------------------------------------------------------------------------------

function enterFrameEvent(e)
	function moveCharacter()
		for i = 1, table.maxn(character_id), 1 do
			local id = character_id[i]
			chracter_image.id.x = character_image.id.x + character_move.id["LR"] * character_stat.id["spd"]
			charcter_image.id.y = character_image.id.y + character_move.id["UD"] * character_stat.id["spd"]
		end
	end
	if isGameStart then
		moveCharacter()
	end
end



-- -----------------------------------------------------------------------------------------------------------------------------------
-- scene
-- -----------------------------------------------------------------------------------------------------------------------------------

function scene:create(event)

  local sceneGroup = self.view


	-- socket setting
	ws = WebSockets{
		uri='ws://192.168.21.190:1337'
	}
	ws:addEventListener( ws.EVENT, webSocketsEvent_handler )

	-- physics setting
  physcis.start()
  physics.setGravity( 0, 0 )
  display.setDrawMode( "hybrid" )
end

function scene:show(event)

  local sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then

    showUI()

		Runtime:addEventListener( "enterFrame", enterFrameEvent )
		exampleUser()
		makeMonster(1)

  elseif phase == "did" then

  end
end

function scene:hide( event )

  local sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then

  elseif phase == "did" then

  end
end

function scene:destroy( event )

  local sceneGroup = self.view

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
