--[[
	Container component for rendering the lattices for each deformable part.
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local Cryo = require(Plugin.Packages.Cryo)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local Lattice = require(Plugin.Src.Components.LatticeTool.Lattice)

local SetSelectedLattice = require(Plugin.Src.Actions.SetSelectedLattice)

local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)

local Constants = require(Plugin.Src.Util.Constants)
local ModelUtil = require(Plugin.Src.Util.ModelUtil)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)

local Workspace = game.Workspace
local UserInputService = game:GetService("UserInputService")

local LatticeTool = Roact.PureComponent:extend("LatticeTool")

function LatticeTool:init()
	self.state = {
		hoveredLattice = nil,
	}

	self.proxyLatticeRootRef = Roact.createRef()

	self.onLatticeHoverStart = function(deformer)
		if not self.props.SelectedLattice then
			self:setState({
				hoveredLattice = deformer
			})
		end
	end

	self.onLatticeHoverEnd = function(deformer)
		if deformer == self.state.hoveredLattice and not self.props.SelectedLattice then
			self:setState({
				hoveredLattice = Roact.None
			})
		end
	end

	self.keyboardInputHandler = UserInputService.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Constants.KEY_SHORTCUTS.LockControl then
				if self.state.hoveredLattice and not self.props.SelectedLattice then
					self.props.SetSelectedLattice(self.state.hoveredLattice)
				elseif self.props.SelectedLattice then
					self.props.SetSelectedLattice(Cryo.None)
				end
			end
		end
	end)
end

function LatticeTool:didMount()
	local editingItem = self.props.EditingItemContext:getItem()
	if ItemCharacteristics.isClothes(editingItem) then
		local deformerToPartMap = ModelUtil:getDeformerToPartMap()
		local _, deformer = next(deformerToPartMap)
		if deformer then
			self.props.SetSelectedLattice(deformer.Name)
		end
	end
end

function LatticeTool:didUpdate(previousProps)
	if previousProps.SelectedLattice ~= self.props.SelectedLattice and self.props.SelectedLattice then
		self:setState({
			hoveredLattice = Roact.None
		})
	end
end

function LatticeTool:willUnmount()
	if self.keyboardInputHandler then
		self.keyboardInputHandler:disconnect()
	end
end

function LatticeTool:renderLattices()
	local props = self.props
	local state = self. state

	local latticeData = props.LatticeData
	local boundsData = props.BoundsData
	local selectedControlPoints = props.SelectedControlPoints
	local hoveredPoint = props.HoveredPoint
	local editingCage = props.EditingCage

	local hoveredLattice = state.hoveredLattice
	local selectedLattice = props.SelectedLattice

	local lattices = {}

	if boundsData then
		for deformer, bounds in pairs(boundsData[editingCage]) do
			lattices[deformer] = Roact.createElement(Lattice, {
				LatticeData = latticeData[editingCage],
				SelectedControlPoints = selectedControlPoints,
				HoveredPoint = hoveredPoint,
				Deformer = deformer,
				Bounds = bounds,
				Adornee = ModelUtil:getPartFromDeformer(deformer),
				AdorneeCageCFrame = ModelUtil:getPartCFrame(deformer, editingCage),
				Visible = hoveredLattice == deformer or selectedLattice == deformer,
				Selected = selectedLattice == deformer,
				OnLatticeHoverStart = self.onLatticeHoverStart,
				OnLatticeHoverEnd = self.onLatticeHoverEnd,
			})
		end
	end
	return lattices
end

function LatticeTool:render()
	local props = self.props

	local editingItem = props.EditingItemContext:getItem()

    return Roact.createElement(Roact.Portal, {
        target = Workspace
    }, {
		Lattices = Roact.createElement("Part", {
			Transparency = 1,
			CFrame = ModelUtil:getRootCFrame(editingItem),
			Archivable = false,
			[Roact.Ref] = self.proxyLatticeRootRef,
		}, self:renderLattices()),
    })
end

local function mapStateToProps(state, props)
	local latticeTool = state.latticeTool
	local status = state.status
	local selectItem = state.selectItem

	return {
		HoveredPoint = status.hoveredPoint,
		SelectedLattice = latticeTool.selectedLattice,
		BoundsData = latticeTool.latticeBoundsData,
		LatticeData = latticeTool.latticeData,
		SelectedControlPoints = status.selectedControlPoints,
		EditingCage = selectItem.editingCage,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SetSelectedLattice = function(selectedLattice)
			dispatch(SetSelectedLattice(selectedLattice))
		end,
	}
end

ContextServices.mapToProps(LatticeTool,{
	EditingItemContext = EditingItemContext,
})

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(LatticeTool)