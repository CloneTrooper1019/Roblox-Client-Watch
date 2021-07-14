--[[
	A list of radio buttons that can be selected and shows text after a Background.
	This component only allows one radio button to be selected at a time.

	Required Props:
		table Buttons: A list of buttons to display. Example: { Key = "", Text = "", Disabled = false }.

	Optional Props:
		string SelectedKey: The initially selected key.
		number LayoutOrder: The layout order of the frame.
		Enum.FillDirection FillDirection: The direction in which buttons are filled.
		callback OnClick: paramters(string key). Fires when the button is activated and returns back the Key.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local RadioButton = require(Framework.UI.RadioButton)

local FitFrame = require(Framework.Util.FitFrame)
local FitFrameVertical = FitFrame.FitFrameVertical

local RadioButtonList = Roact.PureComponent:extend("RadioButtonList")
Typecheck.wrap(RadioButtonList, script)

RadioButtonList.defaultProps = {
	OnClick = function() end,
}

function RadioButtonList:init()
	self.state = {
		selectedKey = self.props.SelectedKey,
	}

	self.onClick = function(key, isDisabled)
		local onClick = self.props.OnClick
		if isDisabled then
			return
		end
		if (self.state.selectedKey ~= key) then
			onClick(key)
			self:setState({
				selectedKey = key,
			})
		end
	end
end

function RadioButtonList:render()
	local buttons = self.props.Buttons
	local fillDirection = self.props.FillDirection
	local layoutOrder = self.props.LayoutOrder
	local theme = self.props.Theme

	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local children = {}

	for index, button in ipairs(buttons) do
		children[button.Key] = Roact.createElement(RadioButton, {
			Disabled = button.Disabled,
			Key = button.Key,
			LayoutOrder = index,
			OnClick = function() self.onClick(button.Key, button.Disabled) end,
			Selected = (self.state.selectedKey == button.Key),
			Text = button.Text,
		})
	end

	return Roact.createElement(FitFrameVertical, {
		BackgroundTransparency = 1,
		contentPadding = UDim.new(0, style.Padding),
		FillDirection = fillDirection,
		LayoutOrder = layoutOrder,
		width = UDim.new(1, 0),
	}, children)
end

ContextServices.mapToProps(RadioButtonList, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return RadioButtonList
