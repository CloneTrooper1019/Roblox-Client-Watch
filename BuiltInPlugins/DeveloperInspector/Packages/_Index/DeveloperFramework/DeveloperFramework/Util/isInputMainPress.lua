--[[
	Return true if the input type is a left-mouse click, touch, or gamepad "X"
]]
local function isInputMainPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
		or  input.UserInputType == Enum.UserInputType.Gamepad1
end

return isInputMainPress
