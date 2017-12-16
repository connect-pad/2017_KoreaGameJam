local player = {}

local ud, lr = 0, 0
local bud, blr = 0, 0
local bx, by = 800, 800

function player.makeChar(id)
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



return player
