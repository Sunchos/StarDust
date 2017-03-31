
local composer = require( "composer" )
-- Create new scene.
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Hide the status bar.
display.setStatusBar( display.HiddenStatusBar )
-- Set physics engine.
local physics = require("physics")
physics.start()
physics.setGravity(0, 0)
-- Set multitouch screen.
system.activate("multitouch")

-- Configure image sheet.
local sheetOptions  = 
{
	frames = 
	{
		{ -- 1) GreenFly.
			x = 0,
			y = 0,
			width = 120,
			height = 128
		},
		{ -- 2) RedFly.
			x = 8,
			y = 129,
			width = 104,
			height = 80
		},
		{ -- 3) YellowBee.
			x = 16,
			y = 210,
			width = 88,
			height = 80
		},
		{ -- 4) Heart.
			x = 8,
			y = 291,
			width = 104,
			height = 88
		},
		{ -- 5) Red ship player.
			x = 121,
			y = 0,
			width = 136,
			height = 152
		},
		{ -- 6) White ship player.
			x = 121,
			y = 153,
			width = 136,
			height = 152
		},
		{ -- 7) Player rocket.
			x = 121,
			y = 306,
			width = 24,
			height = 48
		},
		{ -- 8) Enemy rocket.
			x = 146,
			y = 306,
			width = 24,
			height = 48
		},
		{ -- 9) Short model ship, this for lives.
			x = 171,
			y = 306,
			width = 21,
			height = 23
		},
	},
}

--------------------------------------------------------------------------------------------------
-- Initialize variables.
--------------------------------------------------------------------------------------------------
-- Counter rockets.
local count = 1
-- Count enemies.
local countEnemys = 1
-- Speed of loop.
local currentSpeed = 2000
-- Background.
local background = nil
-- Back ground layer.
local backGroup = nil
-- Status is player died.
local died = false
-- Table for enemies.
local enemiesTable = {}
-- Fire button.
local fireButton = nil
-- Speed in microseconds fire enemies.
local fireEnemiesSpeed = 4000
-- Game loop timer.
local gameLoopTimer
-- Left button.
local leftButton = nil
-- Lives value.
local lives = 5
-- Live text field.
local livesText = nil
-- Main group layer.
local mainGroup = nil
-- Max count enemies(Maybe it will be removed or changed)
local maxEnemies = 4
-- Object sheet.
local objectSheet = graphics.newImageSheet("res/img/SpriteSheet.png", sheetOptions)
-- Set previous time, for counting delta time  between counter and hardware. 
local prevTime = nil
-- Check is left button hold.
local pressedLeftBtn = false
-- Check is right button hold.
local pressedRightBtn = false
-- Check is fire button hold.
local pressedFireBtn = false
-- Right button.
local rightButton = nil
-- Game score.
local score = 0
-- Score text field.
local scoreText = nil
-- Players ship.
local ship = nil
-- Type enemy.
local typeEnemy = 0
-- Ui group layer.
local uiGroup = nil
-- Widget.
local widget = require( "widget" )

-- ----------------------------------------------------------------------------------------
-- Common functions.
-- ----------------------------------------------------------------------------------------
-- Create Enemies.
local function CreateEnemy(typeEnemy, xPos, yPos)
	local newEnemy
	if (typeEnemy == 1) then -- GreenFly.
		newEnemy = display.newImageRect(mainGroup, objectSheet , 1, 40, 42) 
	elseif(typeEnemy == 2) then -- RedFly.
		newEnemy = display.newImageRect(mainGroup, objectSheet , 2, 34, 26) 
	elseif(typeEnemy == 3) then -- YellowBee.
		newEnemy = display.newImageRect(mainGroup, objectSheet , 3, 29, 26) 
	end
	
	table.insert(enemiesTable, newEnemy)
	physics.addBody(newEnemy, "dynamic", {radius = 20, bounce = 0.0})
	newEnemy.myName = "enemy"

  newEnemy.x = xPos
  newEnemy.y = yPos
	 
end -- CreateEnemy.

-- Fire Rocket for enemy.
local function FireEnemy(xPos, yPos)
	local newRocket = display.newImageRect(mainGroup, objectSheet, 8, 8, 16)
	physics.addBody(newRocket, "dynamic", {radius = 20 ,isSensor = true} )
	newRocket.isBullet = true
	newRocket.myName = "enemyRocket"
	
	newRocket.x = xPos
	newRocket.y = yPos
	
	newRocket:toBack()
	
	transition.to( newRocket, { y = display.contentHeight + 20, time = fireEnemiesSpeed, 
			onComplete = function() display.remove(newRocket) end
			})
end -- FireEnemy.

-- Fire Rocket function it works by tapping ship .
local function FireRocket()
	local newRocket = display.newImageRect(mainGroup, objectSheet, 7, 8, 16)
	physics.addBody(newRocket, "dynamic", {isSensor = true} )
	newRocket.isBullet = true
	newRocket.myName = "rocket"
	
	if(count % 2 == 0) then
		newRocket.x = ship.x - 13
		newRocket.y = ship.y
		count = count + 1
	else 
		newRocket.x = ship.x + 13
		newRocket.y = ship.y
		count = count + 1
	end
	
	if(count > 10) then
		count = 1
	end
	
	newRocket:toBack()
	
	transition.to( newRocket, { y = -20, time = 500, 
			onComplete = function() display.remove(newRocket) end
			})
end -- FireRocket function.

-- Returns Delta time
local function GetDeltaTime()

	if(prevTime == nil) then
		return 0
	end
	
	local currentTime = system.getTimer()
	local deltaTime = currentTime - prevTime
	prevTime = currentTime
	
	return deltaTime
end -- GetDeltaTime.

-- Restore player ship.
local function RestoreShip()
	ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentCenterY + 150
 
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=2000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end -- RestoreShip function.

-- Set enemies position on screen.
local function SetEnemiesPosition()
  local distance = 90
  local xPos = display.contentWidth - 40
  local yPos = display.contentCenterY - distance
  for i = 0, maxEnemies do
    for j = 1, 3 do
      CreateEnemy(math.random(3), xPos , yPos)
      yPos = yPos - 60
    end
    xPos = xPos - 60
    yPos = display.contentCenterY - distance
    countEnemys = countEnemys + 1
  end
end

-- Update Text function.
local function UpdateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
end -- UpdateText function.

-- ----------------------------------------------------------------------------------------
-- Controls, buttons and etc.
-- ----------------------------------------------------------------------------------------
-- Move ship function it works by dragging ship.
local function DragShip(event)
	
	local ship = event.target
	local phase = event.phase
	
	if( "began" == phase and ship.x ~= nil) then
		-- Set touch focus on the ship.
		display.currentStage:setFocus( ship )
		-- Store initial offset position.
		ship.touchOffsetX = event.x - ship.x
		--ship.touchOffsetY = event.y - ship.y
	elseif("moved" == phase and ship.x ~= nil) then
		-- Move the ship to the new touch position.
		ship.x = event.x - ship.touchOffsetX
		--ship.y = event.y - ship.touchOffsetY
		
	elseif("ended" == phase or "cancelled" == phase and ship.x ~= nil) then
		-- Release touch focus on the ship.
		display.currentStage:setFocus( nil )
	end
	
	if(ship.x < 23 or ship.x == 23 and ship.x ~= nil) then
		ship.x = 23
	elseif (ship.x > 296 or ship.x == 296 and ship.x ~= nil) then
		ship.x = 296
	end
	
	--UpdateText()
	return true -- Prevents touch propagation to underlying objects.
	
end -- DragShip function.

--Function to handle button events for firebutton.
local function HandleFireButtonEvent(event)

	phase = event.phase
	if(phase == "began") then
		pressedFireBtn = true
		return true
	elseif(phase == "moved") then
		pressedFireBtn = true
	elseif(phase == "ended" or phase == "cancelled") then
		pressedFireBtn = false
		return true
	end
	
	return false
end -- HandleFireButtonEvent.

--Function to handle button events for left button.
local function HandleLeftButtonEvent(event)

	local phase = event.phase
	if(phase == "began") then
		pressedLeftBtn = true
		pressedRightBtn = false
		return true
	elseif(phase == "ended") then
		pressedLeftBtn = false
		return true
	end
	
	return false
end -- HandleLeftButtonEvent.

--Function to handle button events for right button.
local function HandleRightButtonEvent(event)

	local phase = event.phase
	
	if(phase == "began") then
		pressedRightBtn = true
		pressedLeftBtn = false
		return true
	elseif(phase == "ended" or phase == "cancelled") then
		pressedRightBtn = false
		return true
	end
	
	return false
end -- HandleRightButtonEvent.

fireButton = widget.newButton
{
	left = display.contentCenterX - 150,
	top = display.contentHeight - 40,
	width = 60,
	height = 60,
	defaultFile = "res/img/fire.png",
	overFile = "res/img/fire.png",
	onEvent = HandleFireButtonEvent,
}

leftButton = widget.newButton
{
	left = display.contentCenterX + 25,
	top = display.contentHeight - 40,
	width = 60,
	height = 60,
	defaultFile = "res/img/leftButton.png",
	overFile = "res/img/leftButton.png",
	onEvent = HandleLeftButtonEvent,
}

rightButton = widget.newButton
{
	left = display.contentCenterX + 95,
	top = display.contentHeight - 40,
	width = 60,
	height = 60,
	defaultFile = "res/img/rightButton.png",
	overFile = "res/img/rightButton.png",
	onEvent = HandleRightButtonEvent,
}

fireButton.alpha = 0.7
leftButton.alpha = 0.7
rightButton.alpha = 0.7

-- Move ship by controls buttons or maybe by keys 
local function onFrame (event)
	local deltaTime = GetDeltaTime()
	local moveSpeed = (0.3 * deltaTime)
	
	if(pressedRightBtn == true  and ship ~= nil and ship.x ~= nil) then
	
		ship.x = ship.x + moveSpeed
		
		if (ship.x > 296 or ship.x == 296) then
			ship.x = 296
		end
		--UpdateText()
		return true
	end
	
	if (pressedLeftBtn == true  and ship ~= nil and ship.x ~= nil) then
		
		ship.x = ship.x - moveSpeed
		
		if(ship.x < 23 or ship.x == 23) then
			ship.x = 23
		end
		--UpdateText()
		return true
	end
	
	if(pressedFireBtn == true and ship ~= nil and ship.x ~= nil) then
		FireRocket()
		return true
	end
	
	return false
end -- onFrame 

local function onKeyEvent( event )

	local deltaTime = GetDeltaTime()
	local moveSpeed = (0.3 * deltaTime)
	
	local keyName = event.keyName
	local phase = event.phase
	
	--local message = "Key '" .. event.keyName .. "' was pressed! " .. event.phase
	--print( message )
	
	if(keyName == "left" and ship ~= nil and ship.x ~= nil) then
		
		if(phase == "down") then
			pressedLeftBtn = true
			pressedRightBtn = false
		elseif(phase == "up") then
			pressedLeftBtn = false
		end
		--[[ship.x = ship.x - moveSpeed
		
		if(ship.x < 23 or ship.x == 23) then
			ship.x = 23
		end]]
		
		--return true
	elseif(keyName == "right" and ship ~= nil and ship.x ~= nil ) then
		
		if(phase == "down") then
			pressedRightBtn = true
			pressedLeftBtn = false
		elseif(phase == "up") then
			pressedRightBtn = false
		end
		--[[ship.x = ship.x + moveSpeed
		
		if (ship.x > 296 or ship.x == 296) then
			ship.x = 296
		end]]
		
		--return true
	elseif(keyName == "space"  and ship ~= nil and ship.x ~= nil) then
		
		if(phase == "down") then
			pressedFireBtn = true
		elseif(phase == "up") then
			pressedFireBtn = false
		end
		--FireRocket()
		
		--return true
	end
	
	return false
end -- onKeyEvent.

-- ----------------------------------------------------------------------------------------
-- Event functions.
-- ----------------------------------------------------------------------------------------
-- It checks collision between ship, enemies and rockets.  
local function OnCollision( event )
	if( event.phase == "began" ) then
		local obj1 = event.object1
		local obj2 = event.object2
		
		if((obj1.myName == "rocket" and obj2.myName == "enemy") or
			(obj1.myName == "enemy" and obj2.myName == "rocket")) then
			 -- Remove both the rocket and enemy.
			display.remove(obj1)
			display.remove(obj2)
			
			for i = #enemiesTable, 1, -1 do
				if(enemiesTable[i] == obj1 or enemiesTable[i] == obj2) then
					table.remove(enemiesTable, i)
				end
			end
			
			-- Increase score.
			score = score + 100
			if((score % 20000) == 0 ) then
				lives = lives + 1
			end
		elseif((obj1.myName == "ship" and obj2.myName == "enemyRocket") or
				  (obj1.myName == "enemyRocket" and obj2.myName == "ship")) then
			 if( died == false) then
					died = true
					
					-- Update lives.
					lives = lives - 1
					
                    if ( lives == 0 ) then
                        display.remove( ship )
                    else
                        ship.alpha = 0
                        timer.performWithDelay( 1000, RestoreShip )
                    end
			 end
		elseif((obj1.myName == "rocket" and obj2.myName == "enemyRocket") or
		(obj1.myName == "enemyRocket" and obj2.myName == "rocket")) then
			 -- Remove both the rocket and enemy.
			-- Increase score.
			display.remove( obj1 )
			display.remove (obj2)
			--score = score + 50
		end
	end
	
	UpdateText()
	return false
end -- OnCollision.

-- Loop function.
local function GameLoop()
	-- SetUp prevTime.
    --prevTime = system.getTimer()
	
	if(maxEnemies >= countEnemys) then
		SetEnemiesPosition()
	end

	if(--[[math.round((prevTime % 1000) % 2)== 0 and]] #enemiesTable ~= 0) then
		local thisFire =enemiesTable[math.random(#enemiesTable)]
		if(thisFire ~= nil) then
			FireEnemy(thisFire.x, thisFire.y)
		end
	else
		-- Next round.
		currentSpeed = currentSpeed - 100
		fireEnemiesSpeed = fireEnemiesSpeed - 100
	end
	
	--[[for i = #enemiesTable, 1, -1 do
		local thisEnemy = enemiesTable[i]
		if(thisEnemy.x < -100 or 
			thisEnemy.x > display.contentWidth + 100 or
			thisEnemy.y < -100 or 
			thisEnemy.y > display.contentHeight + 100) then
				display.remove(thisEnemy)
				table.remove(enemiesTable, i)
		end
    end]]--
	
	if #enemiesTable == 0 then
		countEnemys = 0
	end
	
end -- GameLoop.

-- ----------------------------------------------------------------------------------------
-- Scene event functions.
-- ----------------------------------------------------------------------------------------
-- Occurs when the scene is first created but has not yet appeared on screen.
function scene:create( event )
	local sceneGroup = self.view
	
	physics.pause() -- Temporarily pause the physics engine.
	
	-- Set up display groups.
	backGroup = display.newGroup() -- Display group for the background image.
	sceneGroup:insert( backGroup ) -- Insert into the scene's view group.
	
	mainGroup = display.newGroup() -- Display group for the ship, enemies and etc.
	sceneGroup:insert( mainGroup ) -- Insert into the scene's view group.
	
	uiGroup = display.newGroup() -- Display group for the UI object like  the score.
	sceneGroup:insert( uiGroup ) -- Insert into the scene's view group.
	
	-- Load the background.
	background = display.newImage(backGroup, "res/img/paralax_space2.png")
	background.x = display.contentWidth
	background.y = display.contentHeight
	
	-- Load the ship.
	ship = display.newImageRect(mainGroup, objectSheet , 6, 45, 51) -- divided by 3 width = 136 / 3 and height = 152 / 3
	ship.x = display.contentCenterX
	ship.y = display.contentCenterY + 150
	physics.addBody(ship, {radius = 30, isSensor = true})
	ship.myName = "ship"
	
	-- Load the text.
	scoreText = display.newText(uiGroup, "Score: " .. score, display.contentCenterX  - 100 ,  display.contentCenterY - 250 , native.systemFont, 20 )
	livesText = display.newText(uiGroup, "Lives: " .. lives, display.contentCenterX + 100, display.contentCenterY - 250, native.systemFont, 20)
	
	-- -----------------------------------------------------------------------------------------------------------------
	-- SetUp Events.
	-- -----------------------------------------------------------------------------------------------------------------
	-- Ship events.
	ship:addEventListener("tap", FireRocket )
	ship:addEventListener( "touch", DragShip )

end -- create.

-- Occurs twice, immediately before and immediately after the scene appears on screen.
function scene:show( event )
	
	local sceneGroup = self.view
	local phase = event.phase
	
	if( phase == "will" )  then
	
	elseif( phase == "did" ) then
		physics.start()	
		-- Game events.
		Runtime:addEventListener( "enterFrame", onFrame  )
		Runtime:addEventListener( "collision", OnCollision )
		Runtime:addEventListener( "key", onKeyEvent )
		prevTime = system.getTimer()
		gameLoopTimer = timer.performWithDelay( 2000, GameLoop, 0) 
	end
	
end -- show.

-- Occurs twice, immediately before and immediately after the scene exits the screen.
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if( phase == "will" )  then
		timer.cancel( gameLoopTimer )
	elseif( phase == "did" ) then
		Runtime:removeEventListener( "enterFrame", onFrame  )
		Runtime:removeEventListener( "collision", onCollision )
		Runtime:removeEventListener( "key", onKeyEvent )
        physics.pause()
		composer.removeScene( "game" )
	end
	
end -- hide.

-- Occurs if the scene is destroyed.
function scene:destroy( event )

	local sceneGroup = self.view
	
end -- destroy. 

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene