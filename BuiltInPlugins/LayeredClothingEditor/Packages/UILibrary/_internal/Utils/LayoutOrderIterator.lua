--[[
    LayoutOrderIterator
    Dynamically generates the "LayoutOrder = ..." so LayoutOrder for all elements 
    does not need to be adjusted when adding or removing elements.
    
    e.g.
    local orderIterator = LayoutOrderIterator.new()
    ...
    Part1 = Roact.createElement(..., {
        ...
        LayoutOrder = orderIterator:getNextOrder(),
        ...
    }),
    Part2 = Roact.createElement(..., {
        ...
        LayoutOrder = orderIterator:getNextOrder(),
        ...
    }),
]]

local LayoutOrderIterator = {}
LayoutOrderIterator.__index = LayoutOrderIterator

function LayoutOrderIterator.new()
    local self = setmetatable({}, LayoutOrderIterator)

    self.order = 0

    return self
end

function LayoutOrderIterator:getNextOrder()
    self.order = self.order + 1
    return self.order
end

return LayoutOrderIterator