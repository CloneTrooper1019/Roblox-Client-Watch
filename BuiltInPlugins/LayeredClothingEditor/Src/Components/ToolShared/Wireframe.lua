--[[
	Uses cage mesh vertex data to render a wireframe out of LineHandleAdornments. This
	component does not receive any props from its parent.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local ControlPointLink = require(Plugin.Src.Components.ToolShared.ControlPointLink)

local ModelUtil = require(Plugin.Src.Util.ModelUtil)

local CoreGui = game:GetService("CoreGui")

local Wireframe = Roact.PureComponent:extend("Wireframe")

function Wireframe:renderLinks()
	local props = self.props

	local pointData = props.PointData
	local polyData = props.PolyData
	local editingCage = props.EditingCage
	local theme = props.Stylizer

	local transparency = ModelUtil.transparencyFromLCEditorToProperty(props.CagesTransparency[editingCage])
	local wireColor = editingCage == Enum.CageType.Outer and theme.WireColorOuter or theme.WireColorInner

	local adorns = {}

	if editingCage and polyData and pointData and pointData[editingCage] and polyData[editingCage] then
		for deformer, facesPerDeformer in pairs(polyData[editingCage]) do
			for _, poly in pairs(facesPerDeformer) do
				local adornee = ModelUtil:getPartFromDeformer(deformer)
				local partCFrame = ModelUtil:getPartCFrame(deformer, editingCage)
				local toWorld = adornee.CFrame:inverse() * partCFrame
				table.insert(adorns, Roact.createElement(ControlPointLink, {
					Adornee = adornee,
					StartPoint = toWorld * pointData[editingCage][deformer][poly[1]].Position,
					EndPoint = toWorld * pointData[editingCage][deformer][poly[2]].Position,
					Transparency = transparency,
					Color = wireColor,
				}))

				table.insert(adorns, Roact.createElement(ControlPointLink, {
					Adornee = adornee,
					StartPoint = toWorld * pointData[editingCage][deformer][poly[2]].Position,
					EndPoint = toWorld * pointData[editingCage][deformer][poly[3]].Position,
					Transparency = transparency,
					Color = wireColor,
				}))

				table.insert(adorns, Roact.createElement(ControlPointLink, {
					Adornee = adornee,
					StartPoint = toWorld * pointData[editingCage][deformer][poly[3]].Position,
					EndPoint = toWorld * pointData[editingCage][deformer][poly[1]].Position,
					Transparency = transparency,
					Color = wireColor,
				}))
			end
		end
	end

	return adorns
end

function Wireframe:render()
	local adorns = self:renderLinks()

	return Roact.createElement(Roact.Portal, {
		target = CoreGui,
	}, {
		AdornLinks = Roact.createElement("Folder", {
			Archivable = false,
		}, adorns),
	})
end

ContextServices.mapToProps(Wireframe,{
	Stylizer = ContextServices.Stylizer,
})

local function mapStateToProps(state, props)
    local cageData = state.cageData
    local selectItem = state.selectItem

	return {
		PointData = cageData.pointData,
		PolyData = cageData.polyData,
		EditingCage = selectItem.editingCage,
		CagesTransparency = selectItem.cagesTransparency,
	}
end

return RoactRodux.connect(mapStateToProps, nil)(Wireframe)