--[[
	Mouse helper functions
]]

local Mouse = {}

function Mouse.onEnter(pluginMouse, iconName)
	if pluginMouse then
		pluginMouse.Icon = iconName and "rbxasset://SystemCursors/" .. iconName or "rbxasset://SystemCursors/PointingHand"
	end
end

function Mouse.onLeave(pluginMouse)
	if pluginMouse then
		pluginMouse.Icon = "rbxasset://SystemCursors/Arrow"
	end
end

return Mouse