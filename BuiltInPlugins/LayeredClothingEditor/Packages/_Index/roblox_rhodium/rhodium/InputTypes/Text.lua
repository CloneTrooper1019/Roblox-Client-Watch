local VirtualInputUtils = require(script.Parent.Parent.VirtualInputUtils)

local VirtualInputManager = game:GetService("VirtualInputManager")

local Text = {}

function Text.sendText(str)
	VirtualInputManager:sendTextInputCharacterEvent(str, VirtualInputUtils.getCurrentWindow())
end

return Text
