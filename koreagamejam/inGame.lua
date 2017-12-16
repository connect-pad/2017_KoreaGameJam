local composer = require "composer"
local physcis = require "physics"

local scene = composer.newScene()

local _W, _H = display.contentWidth, display.contentHeight
local content = {}
local character_image, character_stat, character_move = {}, {}, {}
local showUI, makeCharacter

local playerCollisionFilter = { categoryBits = 1, maskBits = 28 }
local playerBulletCollisionFilter = { categoryBits = 2, maskBits = 28 }
local enemyCollisionFilter = { categoryBits = 4, maskBits = 19 }
local enemyBulletCollisionFilter = { categoryBits = 8, maskBits = 19 }
local wallCollisionFilter = { categoryBits = 16, maskBits = 15 }

local maxHP = 100

local function CC(hex)
	local r = tonumber( hex:sub(1,2), 16) / 255
	local g = tonumber( hex:sub(3,4), 16) / 255
	local b = tonumber( hex:sub(5,6), 16) / 255
	local a = 255/255
	if #hex == 8 then a = tonumber( hex:sub(7,8), 16) / 255 end
	return r,g,b,a
end

function showUI()
  content[1] = display.newRect( 0, 0, _W, _H*0.7 )
  content[1].anchorX, content[1].anchorY = 0, 0
  content[1]:setFillColor( CC("555555") )
end



function makeCharacter(id)
  local ud, lr = 0, 0
  local bud, blr = 0, 0
  local bx, by = 800, 800
  -- local angle = 0

  -- character key event
  function keyCharacter(e)
    if e.phase == "down" then
      --move
      if e.keyName == "a" then
        lr = lr - 1
      elseif e.keyName == "d" then
        lr = lr + 1
      elseif e.keyName == "w" then
        ud = ud - 1
      elseif e.keyName == "s" then
        ud = ud + 1
      end

      --bullet
      if e.keyName == "left" then
        blr = blr - 1
      elseif e.keyName == "right" then
        blr = blr + 1
      elseif e.keyName == "up" then
        bud = bud - 1
      elseif e.keyName == "down" then
        bud = bud + 1
      end

    elseif e.phase == "up" then
      --move
      if e.keyName == "a" then
        lr = lr + 1
      elseif e.keyName == "d" then
        lr = lr - 1
      elseif e.keyName == "w" then
        ud = ud + 1
      elseif e.keyName == "s" then
        ud = ud - 1
      end

      --bullet
      if e.keyName == "left" then
        blr = blr + 1
      elseif e.keyName == "right" then
        blr = blr - 1
      elseif e.keyName == "up" then
        bud = bud + 1
      elseif e.keyName == "down" then
        bud = bud - 1
      end
    end
  end

  function onMouse(e)
    bx = 800 * ( e.x - character_image["id"].x ) / ( math.sqrt( math.pow( e.x - character_image["id"].x , 2 ) + math.pow( e.y - character_image["id"].y, 2 ) ) )
    by = 800 * ( e.y - character_image["id"].y ) / ( math.sqrt( math.pow( e.x - character_image["id"].x , 2 ) + math.pow( e.y - character_image["id"].y, 2 ) ) )

    -- print("x : "..bx.."   y : "..by)
  end

  -- character enterframe event
  function charEnterFrame(e)
    function moveCharacter()
      -- print("LR : "..lr.."   UD : "..ud)

      character_image["id"].x = character_image["id"].x + lr*5
      character_image["id"].y = character_image["id"].y + ud*5
    end

    function trigBullet()

      if blr == -1 then
        if bud == -1 then angle = 135
        elseif bud == 0 then angle = 180
        elseif bud == 1 then angle = 225
        end

      elseif blr == 0 then
        if bud == -1 then angle = 90
        elseif bud == 1 then angle = 270
        end

      elseif blr == 1 then
        if bud == -1 then angle = 45
        elseif bud == 0 then angle = 0
        elseif bud == 1 then angle = 315
        end
      end
    end

    moveCharacter()
    trigBullet()
  end

  function makeBullet(angle)
    local bullet

    function removeBullet()
      if not physics.removeBody(bullet) then
      end
    end

    function checkLocation(e)
      if bullet.x + 10 < 0 then
        timer.cancel( e.source )
        removeBullet()
        print(1)
      elseif bullet.x - 10 > _W then
        timer.cancel( e.source )
        removeBullet()
        print(2)
      elseif bullet.y + 10 < 0 then
        timer.cancel( e.source )
        removeBullet()
        print(3)
      elseif bullet.y - 10 > _H then
        timer.cancel( e.source )
        removeBullet()
        print(4)
      end
    end
    bullet = display.newCircle( character_image["id"].x + character_image["id"].contentWidth * 0.5 ,    character_image["id"].y + character_image["id"].contentHeight * 0.5, 10 )
    physics.addBody( bullet, "dynamic", { radius = 10, filter = playerBulletCollisionFilter } )

    bullet.isBullet = true

    --[[
    bullet.xVelocity = (blr == -1) and -800 or ( blr == 0 ) and 0 or 800
    bullet.yVelocity = (bud == -1 ) and -800 or ( bud == 0 ) and 0 or 800

    if bullet.xVelocity ~= 0 or bullet.yVelocity ~= 0 then
      bx = bullet.xVelocity
      by = bullet.yVelocity
    end
    ]]--

    bullet:setLinearVelocity( bx, by )

    --Runtime:addEventListener( "enterFrame", checkLocation )
    --timer.performWithDelay( 50, checkLocation, -1 )
  end


  character_stat["id"] =
  {
    ["cla"] = 1, -- character class
    ["atk"] = 10, -- character attack
    ["def"] = 10, -- character defend
    ["spd"] = 10, --character moving speed
    ["ats"] = 500, --attack speed ( in 1s )
  }

  character_image["id"] = display.newCircle( _W*0.5, _H*0.35, 30 )
  character_image["id"].anchorX, character_image["id"].anchorY = 0, 0

  physics.addBody( character_image["id"], "dynamic", { radius = 30, filter = playerCollisionFilter } )

  Runtime:addEventListener( "key", keyCharacter )
  Runtime:addEventListener( "enterFrame", charEnterFrame )
  Runtime:addEventListener( "mouse", onMouse )
  timer.performWithDelay( character_stat["id"]["ats"] , makeBullet, -1 )
end

function endedGame(event)
  local options =
  {
    effect = "fade",
    time = 500,
    params =
    {
      someKey = "someValue",
      someOtherKey = 10
    }
  }
  composer.gotoScene( sceneName, options )
end

function scene:create(event)

  local sceneGroup = self.view

  physcis.start()
  physics.setGravity( 0, 0 )
  display.setDrawMode( "hybrid" )
end

function scene:show(event)

  local sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then

    showUI()
    makeCharacter("aaaa")

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
