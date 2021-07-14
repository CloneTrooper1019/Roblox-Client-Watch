--[[
	Titled dropdown for selecting a deformer.

	Props:
		UDim2 Size: size of the frame
		string Deformer: manual deformer selection if selected from an outside source
		number LayoutOrder: render order of component in layout
		table PointData: represents rbf points for each cage for the item being edited, provided via mapStateToProps
		table Localization: A Localization ContextItem, which is provided via mapToProps.
		callback OnDeformerSelected: callback for when user selects deformer from dropdown menu
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		EnumItem EditingCage: which cage on the model is currently being edited, provided by mapStateToProps
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local Cryo = require(Plugin.Packages.Cryo)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local UI = Framework.UI

local DropdownMenu = UI.DropdownMenu
local TextLabel = UI.Decoration.TextLabel
local Button = UI.Button
local Image = UI.Decoration.Image
local Pane = UI.Pane

local StringUtil = require(Plugin.Src.Util.StringUtil)

local DeformerDropdownMenu = Roact.PureComponent:extend("DeformerDropdownMenu")

local TARGET_KEY = "Target"

function DeformerDropdownMenu:getListItems()
	local props = self.props

	local pointData = props.PointData
	local editingCage = props.EditingCage

	if pointData[editingCage] then
		return Cryo.Dictionary.keys(pointData[editingCage])
	end

	return {}
end

function DeformerDropdownMenu:init()
	self.state = {
		menuOpen = false,
	}

	self.listItems = self:getListItems()

	self.selectItem = function(value, index)
		self:setState({
			menuOpen = false,
		})
		self.props.OnDeformerSelected(value)
	end

	self.closeMenu = function()
		self:setState({
			menuOpen = false,
		})
	end

	self.openMenu = function()
		self:setState({
			menuOpen = true,
		})
	end
end

function DeformerDropdownMenu:didUpdate(nextProps)
	if nextProps.EditingItem ~= self.props.EditingItem or
		nextProps.EditingCage ~= self.props.EditingCage then
		self.listItems = self:getListItems()
	end
end

local function getDeformerIndex(deformer, listItems)
	for index, item in ipairs(listItems) do
		if item == deformer then
			return index
		end
	end
end

function DeformerDropdownMenu:render()
	local props = self.props

	local size = props.Size
	local layoutOrder = props.LayoutOrder

	local deformer = props.Deformer
	local selectedIndex = getDeformerIndex(deformer, self.listItems) or nil

	local localization = props.Localization

	local theme = props.Stylizer

	local labelText = localization:getText("ToolSettings", TARGET_KEY)
	local textWidth = StringUtil.getTextWidth(labelText, theme.TextSize, theme.Font)

	return Roact.createElement(Pane, {
		Size = size,
		LayoutOrder = layoutOrder,
		Layout = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Spacing = theme.Padding,
	}, {
		Label = Roact.createElement(TextLabel, {
			Text = labelText,
			Size = UDim2.new(0, textWidth, 1, 0),
			LayoutOrder = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		Container = Roact.createElement(Pane, {
			Size = UDim2.new(1, -textWidth, 1, 0),
			LayoutOrder = 2,
			Layout = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Spacing = theme.DropdownFramePadding,
			Padding = {Right = theme.Padding},
		}, {
			DropdownFrame = Roact.createElement(Button, {
				Style = "Round",
				Size = UDim2.new(0, theme.DropdownFrameWidth, 0, theme.ArrowSize),
				OnClick = self.openMenu,
			}, {
				SelectedLabel = Roact.createElement(TextLabel, {
					Text = selectedIndex ~= nil and self.listItems[selectedIndex] or "",
					Position = UDim2.new(0, theme.DropdownFramePadding, 0, 0),
					Size = UDim2.new(1, -theme.ArrowSize - (theme.DropdownFramePadding * 2), 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				DownArrow = Roact.createElement(Image, {
					Style = theme,
				}),
				Menu = Roact.createElement(DropdownMenu, {
					Hide = not self.state.menuOpen,
					SelectedIndex = selectedIndex,
					Items = self.listItems,
					OnItemActivated = self.selectItem,
					OnFocusLost = self.closeMenu,
				}),
			}),
		}),
	})
end

ContextServices.mapToProps(DeformerDropdownMenu,{
	Stylizer = ContextServices.Stylizer,
	Localization = ContextServices.Localization,
})

local function mapStateToProps(state, props)
	local cageData = state.cageData
	local selectItem = state.selectItem

	return {
		PointData = cageData.pointData,
		EditingCage = selectItem.editingCage,
	}
end

local function mapDispatchToProps(dispatch)
	return {}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(DeformerDropdownMenu)