--[[
	This is a button component styled to represent toggling a tree view for Asset Preview

	Necessary properties:
	Position = UDim2
	ZIndex = number,
	ShowTreeView = boolean, represents whether or not the button is selected.
	OnTreeviewStatusToggle = callback, this is thefunction that should be invoked by this button.

	Optionlal properties:
	Size = number, This is the length and width of the button.
]]

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local RoundButton = require(Library.Components.RoundFrame)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local MainViewButtons = Roact.PureComponent:extend("MainViewButtons")

-- Determined by how many buttons we have and the padding.
local TOTAL_WIDTH = 28
local TOTAL_HEIGHT = 28

local INLINE_PADDING = 6

local BUTTON_STATUS = {
	default = 0,
	hovered = 1,
	disabled = 2,
}

function MainViewButtons:init(props)
	self.state = {
		treeViewButtonStatus = BUTTON_STATUS.default,
	}

	self.onTreeViewButtonActivated = function()
		local newTreeViewStatus = not self.props.ShowTreeView

		self.props.OnTreeviewStatusToggle(newTreeViewStatus)
	end

	self.onTreeViewButtonEnter = function()
		self:setState({
			treeViewButtonStatus = BUTTON_STATUS.hovered
		})
	end

	self.onTreeViewButtonLeave = function()
		self:setState({
			treeViewButtonStatus = BUTTON_STATUS.default
		})
	end
end

local function getButtonBGColorAndTrans(buttonsTheme, buttonStatus, toggleStatus)
	local buttonBGColor
	local buttonTrans

	local defaultTrans = buttonsTheme.backgroundTrans
	if toggleStatus then
		defaultTrans = defaultTrans + 0.3
	end

	if buttonStatus == BUTTON_STATUS.default then
		buttonBGColor = buttonsTheme.backgroundColor
		buttonTrans = defaultTrans
	elseif buttonStatus == BUTTON_STATUS.hovered then
		buttonBGColor = buttonsTheme.backgroundColor
		buttonTrans = defaultTrans + 0.3
	else -- BUTTON_STATUS.disabled
		buttonBGColor = buttonsTheme.backgroundDisabledColor
		buttonTrans = defaultTrans
	end

	return buttonBGColor, buttonTrans
end

function MainViewButtons:render()
	return withTheme(function(theme)
		local props = self.props
		local state = self.state

		local buttonsTheme = theme.assetPreview.treeViewButton

		local position = props.Position or UDim2.new(1, 0, 1, 0)
		local treeViewButtonSize = props.TreeViewButtonSize or buttonsTheme.buttonSize

		local treeViewButtonBGColor, treeViewbButtonTrans = getButtonBGColorAndTrans(buttonsTheme,
				state.treeViewButtonStatus,
				props.showTreeView)

		return Roact.createElement("Frame", {
			Position = position,
			AnchorPoint = Vector2.new(1, 1),
			Size = UDim2.new(0, TOTAL_WIDTH, 0, TOTAL_HEIGHT),
			ZIndex = props.ZIndex or 1,

			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		},{
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,

				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, INLINE_PADDING),
			}),

			TreeViewBGButton = Roact.createElement(RoundButton, {
				Size = UDim2.new(0, treeViewButtonSize, 0, treeViewButtonSize),

				BackgroundTransparency = treeViewbButtonTrans,
				BackgroundColor3 = treeViewButtonBGColor,
				BorderSizePixel = 0,

				LayoutOrder = 1,
				AutoButtonColor = false,

				OnActivated = self.onTreeViewButtonActivated,
				OnMouseEnter = self.onTreeViewButtonEnter,
				OnMouseLeave = self.onTreeViewButtonLeave,
			}, {
				TreeViewImageLabel = Roact.createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 16, 0, 16),

					Image = buttonsTheme.hierarchy,
					BackgroundTransparency = 1,
				})
			}),
		})
	end)
end

return MainViewButtons