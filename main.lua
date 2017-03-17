-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

background = display.newImage("res/img/paralax_space2.png")
background.x = display.contentWidth
background.y = display.contentHeight

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