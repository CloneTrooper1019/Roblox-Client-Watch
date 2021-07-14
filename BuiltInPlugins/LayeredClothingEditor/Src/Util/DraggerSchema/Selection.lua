local Plugin = script.Parent.Parent.Parent.Parent

local Constants = require(Plugin.Src.Util.Constants)
local Framework = require(Plugin.Packages.Framework)
local deepCopy = Framework.Util.deepCopy

local Selection = {}
Selection.__index = Selection

function Selection.new(selectionChangedSignal)
	local self = setmetatable({}, Selection)

	self.SelectionChanged = selectionChangedSignal

	return self
end

function Selection:Set(objects)
	if self.toolMode == Constants.TOOL_MODE.Point then
		self.selectRbfPoint(objects)
	elseif self.toolMode == Constants.TOOL_MODE.Lattice then
		self.setSelectedControlPoints(objects)
	end
end

function Selection:Get()
	if self.toolMode == Constants.TOOL_MODE.Point then
		return deepCopy(self.clickedPoints)
	elseif self.toolMode == Constants.TOOL_MODE.Lattice then
		return deepCopy(self.selectedControlPoints)
	end

	return {}
end

function Selection:GetActiveInstance()
	return nil
end

return Selection
