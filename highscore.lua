
local composer = require( "composer" )
-- Create new scene.
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------



-- ----------------------------------------------------------------------------------------
-- Scene event functions.
-- ----------------------------------------------------------------------------------------

-- Occurs when the scene is first created but has not yet appeared on screen.
function scene:create( event )

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