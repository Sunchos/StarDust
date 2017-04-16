
local composer = require( "composer" )
-- Create new scene.
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables.
-- File path for store information.
local filePath = system.pathForFile("scores.json", system.DocumentsDirectory)
-- For encode and decode data we use json.
local json = require("json")
-- Leaderboard.
local scoresTable = {}

-- ----------------------------------------------------------------------------------------
-- Common functions.
-- ----------------------------------------------------------------------------------------
-- Goto menu function.
local function GotoMenu()
	composer.gotoScene("menu", { time = 800, effect="crossFade"} )
end -- GotoMenu.

-- Load scores.
local function LoadScores()
	
	local file = io.open( filePath, "r")
	
	if file then
		local contents = file:read("*a")
		io.close( file )
		scoresTable = json.decode( contents )
	end
	
	if ( scoresTable == nil or #scoresTable == 0) then 
		scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
end -- LoadScores.

-- Save scores.
local function SaveScores()
	
	for i = #scoresTable, 11, -1 do
		table.remove(scoresTable, i)
	end
	
	local file = io.open( filePath, "w")
	
	if file then
		file:write ( json. encode( scoresTable ) )
		io.close( file )
	end
end -- SaveScores.
-- ----------------------------------------------------------------------------------------
-- Scene event functions.
-- ----------------------------------------------------------------------------------------

-- Occurs when the scene is first created but has not yet appeared on screen.
function scene:create( event )

	local sceneGroup = self.view
	
	-- Load the previous scores.
	LoadScores()
	
	-- Insert the saved score from the last game into the table, then reset it.
	table.insert( scoresTable, composer.getVariable("finalScore"))
	composer.setVariable("finalScore",  0)
	
	-- Sort the table entries from highest to lowest.
	local function compare( a, b )
		return a > b
	end
	
	table.sort( scoresTable, compare)
	
	-- Save the scores.
    SaveScores()
	
	local background = display.newImage(sceneGroup, "res/img/paralax_space2.png")
    background.x = display.contentCenterX
    background.y = display.contentCenterY
	
	local highScoresHeader = display.newText(sceneGroup, "High Scores",  display.contentCenterX, 20, native.systemFont, 36 )
	
	for i = 1, 10 do
		if( scoresTable[i]) then
			local yPos = highScoresHeader.y  + ( i * 36)
			
			local rankNum = display.newText ( sceneGroup, i .. ")", display.contentCenterX - 15, yPos, native.systemFont, 15)
			--rankNum:setFillColor( 0.0 )
			rankNum.anchorX = 1
			
			local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX + 10 , yPos, native.systemFont, 15)
			thisScore.anchorX = 0
		end
	end
	
	local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX, display.contentCenterY + 200, native.systemFont, 36)
	menuButton: setFillColor( 0.75, 0.78, 1)
	menuButton:addEventListener("tap", GotoMenu )
end -- create.

-- Occurs twice, immediately before and immediately after the scene appears on screen.
function scene:show( event )
	
	local sceneGroup = self.view
	local phase = event.phase
	
	if( phase == "will" )  then
	
	elseif( phase == "did" ) then
		
	end
	
end -- show.

-- Occurs twice, immediately before and immediately after the scene exits the screen.
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase
	
	if( phase == "will" )  then
	
	elseif( phase == "did" ) then
		composer.removeScene( "highscores" )
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