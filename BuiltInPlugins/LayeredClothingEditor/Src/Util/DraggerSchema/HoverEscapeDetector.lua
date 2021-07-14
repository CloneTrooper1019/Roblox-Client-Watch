--[[
	class HoverEscapeDetector

	Constructed with a given selectable object and a given callback. Calls the
	callback whenever selectable object changes in some way that could make it
	no longer hovered thanks to factors external to the dragger (such as when
	it is deleted through a hotkey)
]]

local HoverEscapeDetector = {}
HoverEscapeDetector.__index = HoverEscapeDetector

function HoverEscapeDetector.new(draggerContext, hoveredItem, onEscaped)
	local self = setmetatable({
		_destroyed = false,
	}, HoverEscapeDetector)

	self._toolChangedConnection = draggerContext.ToolChangedSignal:Connect(function()
		onEscaped()
	end)

	return self
end

function HoverEscapeDetector:destroy()
	assert(not self._destroyed)
	self._toolChangedConnection:Disconnect()
	self._destroyed = true
end

return HoverEscapeDetector