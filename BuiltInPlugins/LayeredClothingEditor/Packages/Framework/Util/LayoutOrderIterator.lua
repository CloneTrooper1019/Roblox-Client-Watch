--[[
	A simple counting utility that dynamically generates an index.
	So when adding or removing elements from components organized by LayoutOrder,
	you no longer need to update the indices.

	Example:
		function Foo:render()
			local orderItr = LayoutOrderIterator.new()
			return Roact.createElement("Frame", {}, {
				Layout = Roact.createElement("UIListLayout"),
				Part1 = Roact.createElement(..., {
					...
					LayoutOrder = orderItr:getNextOrder(),
					...
				}),
				Part2 = Roact.createElement(..., {
					...
					LayoutOrder = orderItr:getNextOrder(),
					...
				}),
			})
		end
]]
local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")

local LayoutOrderIterator = {}
LayoutOrderIterator.__index = LayoutOrderIterator

function LayoutOrderIterator.new(start)
	local self = setmetatable({}, LayoutOrderIterator)

	if FFlagLuobuDevPublishLua then
		self.order = start or 0
	else
		self.order = 0
	end

	return self
end

function LayoutOrderIterator:getNextOrder()
	self.order = self.order + 1
	return self.order
end

return LayoutOrderIterator