--[[
	Frame for any settings related to Lattice Tool

	Required Props:
		UDim2 Size: size of the frame
		callback SetSubdivisions: function to call to set subdivision data for a lattice, provided by mapDispatchToProps
		callback SetSelectedLattice: function to set the selected lattice, provided by mapDispatchToProps
		table Localization: A Localization ContextItem, which is provided via mapToProps.
		Plugin Plugin: A Plugin ContextItem, which is provided via mapToProps.
		table Signals: A Signals ContextItem, which is provided via mapToProps.
		table EditingItemContext: An EditingItemContext, which is provided via mapToProps.
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		string SelectedLattice: lattice currently selected in the editor, provided via mapToProps
		table Subdivisions: subdivision data for each lattice, provided by mapStateToProps
		EnumItem EditingCage: which cage on the model is currently being edited, provided by mapStateToProps
		number LayoutOrder: render order of component in layout
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)

local Vector3Entry = require(Plugin.Src.Components.Vector3Entry)
local CheckboxSetting = require(Plugin.Src.Components.CheckboxSetting)
local DeformerDropdownMenu = require(Plugin.Src.Components.DeformerDropdownMenu)
local ShowDialog = require(Plugin.Src.Util.ShowDialog)
local ConfirmCancelDialog = require(Plugin.Src.Components.ConfirmCancelDialog)

local SetSelectedLattice = require(Plugin.Src.Actions.SetSelectedLattice)
local SetSubdivisions = require(Plugin.Src.Thunks.SetSubdivisions)

local SignalsContext = require(Plugin.Src.Context.Signals)
local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)
local Constants = require(Plugin.Src.Util.Constants)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local Button = Framework.UI.Button
local Pane = Framework.UI.Pane

local Util = Framework.Util
local StyleModifier = Util.StyleModifier
local LayoutOrderIterator = Util.LayoutOrderIterator

local LatticeToolSettings = Roact.PureComponent:extend("LatticeToolSettings")

function LatticeToolSettings:init()
	self.state = {
		vectorValue = nil,
		validVector = true,
		useLocalAlignment = true,
	}

	self.onVectorValueChanged = function(value)
		if value then
			self:setState({
				vectorValue = value,
				validVector = true,
			})
		else
			self:setState({
				validVector = false,
			})
		end
	end

	self.onDeformerSelected = function(deformer)
		self.props.SetSelectedLattice(deformer)
	end

	self.onGenerateClicked = function()
		if self.state.vectorValue ~= nil and self.props.SelectedLattice ~= nil and self.state.validVector then
			ShowDialog(self.props.Plugin, self.props.Localization, ConfirmCancelDialog, {
				Text = self.props.Localization:getText("LatticeTool","GenerateMessageBoxText"),
				OnConfirm = function()
					self.props.SetSubdivisions(self.state.vectorValue, self.props.SelectedLattice, self.props.EditingCage, self.state.useLocalAlignment)
					self.props.Signals:get(Constants.SIGNAL_KEYS.SelectionChanged):Fire()
				end,
			})
		end
	end

	self.onLocalAlignmentChecked = function()
		self:setState({
			useLocalAlignment = not self.state.useLocalAlignment
		})
	end
end

function LatticeToolSettings:updateSubdivisions()
	if self.props.EditingCage and self.props.SelectedLattice then
		self:setState({
			vectorValue = self.props.Subdivisions[self.props.EditingCage][self.props.SelectedLattice] or Roact.None,
		})
	end
end

function LatticeToolSettings:didMount()
	self:updateSubdivisions()
end

function LatticeToolSettings:didUpdate(previousProps, previousState)
	if previousProps.EditingCage ~= self.props.EditingCage or previousProps.SelectedLattice ~= self.props.SelectedLattice then
		self:updateSubdivisions()
	end
end

function LatticeToolSettings:render()
	local props = self.props
	local state = self.state

	local size = props.Size
	local layoutOrder = props.LayoutOrder
	local selectedLattice = props.SelectedLattice or ""
	local editingItem = props.EditingItemContext:getItem()

	local vectorValue = state.vectorValue
	local validVector = state.validVector
	local useLocalAlignment = state.useLocalAlignment

	local isClothes = ItemCharacteristics.isClothes(editingItem)

	local localization = props.Localization
	local theme = props.Stylizer

	local orderIterator = LayoutOrderIterator.new()

	local subdivisionsEnabled = selectedLattice ~= ""
	local buttonEnabled = vectorValue ~= nil and subdivisionsEnabled and validVector

	return Roact.createElement(Pane, {
		LayoutOrder = layoutOrder,
		Size = size,
		Layout = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Spacing = theme.LayoutPadding,
		Padding = {
			Top = theme.MainPadding,
			Left = theme.MainPadding,
			Right = theme.MainPadding,
		}
	}, {
		DropdownMenu = not isClothes and Roact.createElement(DeformerDropdownMenu, {
			Size = UDim2.new(1, 0, 0, theme.Height),
			LayoutOrder = orderIterator:getNextOrder(),
			Deformer = selectedLattice,
			OnDeformerSelected = self.onDeformerSelected,
		}),

		Subdivisions = Roact.createElement(Vector3Entry, {
			Enabled = subdivisionsEnabled,
			Title = localization:getText("ToolSettings", "Subdivisions"),
			Size = UDim2.new(1, 0, 0, theme.Height),
			VectorValue = vectorValue,
			LayoutOrder = orderIterator:getNextOrder(),
			OnVectorValueChanged = self.onVectorValueChanged,
		}),

		LocalAlignmentCheckbox = Roact.createElement(CheckboxSetting, {
			Enabled = buttonEnabled,
			Title = localization:getText("ToolSettings", "LocalAlignment"),
			Size = UDim2.new(1, 0, 0, theme.Height),
			LayoutOrder = orderIterator:getNextOrder(),
			Selected = useLocalAlignment,
			OnToggle = self.onLocalAlignmentChecked,
		}),

		GenerateButtonContainer = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, theme.Height),
			LayoutOrder = orderIterator:getNextOrder(),
		}, {
			GenerateButton = Roact.createElement(Button, {
				Text = localization:getText("ToolSettings", "Generate"),
				Style = "Round",
				StyleModifier = not buttonEnabled and StyleModifier.Disabled or nil,
				Size = UDim2.new(0, theme.ButtonWidth, 0, theme.Height),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				OnClick = self.onGenerateClicked,
			})
		}),
	})
end

ContextServices.mapToProps(LatticeToolSettings,{
	Plugin = ContextServices.Plugin,
	Stylizer = ContextServices.Stylizer,
	Localization = ContextServices.Localization,
	Signals = SignalsContext,
	EditingItemContext = EditingItemContext,
})

local function mapStateToProps(state, props)
	local latticeTool = state.latticeTool
	local selectItem = state.selectItem

	return {
		SelectedLattice = latticeTool.selectedLattice,
		Subdivisions = latticeTool.subdivisions,
		EditingCage = selectItem.editingCage,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SetSubdivisions = function(subdivisions, deformer, cage, localAlignment)
			dispatch(SetSubdivisions(subdivisions, deformer, cage, localAlignment))
		end,
		SetSelectedLattice = function(selectedLattice)
			dispatch(SetSelectedLattice(selectedLattice))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(LatticeToolSettings)