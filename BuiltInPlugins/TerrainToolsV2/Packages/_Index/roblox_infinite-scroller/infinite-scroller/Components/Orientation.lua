-- Enum for specifying the leading edge of the scroller.
local Root = script:FindFirstAncestor("infinite-scroller").Parent
local t = require(Root.t)

local Orientation = {
	Up = "Orientation.Up",
	Down = "Orientation.Down",
	Left = "Orientation.Left",
	Right = "Orientation.Right",
}

local metaindex = {
	isOrientation = t.union(
		t.literal(Orientation.Up),
		t.literal(Orientation.Down),
		t.literal(Orientation.Left),
		t.literal(Orientation.Right)
	)
}

setmetatable(Orientation, {
	__index = function(self, key)
		return metaindex[key] or
			error(tostring(key) .. " is not a valid member of Scroller.Orientation", 2)
	end,
	__newindex = function()
		error("Scroller.Orientation is read-only", 2)
	end,
})

return Orientation
