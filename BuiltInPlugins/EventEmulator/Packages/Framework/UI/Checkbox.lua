--[[
	A check button followed by an optional text label.

	Required Props:
		callback OnClick: The function that will be called when the button is clicked.

	Optional Props:
		any Checked: The check button state. Can be a boolean or the Indeterminate symbol.
		boolean Disabled: Whether or not this button can be clicked.
		string Key: The key that will be sent back to the OnClick function.
		number LayoutOrder: The layout order of this component.
		Style Style: The style with which to render this component.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		string Text: The text to display after the check button.
]]
local FFlagDevFrameworkPaneOnClick = game:GetFastFlag("DevFrameworkPaneOnClick")

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Button = require(Framework.UI.Button)
local Pane = require(Framework.UI.Pane)
local TextLabel = require(Framework.UI.TextLabel)

local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local StyleModifier = Util.StyleModifier
local Symbol = Util.Symbol
local Typecheck = Util.Typecheck

local Dash = require(Framework.packages.Dash)
local join = Dash.join

local Checkbox = Roact.PureComponent:extend("Checkbox")
Typecheck.wrap(Checkbox, script)

Checkbox.Indeterminate = Symbol.named("Indeterminate")

Checkbox.defaultProps = {
	Checked = false,
	Disabled = false,
	Key = "",
	OnClick = function() end,
}

function Checkbox:init()
	self.onClick = function()
		local isDisabled = self.props.Disabled
		local onClick = self.props.OnClick
		if not isDisabled and onClick then
			onClick(self.props.Key)
		end
	end
end

function Checkbox:render()
	local props = self.props

	local isChecked = props.Checked
	local isDisabled = props.Disabled
	local layoutOrder = props.LayoutOrder
	local text = props.Text or ""

	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		local theme = props.Theme
		style = theme:getStyle("Framework", self)
	end

	local styleModifier
	if isDisabled then
		styleModifier = StyleModifier.Disabled
	elseif isChecked == Checkbox.Indeterminate then
		styleModifier = StyleModifier.Indeterminate
	elseif isChecked then
		styleModifier = StyleModifier.Selected
	end

	local buttonProps = {
		OnClick = self.onClick,
		Size = style.ImageSize,
		Style = style.BackgroundStyle,
		StyleModifier = styleModifier,
	}

	local children = props[Roact.Children] or {}

	if text == "" then
		return Roact.createElement(Button, join(buttonProps, {
			LayoutOrder = layoutOrder,
		}), children)
	else
		if FFlagDevFrameworkPaneOnClick then
			children.Button = Roact.createElement(Button, join(buttonProps, {
				LayoutOrder = 1,
			}))
			children.Label = Roact.createElement(TextLabel, {
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				StyleModifier = styleModifier,
				Text = text,
			})
			return Roact.createElement(Pane, {
				AutomaticSize = Enum.AutomaticSize.XY,
				Layout = Enum.FillDirection.Horizontal,
				LayoutOrder = layoutOrder,
				OnClick = self.onClick,
				Spacing = style.Spacing,
			}, children)
		else
			children.Container = Roact.createElement(Pane, {
				Layout = Enum.FillDirection.Horizontal,
				Spacing = style.Spacing,
			}, {
				Button = Roact.createElement(Button, {
					LayoutOrder = 1,
					OnClick = self.onClick,
					Size = style.ImageSize,
					Style = style.BackgroundStyle,
					StyleModifier = styleModifier,
				}),
				Label = Roact.createElement(TextLabel, {
					AutomaticSize = Enum.AutomaticSize.XY,
					LayoutOrder = 2,
					StyleModifier = styleModifier,
					Text = text,
				})
			})

			return Roact.createElement("TextButton", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = layoutOrder,
				Text = "",
				[Roact.Event.Activated] = self.onClick,
			}, children)
		end
	end
end

ContextServices.mapToProps(Checkbox, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return Checkbox
