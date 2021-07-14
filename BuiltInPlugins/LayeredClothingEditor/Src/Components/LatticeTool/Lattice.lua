--[[
	Component that renders a lattice drawn in 3D space. Each controllable lattice point is a
	BoxHandleAdornment while each connecting line between points in the lattice is a LineHandleAdornment.

	Props:
		table LatticeData: 3D grid data structure for each lattice point
		table SelectedControlPoints: lattice points that are selected
		table HoveredPoint: data about lattice point that is hovered by mouse
		string Deformer: Name of the wrap deformer for this lattice
		table Bounds: bounds of the vertices from the rbf point data for this deformer
		instance Adornee: the part this lattice is attached to
		CFrame AdorneeCageCFrame: CFrame of the adornee
		boolean Visible: is this lattice visible to the user
		boolean Selected: is this lattice selected to be edited by the user
		callback OnLatticeHoverStart = callback for when lattice volume is hovered by mouse
		callback OnLatticeHoverEnd: callback for when lattice volume is no longer hovered by mouse
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local ControlPoint = require(Plugin.Src.Components.ToolShared.ControlPoint)
local ControlPointLink = require(Plugin.Src.Components.ToolShared.ControlPointLink)

local Constants = require(Plugin.Src.Util.Constants)

local CoreGui = game:GetService("CoreGui")

local Lattice = Roact.PureComponent:extend("Lattice")

function Lattice:renderLinks(links, latticePoints)
	for yIndex, zLayers in pairs(latticePoints) do
		for zIndex, xLayers in pairs(zLayers) do
			for xIndex, latticePoint in pairs(xLayers) do
				local topPoint = (yIndex + 1 <= #latticePoints) and latticePoints[yIndex + 1][zIndex][xIndex] or nil
				local forwardPoint = (zIndex + 1 <= #zLayers) and latticePoints[yIndex][zIndex + 1][xIndex] or nil
				local rightPoint = (xIndex + 1 <= #xLayers) and latticePoints[yIndex][zIndex][xIndex + 1] or nil

				if topPoint then
					self:renderLink(links, latticePoint, topPoint)
				end

				if forwardPoint then
					self:renderLink(links, latticePoint, forwardPoint)
				end

				if rightPoint then
					self:renderLink(links, latticePoint, rightPoint)
				end
			end
		end
	end
end

function Lattice:renderLink(links, startPoint, endPoint)
	local props = self.props

	local theme = props.Stylizer

	local adornee = props.Adornee
	local toWorld = adornee.CFrame:inverse() * props.AdorneeCageCFrame
	links[startPoint.id .."_to_" ..endPoint.id] = Roact.createElement(ControlPointLink, {
		Adornee = adornee,
		StartPoint = toWorld * startPoint.position,
		EndPoint = toWorld * endPoint.position,
		Transparency = 0,
		Color = theme.LinkColor,
	})
end

function Lattice:isControlPointHovered(deformer, id)
	local hoveredPoint = self.props.HoveredPoint
	return hoveredPoint ~= nil and hoveredPoint.Deformer == deformer and hoveredPoint.ID == id
end

function Lattice:renderLattice()
	local props = self.props

	local latticeData = props.LatticeData
	local deformer = props.Deformer
	local selectedControlPoints = props.SelectedControlPoints
	local adornee = props.Adornee
	local adorneeCageCFrame = props.AdorneeCageCFrame

	if not adornee then
		return
	end

	local lattice = {}
	local links = {}

	local selected = {}
	for _, controlPoint in pairs(selectedControlPoints) do
		if deformer == controlPoint.Deformer then
			selected[controlPoint.ID] = true
		end
	end

	if latticeData and latticeData[deformer] then
		local latticePoints = latticeData[deformer].lattice
		for yIndex, zLayers in pairs(latticePoints) do
			for zIndex, xLayers in pairs(zLayers) do
				for xIndex, latticePoint in pairs(xLayers) do
					local id = latticePoint.id
					local position = latticePoint.position
					local gridPosition = Vector3.new(yIndex, zIndex, xIndex)
					lattice[id] = Roact.createElement(ControlPoint, {
						Position = adorneeCageCFrame * position,
						Selected = selected[id] or false,
						Hovered = self:isControlPointHovered(deformer, id),
					}, {
						[Constants.LCE_CONTROL_TAG] = Roact.createElement("Vector3Value", {
							Value = gridPosition,
							Archivable = false,
						})
					})
				end
			end
		end

		self:renderLinks(links, latticePoints)
	end

	return lattice, links
end

function Lattice:render()
	local props = self.props
	local deformer = props.Deformer
	local bounds = props.Bounds
	local visible = props.Visible
	local selected = props.Selected
	local adornee = props.Adornee

	local onLatticeHoverStart = props.OnLatticeHoverStart
	local onLatticeHoverEnd = props.OnLatticeHoverEnd

	local lattice, links = self:renderLattice()

	links = visible and links or {}

	local elements = {}
	elements["CollisionVolumePortal"] = Roact.createElement(Roact.Portal, {
        target = CoreGui
    }, {
		CollisionVolume = Roact.createElement("BoxHandleAdornment", {
			CFrame = bounds.CFrame,
			Size = Vector3.new(bounds.Width, bounds.Height, bounds.Depth),
			Adornee = adornee,
			Transparency = 1,
			Archivable = false,
			[Roact.Event.MouseEnter] = function() onLatticeHoverStart(deformer) end,
			[Roact.Event.MouseLeave] = onLatticeHoverEnd,
		}, links),
	})

	if visible and selected then
		elements[deformer] = Roact.createElement("Folder", {
			Archivable = false,
		}, lattice)
	end

	return Roact.createFragment(elements)
end

ContextServices.mapToProps(Lattice,{
	Stylizer = ContextServices.Stylizer,
})

return Lattice