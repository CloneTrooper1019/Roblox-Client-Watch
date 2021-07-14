local Plugin = script.Parent.Parent.Parent.Parent

local ModelUtil = require(Plugin.Src.Util.ModelUtil)
local ToolUtil = require(Plugin.Src.Util.ToolUtil)
local TableUtil = require(Plugin.Src.Util.TableUtil)

local Workspace = game:GetService("Workspace")

local SelectionInfo = {}
SelectionInfo.__index = SelectionInfo

local function computeBoundBoxPointMode(selection)
	local pointTable = {}
	local pointInstances = Workspace:FindFirstChild("RbfPoints")
	if pointInstances then
		for _, deformerFolder in ipairs(pointInstances:GetChildren()) do
			pointTable[deformerFolder.Name] = {}
			for _, vert in ipairs(deformerFolder:GetChildren()) do
				pointTable[deformerFolder.Name][tonumber(vert.Name)] = vert.CFrame.p
			end
		end
	end

	local points = {}
	for _, entry in pairs(selection) do
		table.insert(points, pointTable[entry.Deformer][entry.Index])
	end
	return ModelUtil:getBounds(points)
end

local function computeBoundBoxLatticeMode(selection)
	local pointTable = {}
	local pointInstances = Workspace:FindFirstChild("Lattices")
	if pointInstances then
		for _, deformerFolder in ipairs(pointInstances:GetChildren()) do
			pointTable[deformerFolder.Name] = {}
			for _, point in ipairs(deformerFolder:GetChildren()) do
				pointTable[deformerFolder.Name][point.Name] = point.CFrame.p
			end
		end
	end

	local points = {}
	for _, entry in pairs(selection) do
		table.insert(points, pointTable[entry.Deformer][entry.ID])
	end
	return ModelUtil:getBounds(points)
end

local function computeBoundingBox(context, selection)
	if ToolUtil:isDraggerPointMode(context) then
		return computeBoundBoxPointMode(selection)
	elseif ToolUtil:isDraggerLatticeMode(context) then
		return computeBoundBoxLatticeMode(selection)
	else
		return ModelUtil:getBounds({})
	end
end

local function buildPointSelection(selection)
	local selectionTable = {}
	for _, vert in pairs(selection) do
		TableUtil:setNested(selectionTable, {vert.Deformer, vert.Index}, vert.Index)
	end
	return selectionTable
end

local function buildSelectionTable(context, selection)
	local editingItem = context.editingItem
	local latticeBoundsData = context.latticeBoundsData
	local editingCage = context.editingCage
	local selectedLattice = context.selectedLattice

	if not editingItem or not editingCage then
		return {}
	end

	if ToolUtil:isDraggerPointMode(context) then
		return buildPointSelection(selection)
	elseif ToolUtil:isDraggerLatticeMode(context) then
		if latticeBoundsData and selectedLattice then
			return selection
		else
			return {}
		end
	end
end

function SelectionInfo.new(draggerContext, selection)
	return setmetatable({
		_draggerContext = draggerContext,
		_selection = buildSelectionTable(draggerContext, selection),
		_bounds = computeBoundingBox(draggerContext, selection),
	}, SelectionInfo)
end

function SelectionInfo:isEmpty()
	return self._selection == nil or next(self._selection) == nil
end

function SelectionInfo:getBoundingBox(empty)
	local editingItem = self._draggerContext.editingItem
	local latticeBoundsData = self._draggerContext.latticeBoundsData
	local editingCage = self._draggerContext.editingCage
	local selectedLattice = self._draggerContext.selectedLattice

	local rootCFrame = ModelUtil:getRootCFrame(editingItem)
	local selectionSize = Vector3.new(self._bounds.Width, self._bounds.Height, self._bounds.Depth)
	if self._draggerContext:shouldUseLocalSpace() then
		local rootRotOnly = rootCFrame - rootCFrame.p
		if ToolUtil:isDraggerPointMode(self._draggerContext) then
			return rootRotOnly + self._bounds.Center , Vector3.new(), selectionSize
		elseif ToolUtil:isDraggerLatticeMode(self._draggerContext) then
			local latticeBounds = latticeBoundsData[editingCage][selectedLattice]
			if latticeBounds then
				local boundsRotOnly = latticeBounds.CFrame - latticeBounds.CFrame.p
				return (rootRotOnly * boundsRotOnly) + self._bounds.Center, Vector3.new(), selectionSize
			else
				return CFrame.new(), Vector3.new(), Vector3.new()
			end
		else
			return CFrame.new(), Vector3.new(), Vector3.new()
		end
	else
		return CFrame.new() + self._bounds.Center, Vector3.new(), selectionSize
	end
end

function SelectionInfo:doesContainItem(item)
	if type(item) ~= "table" then
		return false
	end
	if ToolUtil:isDraggerPointMode(self._draggerContext) then
		return self._selection[item.Deformer] ~= nil and self._selection[item.Deformer][item.Index] ~= nil
	elseif ToolUtil:isDraggerLatticeMode(self._draggerContext) then
		return self._selection[item.Deformer] ~= nil and self._selection[item.Deformer][item.ID] ~= nil
	end
end

function SelectionInfo:getSelected()
	return self._selection
end

function SelectionInfo:isDynamic()
	return false
end

return SelectionInfo