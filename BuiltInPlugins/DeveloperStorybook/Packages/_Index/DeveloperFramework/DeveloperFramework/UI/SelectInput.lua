--[[
	A from element which allows the user to choose an option from a dropdown menu of options.

	Required Props:
		table Items: An array of each item that should appear in the dropdown.
		callback OnItemActivated: A callback for when the user selects a dropdown entry.
		Focus Focus: a Focus object supplied by mapToProps()

	Optional Props:
		number Width: The width of the select input
		string PlaceholderText: A placeholder to display if there is no item selected.
		callback OnRenderItem: A function used to render a dropdown menu item.
		number SelectedIndex: The currently selected item index.
		Style Style: The style with which to render this component.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Theme Theme: a Theme object supplied by mapToProps()

	Style Values:
		Style BackgroundStyle: The style with which to render the background.
		UDim2 Size: The size of the input component.
		UDim2 ArrowSize: The size of the dropdown arrow image.
		string ArrowImage: The asset to use as the dropdown arrow image.
		Color3 ArrowColor: The color of the dropdown arrow image.
		Color3 PlaceholderTextColor: The color of the dropdown placeholder text.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local UI = Framework.UI
local prioritize = Util.prioritize
local Container = require(UI.Container)
local RoundBox = require(UI.RoundBox)
local DropdownMenu = require(UI.DropdownMenu)
local TextLabel = require(UI.TextLabel)
local StyleModifier = Util.StyleModifier

local SelectInput = Roact.PureComponent:extend("SelectInput")
Typecheck.wrap(SelectInput, script)

local isInputMainPress = Util.isInputMainPress

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local BORDER_SIZE = 1

function SelectInput:init()
	self.state = {
		isOpen = false
	}

	self.mouseEnter = function()
		self:setState({
			StyleModifier = StyleModifier.Hover
		})
	end

	self.mouseLeave = function()
		self:setState({
			StyleModifier = Roact.None
		})
	end

	self.onInputBegan = function(rbx, input)
		local isMainPress = isInputMainPress(input)
		if isMainPress then
			self:setState({
				isOpen = true
			})
		end
	end

	self.focusLost = function()
		self:setState({
			isOpen = false
		})
	end
end

function SelectInput:render()
	local props = self.props
	local state = self.state

	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = props.Theme:getStyle("Framework", self)
	end
	local items = props.Items

	local isOpen = state.isOpen
	local size = prioritize(props.Size, style.Size, UDim2.new(1, 0, 1, 0))
	if props.Width then
		size = UDim2.new(0, props.Width, size.Y.Scale, size.Y.Offset)
	end

	local backgroundStyle = style.BackgroundStyle
	local selectedIndex = props.SelectedIndex
	local itemText = selectedIndex and items[selectedIndex] or props.PlaceholderText

	local SelectedItemText = itemText and Roact.createElement(TextLabel, {
		Text = itemText,
		Size = UDim2.new(1, -(style.ArrowOffset + style.ArrowSize.X.Offset), 1, -BORDER_SIZE * 2),
		Position = UDim2.fromOffset(10, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor = (not selectedIndex) and style.PlaceholderTextColor or nil
	})

	local SelectArrow = Roact.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Size = style.ArrowSize,
		Position = UDim2.new(1, -style.ArrowOffset, 0.5, 0),
		Image = style.ArrowImage,
		ImageColor3 = style.ArrowColor,
		BackgroundTransparency = 1
	})

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = size,
		[Roact.Event.InputBegan] = self.onInputBegan,
		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseLeave] = self.mouseLeave,
	}, {
		Input = Roact.createElement(Container, {
			Background = RoundBox,
			BackgroundStyle = backgroundStyle,
		}, {
			SelectedItemText = SelectedItemText,
			SelectArrow = SelectArrow,
		}),
		Menu = Roact.createElement(DropdownMenu, {
			Width = props.Width,
			Hide = not isOpen,
			Items = items,
			OnFocusLost = self.focusLost,
			OnItemActivated = props.OnItemActivated,
			Style = style.DropdownMenu,
		})
	})
end

ContextServices.mapToProps(SelectInput, {
	Focus = ContextServices.Focus,
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return SelectInput
