-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local score = 0
local lives = 5

background = display.newImage("res/img/paralax_space2.png")
background.x = display.contentWidth
background.y = display.contentHeight

local scoreText = display.newText("Score: " .. score, display.contentCenterX  - 100 ,  display.contentCenterY - 230 , native.systemFont, 20 )
local livesText = display.newText("Lives: " .. lives, display.contentCenterX + 100, display.contentCenterY - 230, native.systemFont, 20)

local centerRect = display.newImage("res/img/redShip.png")
centerRect.x = display.contentWidth / 2
centerRect.y = display.contentHeight / 2

function centerRect:touch(event)
	if event.phase == "began" then
		display.getCurrentStage():setFocus(self)
		self.isFocus = true
	elseif self.isFocus then
		if event.phase == "moved" then
			print("moved phase")
		elseif event.phase == "ended" or event.phase == "cancelled" then
			display.getCurrentStage():setFocus(nil)
			self.isFocus = false
		end
	end
	
		return true
end

centerRect:addEventListener("touch" , centerRect)