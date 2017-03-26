-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Use the require function to include the Corona "composer" module so 
-- we can create a new scene.
local composer = require( "composer" )

-- Use composer to create a new scene. 
local scene = composer.newScene()

system.activate("multitouch")
local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

math.randomseed(os.time())

-- Configure image sheet

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

local objectSheet = graphics.newImageSheet("res/img/SpriteSheet.png", sheetOptions)

if(objectSheet == nil) then
	print("empty!")
end

-- Initialize variables
local score = 0
local lives = 5
local died = false

local enemiesTable = {}
local gameLoopTimer
local typeEnemy = 0

local count = 1
local maxEnemies = 4

local prevTime = nil
-- Add bool type for left button and right.
local pressedLieftBtn = false
local pressedRightBtn = false

local currentSpeed = 2000
local fireEnemiesSpeed = 4000

-- Set up display groups.

local backGroup = display.newGroup() -- Display group for the background image.
local mainGroup = display.newGroup() -- Display group for the ship, enemies and etc.
local uiGroup = display.newGroup() -- Display group for the UI object like  the score.

-- Load the background.

local background = display.newImage(backGroup, "res/img/paralax_space2.png")
background.x = display.contentWidth
background.y = display.contentHeight

-- Load the ship.
local ship = display.newImageRect(mainGroup, objectSheet , 6, 45, 51) -- divided by 3 width = 136 / 3 and height = 152 / 3
ship.x = display.contentCenterX
ship.y = display.contentCenterY + 150
physics.addBody(ship, {radius = 30, isSensor = true})
ship.myName = "ship"

-- Load the text.
local scoreText = display.newText(uiGroup, "Score: " .. score, display.contentCenterX  - 100 ,  display.contentCenterY - 250 , native.systemFont, 20 )
local livesText = display.newText(uiGroup, "Lives: " .. lives, display.contentCenterX + 100, display.contentCenterY - 250, native.systemFont, 20)
--local xPosText = display.newText(uiGroup, "x: " .. ship.x, display.contentCenterX  - 100 ,  display.contentCenterY - 210 , native.systemFont, 20)
--local yPosText = display.newText(uiGroup, "y: " .. ship.y, display.contentCenterX  - 100 ,  display.contentCenterY - 190 , native.systemFont, 20)

-- Hide the status bar.
display.setStatusBar( display.HiddenStatusBar )

-- Returns Delta time
local function GetDeltaTime()

	if(prevTime == nil) then
		return 0
	end
	
	local currentTime = system.getTimer()
	local deltaTime = currentTime - prevTime
	prevTime = currentTime
	
	return deltaTime
end

-- Update Text function.
local function UpdateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
	--if(ship.isBodyActive == true) then
		--xPosText.text = "x: " .. ship.x
		--yPosText.text = "y: " .. ship.y
	--end
end -- UpdateText function.

local function RestoreShip()
	ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentCenterY + 150
 
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=3000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end -- RestoreShip function.

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
	 
end

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
end

-- Buttons on screen.

local widget = require( "widget" )

--Function to handle button events for firebutton.
local function HandleFireButtonEvent(event)
	if("ended" == event.phase and ship ~= nil and ship.x ~= nil) then
		FireRocket()
		return true
	end
	
	return false
end -- HandleFireButtonEvent

local fireButton = widget.newButton
{
	left = display.contentCenterX - 150,
	top = display.contentHeight - 40,
	width = 60,
	height = 60,
	defaultFile = "res/img/fire.png",
	overFile = "res/img/fire.png",
	onEvent = HandleFireButtonEvent,
}

local function HandleRightButtonEvent(event)

	local phase = event.phase
	
	if(phase == "began") then
		pressedRightBtn = true
		pressedLieftBtn = false
		return true
	elseif(phase == "ended" or phase == "cancelled") then
		pressedRightBtn = false
		return true
	end
	
	return false
end -- HandleRightButtonEvent

local rightButton = widget.newButton
{
	left = display.contentCenterX + 95,
	top = display.contentHeight - 40,
	width = 60,
	height = 60,
	defaultFile = "res/img/rightButton.png",
	overFile = "res/img/rightButton.png",
	onEvent = HandleRightButtonEvent,
}

local function HandleleftButtonEvent(event)

	local phase = event.phase
	if(phase == "began") then
		pressedLieftBtn = true
		pressedRightBtn = false
		return true
	elseif(phase == "ended") then
		pressedLieftBtn = false
		return true
	end
	
	return false
end -- HandleLeftButtonEvent

local leftButton = widget.newButton
{
	left = display.contentCenterX + 25,
	top = display.contentHeight - 40,
	width = 60,
	height = 60,
	defaultFile = "res/img/leftButton.png",
	overFile = "res/img/leftButton.png",
	onEvent = HandleleftButtonEvent,
}

leftButton.alpha = 0.7
rightButton.alpha = 0.7
fireButton.alpha = 0.7

-- Move ship function it works by dragging ship.
local function DragShip(event)
	
	local ship = event.target
	local phase = event.phase
	
	if( "began" == phase) then
		-- Set touch focus on the ship.
		display.currentStage:setFocus( ship )
		-- Store initial offset position.
		ship.touchOffsetX = event.x - ship.x
		--ship.touchOffsetY = event.y - ship.y
	elseif("moved" == phase) then
		-- Move the ship to the new touch position.
		ship.x = event.x - ship.touchOffsetX
		--ship.y = event.y - ship.touchOffsetY
		
	elseif("ended" == phase or "cancelled" == phase) then
		-- Release touch focus on the ship.
		display.currentStage:setFocus( nil )
	end
	
	if(ship.x < 23 or ship.x == 23) then
		ship.x = 23
	elseif (ship.x > 296 or ship.x == 296) then
		ship.x = 296
	end
	
	--UpdateText()
	return true -- Prevents touch propagation to underlying objects.
	
end -- DragShip function.

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
	
	if (pressedLieftBtn == true  and ship ~= nil and ship.x ~= nil) then
		
		ship.x = ship.x - moveSpeed
		
		if(ship.x < 23 or ship.x == 23) then
			ship.x = 23
		end
		--UpdateText()
		return true
	end
	
	return false
end -- onFrame 

-- SetUp Events. --

-- Ship events.
ship:addEventListener("tap", FireRocket )
ship:addEventListener( "touch", DragShip )
Runtime:addEventListener( "enterFrame", onFrame  )
-- Game events.
Runtime:addEventListener( "collision", OnCollision )


local countEnemys = 1

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

-- Loop function.
local function GameLoop()
	-- SetUp prevTime.
    prevTime = system.getTimer()
	
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
	
end

gameLoopTimer = timer.performWithDelay( currentSpeed, GameLoop, 0) 