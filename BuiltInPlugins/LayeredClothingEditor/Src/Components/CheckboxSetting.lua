--[[
	Formatted checkbox with a title to the left.

	Required Props:
		string Title: label text to the left of the input boxes
		UDim2 Size: size of the frame
		boolean Enabled: whether or not the input boxes are interactable
		boolean Selected: if the checkbox is in a checked state
		number LayoutOrder: sort order of frame in a layout
		callback OnToggle: function to be called when checkbox is clicked.
	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local UI = Framework.UI
local ToggleButton = UI.ToggleButton
local TextLabel = UI.Decoration.TextLabel
local Pane = UI.Pane

local StringUtil = require(Plugin.Src.Util.StringUtil)

local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator
local Typecheck = Util.Typecheck

local CheckboxSetting = Roact.PureComponent:extend("CheckboxSetting")
Typecheck.wrap(CheckboxSetting, script)

function CheckboxSetting:render()
	local props = self.props

	local size = props.Size
	local layoutOrder = props.LayoutOrder
	local title = props.Title
	local enabled = props.Enabled
	local selected = props.Selected
	local onToggle = props.OnToggle

	local theme = props.Stylizer

	local orderIterator = LayoutOrderIterator.new()

	local textWidth = StringUtil.getTextWidth(title, theme.TextSize, theme.Font)

	return Roact.createElement(Pane, {
		Size = size,
		LayoutOrder = layoutOrder,
		Layout = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Spacing = theme.FramePadding,
	}, {
		Label = Roact.createElement(TextLabel, {
			Text = title,
			Size = UDim2.new(0, textWidth, 1, 0),
			LayoutOrder = orderIterator:getNextOrder(),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		CheckboxContainer = Roact.createElement(Pane, {
			Size = UDim2.new(1, -textWidth, 1, 0),
			LayoutOrder = orderIterator:getNextOrder(),
			Layout = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = {Right = theme.FramePadding}
		}, {
			CheckboxToggle = Roact.createElement(ToggleButton, {
				Disabled = not enabled,
				Selected = selected,
				OnClick = onToggle,
				Size = theme.BoxSize,
			}),
		}),
	})
end

ContextServices.mapToProps(CheckboxSetting,{
	Stylizer = ContextServices.Stylizer,
})

return CheckboxSetting