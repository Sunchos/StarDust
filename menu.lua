
local composer = require( "composer" )
-- Create new scene.
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- The function which tells Composer to move to the game scene.
local function gotoGame()
	composer.gotoScene( "game" , { time=800, effect="crossFade" })
end -- gotoGame.

-- The function which tells Composer to move to the game scene.
local function gotoHighScores()
	composer.gotoScene( "highscores", { time=800, effect="crossFade" })
end -- gotoHighScore.

-- The function which tells Composer to move to the game scene.
local function gotoSettings()
	composer.gotoScene( "settings", { time=800, effect="crossFade" })
end -- gotoSettings.

-- ----------------------------------------------------------------------------------------
-- Scene event functions.
-- ----------------------------------------------------------------------------------------

-- Occurs when the scene is first created but has not yet appeared on screen.
function scene:create( event )
	local sceneGroup = self.view
	
	local background = display.newImage(sceneGroup, "res/img/paralax_space2.png")
	background.x = display.contentCenteX
	background.y = display.contentCenteY

	local playButton = display.newText(sceneGroup, "Play", display.contentCenterX, display.contentCenterY - 80, native.systemFont, 40)
	playButton:setFillColor( 0.82, 0.86, 1)
	
	local highScoresButton = display.newText( sceneGroup, "High Scores", display.contentCenterX, display.contentCenterY , native.systemFont, 40)
	highScoresButton:setFillColor( 0.82, 0.86, 1)
	
	local settingsButton = display.newText( sceneGroup, "Settings", display.contentCenterX, display.contentCenterY + 80 , native.systemFont, 40)
	settingsButton:setFillColor( 0.82, 0.86, 1)
	
	playButton:addEventListener( "tap", gotoGame)
	highScoresButton:addEventListener("tap", gotoHighScores)
	settingsButton:addEventListener("tap", gotoSettings)
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