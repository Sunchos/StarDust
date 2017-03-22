-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

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
local maxEnemies = 20

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
ship.y = display.contentHeight - 60
physics.addBody(ship, {radius = 30, isSensor = true})
ship.myName = "ship"

-- Load the text.
local scoreText = display.newText(uiGroup, "Score: " .. score, display.contentCenterX  - 100 ,  display.contentCenterY - 230 , native.systemFont, 20 )
local livesText = display.newText(uiGroup, "Lives: " .. lives, display.contentCenterX + 100, display.contentCenterY - 230, native.systemFont, 20)
local xPosText = display.newText(uiGroup, "x: " .. ship.x, display.contentCenterX  - 100 ,  display.contentCenterY - 210 , native.systemFont, 20)
local yPosText = display.newText(uiGroup, "y: " .. ship.y, display.contentCenterX  - 100 ,  display.contentCenterY - 190 , native.systemFont, 20)

-- Hide the status bar.
display.setStatusBar( display.HiddenStatusBar )

-- Update Text function.
local function UpdateText()
	livesText.text = "Lives: " .. lives
	scoreText.text = "Score: " .. score
	xPosText.text = "x: " .. ship.x
	yPosText.text = "y: " .. ship.y
end -- UpdateText function.

local function RestoreShip()
	ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight - 60
 
    -- Fade in the ship
    transition.to( ship, { alpha=1, time=4000,
        onComplete = function()
            ship.isBodyActive = true
            died = false
        end
    } )
end -- RestoreShip function.

-- Create Enemies.
local function CreateEnemy(typeEnemy)
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

    local whereFrom = math.random( 3 )
	
	if( whereFrom == 1) then
		newEnemy.x = -60
		newEnemy.y = math.random( 100 )
		newEnemy:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
	 elseif ( whereFrom == 2 ) then
        -- From the top
        newEnemy.x = math.random( display.contentWidth )
        newEnemy.y = -60
        newEnemy:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        newEnemy.x = display.contentWidth + 60
        newEnemy.y = math.random( 100 )
        newEnemy:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end
	 
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

-- Buttons on screen.

local widget = require( "widget" )
local widget2 = require( "widget")

--Function to handle button events for firebutton.
local function HandleFireButtonEvent(event)
	local phase = event.phase
	if("ended" == phase) then
		FireRocket()
	end
end -- HandleFireButtonEvent

local fireButton = widget2.newButton
{
	left = display.contentCenterX - 150,
	top = display.contentHeight - 20,
	width = 40,
	height = 40,
	defaultFile = "res/img/fire.png",
	overFile = "res/img/fire.png",
	onEvent = HandleFireButtonEvent,
}

local function HandleRightButtonEvent(event)
	local phase = event.phase
	--[[if("began" == phase) then
		ship.x =ship. x + 5
	elseif("moved" == phase) then
		-- Move the ship to the new touch position.
		ship.x =ship. x + 5 ]]--
	if("ended" == phase) then
		ship.x = ship. x + 1
	end
	
	if (ship.x > 296 or ship.x == 296) then
		ship.x = 296
	end
	
	UpdateText()
end -- HandleRightButtonEvent

local rightButton = widget.newButton
{
	left = display.contentCenterX + 110,
	top = display.contentHeight - 20,
	width = 40,
	height = 40,
	defaultFile = "res/img/rightButton.png",
	overFile = "res/img/rightButton.png",
	onEvent = HandleRightButtonEvent,
}

local function HandleleftButtonEvent(event)
	local phase = event.phase
	--[[ if("began" == phase) then
		ship.x =ship. x - 5
	elseif("moved" == phase) then
		-- Move the ship to the new touch position.
		ship.x =ship. x - 5 ]]--
	if("ended" == phase) then
			ship.x = ship. x - 1
	end

	if(ship.x < 23 or ship.x == 23) then
		ship.x = 23
	end
	
	UpdateText()
end -- HandleLeftButtonEvent

local leftButton = widget.newButton
{
	left = display.contentCenterX + 60,
	top = display.contentHeight - 20,
	width = 40,
	height = 40,
	defaultFile = "res/img/leftButton.png",
	overFile = "res/img/leftButton.png",
	onEvent = HandleleftButtonEvent,
}

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
	
	UpdateText()
	return true -- Prevents touch propagation to underlying objects.
	
end -- DragShip function.

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
			if((score % 20000) == 0) then
				lives = lives + 1
			end
			
		elseif((obj1.myName == "ship" and obj2.myName == "enemy") or
				  (obj1.myName == "enemy" and obj2.myName == "ship")) then
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
		end
		
	end
	
	UpdateText()
end -- OnCollision.

-- SetUp Events. --

-- Ship events.
ship:addEventListener("tap", FireRocket )
ship:addEventListener( "touch", DragShip )
-- Game events.
Runtime:addEventListener( "collision", OnCollision )

countEnemys = 1

local enemiMoves
-- Loop function.
local function GameLoop()

	if(maxEnemies >= countEnemys) then
		CreateEnemy(math.random(3))
		countEnemys = countEnemys + 1
	end
	
	for i = #enemiesTable, 1, -1 do
		local thisEnemy = enemiesTable[i]
		if(thisEnemy.x < -100 or 
		thisEnemy.x > display.contentWidth + 100 or
		thisEnemy.y < -100 or 
		thisEnemy.y > display.contentHeight + 100) then
			display.remove(thisEnemy)
			table.remove(enemiesTable, i)
		end
    end
	
	if #enemiesTable == 0 then
		countEnemys = 0
	end
	
end

gameLoopTimer = timer.performWithDelay( 500, GameLoop, 0) 