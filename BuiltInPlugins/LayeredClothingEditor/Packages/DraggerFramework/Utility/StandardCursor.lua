--[[
This file is a workaround for STUDIOCORE-22344

We would like to just use the system cursors for the draggers, however, due to
the above unresolved issue, the system cursors do not work in Play Solo mode.

To work around this, use the old set of dragger cursors instead while in Play
Solo mode.
]]

local RunService = game:GetService("RunService")

local StandardCursor = {}

local function isPlaySolo()
	return RunService:IsRunning() and not RunService:IsRunMode()
end

function StandardCursor.getArrow()
	if isPlaySolo() then
		return "rbxasset://textures/advCursor-default.png"
	else
		return "rbxasset://SystemCursors/Arrow"
	end
end

function StandardCursor.getOpenHand()
	if isPlaySolo() then
		return "rbxasset://textures/advCursor-openedHand.png"
	else
		return "rbxasset://SystemCursors/OpenHand"
	end
end

function StandardCursor.getClosedHand()
	if isPlaySolo() then
		return "rbxasset://textures/advClosed-hand.png"
	else
		return "rbxasset://SystemCursors/ClosedHand"
	end
end

return StandardCursor