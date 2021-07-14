--[[
	Very light wrapper around DevFramework RadioButtonList that gives it a header title.

	Required Props:
		string Title: text for the header of the list.
		table Buttons: A list of buttons to display. Example: { Key = "", Text = "", Disabled = false }.
		callback OnClick: parameters(string key). Fires when the button is activated and returns back the Key.
	Optional Props:
		number LayoutOrder: Render order of this component in a layout
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local UI = Framework.UI
local TextLabel = UI.Decoration.TextLabel
local RadioButtonList = UI.RadioButtonList
local Pane = UI.Pane

local Util = Framework.Util
local LayoutOrderIterator = Util.LayoutOrderIterator
local Typecheck = Util.Typecheck

local LCERadioButtonList = Roact.PureComponent:extend("LCERadioButtonList")

Typecheck.wrap(LCERadioButtonList, script)

function LCERadioButtonList:render()
	local props = self.props

	local title = props.Title
	local buttons = props.Buttons
	local onClick = props.OnClick
	local layoutOrder = props.LayoutOrder
	local theme = props.Stylizer

	local orderIterator = LayoutOrderIterator.new()

	return Roact.createElement(Pane, {
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = layoutOrder,
		Layout = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Spacing = theme.HeaderPadding,
	}, {
		Title = Roact.createElement(TextLabel, {
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Size = UDim2.new(1, 0, 0, 24),
			Text = title,
			Font = theme.FontBold,
			LayoutOrder = orderIterator:getNextOrder(),
		}),

		List = Roact.createElement(RadioButtonList, {
			Buttons = buttons,
			OnClick = onClick,
			LayoutOrder = orderIterator:getNextOrder(),
		}),
	})
end

ContextServices.mapToProps(LCERadioButtonList, {
	Stylizer = ContextServices.Stylizer,
})

return LCERadioButtonList