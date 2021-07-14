--[[
	Container component for rendering the points on the cage mesh. This
	component does not receive any props from its parent.
]]


local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Constants = require(Plugin.Src.Util.Constants)

local Point = require(Plugin.Src.Components.PointTool.Point)

local SelectRbfPoint = require(Plugin.Src.Thunks.SelectRbfPoint)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local TableUtil = require(Plugin.Src.Util.TableUtil)
local ModelUtil = require(Plugin.Src.Util.ModelUtil)

local Workspace = game.Workspace

local PointTool = Roact.PureComponent:extend("PointTool")

function PointTool:isHovered(deformer, pointIndex)
	local hoveredPoint = self.props.HoveredPoint
	return hoveredPoint ~= nil and hoveredPoint.Deformer == deformer and hoveredPoint.Index == pointIndex
end

function PointTool:isSelected(deformer, pointIndex)
	local selectedPoints = self.props.SelectedPoints
	if selectedPoints[deformer] then
		if selectedPoints[deformer][pointIndex] then
			return true
		end
	end
	return false
end

local function checkPointVisited(self, deformer, index)
	return self.markedSeamPoints[deformer] and self.markedSeamPoints[deformer][index]
end

local function visitPoint(self, cage, deformer, index)
	local seamData = self.props.SeamData

	local linkedPoints = seamData[cage] and seamData[cage][deformer] and seamData[cage][deformer][index]
	if linkedPoints then
		for _, linkPoint in ipairs(linkedPoints) do
			TableUtil:setNested(self.markedSeamPoints, {linkPoint.Deformer, linkPoint.Index}, true)
		end
	end
	TableUtil:setNested(self.markedSeamPoints, {deformer, index}, true)
end

function PointTool:renderPointClickDetector(position)
	local theme = self.props.Stylizer

	return Roact.createElement("Part", {
		Position = position,
		Size = Vector3.new(theme.DefaultPointSize, theme.DefaultPointSize, theme.DefaultPointSize),
		Transparency = 1,
		CanCollide = false,
		Archivable = false,
	}, {
		[Constants.LCE_POINT_TAG] = Roact.createElement("BoolValue", {
			Archivable = false,
		}),
	})
end

function PointTool:renderPointDisplay(position, adornee, selected, deformer, index)
	local props = self.props

	local selectedPoints = props.SelectedPoints
	local editingCage = props.EditingCage
	local transparency = ModelUtil.transparencyFromLCEditorToProperty(props.CagesTransparency[editingCage])

	return Roact.createElement(Point, {
		Position = position,
		Adornee = adornee,
		Selected = selected,
		Weight = selected and selectedPoints[deformer][index],
		Hovered = self:isHovered(deformer, index),
		Transparency = transparency
	})
end

function PointTool:renderPoints()
	local props = self.props

	local pointData = props.PointData
	local editingCage = props.EditingCage

	local deformers = {}
	local displayPoints = {}

	self.markedSeamPoints = {}
	if editingCage and pointData and pointData[editingCage] then
		for deformer, pointsPerDeformer in pairs(pointData[editingCage]) do
			local pointsClickDetectors = {}
			for pointIndex, point in pairs(pointsPerDeformer) do
				if not checkPointVisited(self, deformer, pointIndex) then
					visitPoint(self, editingCage, deformer, pointIndex)

					local selected = self:isSelected(deformer, pointIndex)
					local adornee = ModelUtil:getPartFromDeformer(deformer)
					local partCFrame = ModelUtil:getPartCFrame(deformer, editingCage)

					local pointWorld = partCFrame * point.Position
					local pointRelativeToAdornee = adornee.CFrame:inverse() * pointWorld

					pointsClickDetectors[pointIndex] = self:renderPointClickDetector(pointWorld)
					table.insert(displayPoints, self:renderPointDisplay(pointRelativeToAdornee, adornee, selected, deformer, pointIndex))
				end
			end
			deformers[deformer] = Roact.createElement("Folder", {
				Archivable = false,
			}, pointsClickDetectors)
		end
	end

	return deformers, displayPoints
end

function PointTool:render()
	local pointClickDetectors, displayPoints = self:renderPoints()

	return Roact.createFragment({
		PointClickDetectors = Roact.createElement(Roact.Portal, {
			target = Workspace,
		}, {
			RbfPoints = Roact.createElement("Folder", {
				Archivable = false,
			}, pointClickDetectors),
		}),

		PointDisplay = Roact.createElement(Roact.Portal, {
			target = game:GetService("CoreGui"),
		}, {
			DisplayPoints = Roact.createElement("Folder", {
				Archivable = false,
			}, displayPoints),
		}),
	})
end

ContextServices.mapToProps(PointTool,{
	Stylizer = ContextServices.Stylizer,
})

local function mapStateToProps(state, props)
    local pointTool = state.pointTool
    local cageData = state.cageData
    local status = state.status
    local selectItem = state.selectItem

	return {
		SelectedPoints = pointTool.selectedPoints,
		HoveredPoint = status.hoveredPoint,
		PointData = cageData.pointData,
		PolyData = cageData.polyData,
		SeamData = cageData.seamData,
		ToolMode = status.toolMode,
		EditingCage = selectItem.editingCage,
		CagesTransparency = selectItem.cagesTransparency,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SelectRbfPoint = function(deformer, pointIndex, multiselect)
			dispatch(SelectRbfPoint(deformer, pointIndex, multiselect))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(PointTool)