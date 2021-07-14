local VirtualInputUtils = require(script.Parent.Parent.VirtualInputUtils)

local VirtualInputManager = game:GetService("VirtualInputManager")

local Keyboard = {}

function Keyboard.SendKeyEvent(isPressed, keyCode, isRepeated)
	VirtualInputManager:SendKeyEvent(isPressed, keyCode, isRepeated, VirtualInputUtils.getCurrentWindow())
end

function Keyboard.pressKey(keyCode)
	Keyboard.SendKeyEvent(true, keyCode, false)
end

function Keyboard.releaseKey(keyCode)
	Keyboard.SendKeyEvent(false, keyCode, false)
end

function Keyboard.hitKey(keyCode)
	Keyboard.pressKey(keyCode)
	Keyboard.releaseKey(keyCode)
end

return Keyboard