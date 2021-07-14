--[[
	Represents a single TextBox that accepts only numbers. Used in a NumberTrack.

	When the user starts editing the text inside this component, the text will
	clear, and the user can type anything. When the user presses enter, the SetNumber
	function will be called if the user entered a number, and then the text will return
	to the number which was passed in props.

	Because of this logic, if the SetNumber function is correctly hooked up, the Number
	prop will update when the user confirms their entry, so that the next render will
	show the new number in the text field.

	Props:
		UDim2 Size = The size of the text box.
		float Number = The number to display in the text box when it is not
			being edited by the user.
		int LayoutOrder = The order in which the box displays in a UIListLayout.
		bool ReadOnly = Value cannot be modified, neither by typing a new value, nor
			dragging the label button.

		function SetNumber(float number) = A callback for when the user enters
			a number and then presses the Enter key to confirm their entry.
		function OnDragBegan(input) = A callback for when the user clicks and
			holds the mouse down on the label for the track.
		function OnDragMoved(input) = A callback for when the user drags the mouse
			after clicking and holding the label for the track.
]]

local PADDING = 12

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local StringUtils = require(Plugin.Src.Util.StringUtils)
local DragListenerArea = require(Plugin.Src.Components.DragListenerArea)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local UILibraryCompat = Plugin.Src.UILibraryCompat
local RoundFrame = require(UILibraryCompat.RoundFrame)

local TextBox = require(Plugin.Src.Components.TextBox)

local GetFFlagNoValueChangeDuringPlayback = require(Plugin.LuaFlags.GetFFlagNoValueChangeDuringPlayback)

local NumberBox = Roact.PureComponent:extend("NumberBox")

function NumberBox:init()
	self.state = {
		focused = false,
	}

	self.getTextWidth = function(text, theme)
		local font = theme.font
		local textSize = theme.trackTheme.textSize
		return StringUtils.getTextWidth(text, textSize, font)
	end

	self.focusChanged = function(rbx, focused, submitted)
		self:setState({
			focused = focused,
		})

		if not focused then
			if submitted then
				local text = rbx.Text
				local number = tonumber(text)
				if number and self.props.SetNumber then
					self.props.SetNumber(number)
				else
					rbx.Text = self.props.Number
				end
			else
				rbx.Text = self.props.Number
			end
		end
	end

	self.onDragMoved = function(input)
		if self.props.OnDragMoved then
			self.props.OnDragMoved(input)
		end
	end

	self.onDragBegan = function(input)
		if self.props.OnDragBegan then
			self.props.OnDragBegan(input)
		end
	end
end

function NumberBox:formatNumber(number)
	return math.floor(number * 1000) / 1000
end

function NumberBox:render()
		local props = self.props
		local theme = props.Theme:get("PluginTheme")

		local textBoxTheme = theme.textBox
		local trackTheme = theme.trackTheme
		local state = self.state

		local name = props.Name
		local size = props.Size
		local position = props.Position
		local anchorPoint = props.AnchorPoint
		local number = props.Number
		local layoutOrder = props.LayoutOrder
		local readOnly = props.ReadOnly

		local focused = state.focused

		local borderColor = focused and textBoxTheme.focusedBorder or textBoxTheme.defaultBorder
		local nameWidth = self.getTextWidth(name, theme) + PADDING

		return Roact.createElement(RoundFrame, {
			Size = size,
			Position = position,
			AnchorPoint = anchorPoint,
			BackgroundColor3 = textBoxTheme.backgroundColor,
			BorderColor3 = borderColor,
			LayoutOrder = layoutOrder,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
			}),

			LabelFrame = Roact.createElement(RoundFrame, {
				Size = UDim2.new(0, nameWidth, 1, 0),
				BackgroundColor3 = trackTheme.shadedBackgroundColor,
				BorderColor3 = borderColor,
				LayoutOrder = 1,
			}, {
				NameLabel = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ZIndex = 2,

					Text = name,
					Font = theme.font,
					TextSize = trackTheme.textSize,
					TextColor3 = trackTheme.textColor,
					TextXAlignment = Enum.TextXAlignment.Center,
				}),

				LeftBorderOverlay = Roact.createElement("Frame", {
					Size = UDim2.new(0, 5, 1, -2),
					Position = UDim2.new(1, 0, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = trackTheme.shadedBackgroundColor,
					BorderSizePixel = 0,
				}),

				RightBorderOverlay = Roact.createElement("Frame", {
					Size = UDim2.new(0, 5, 1, -2),
					Position = UDim2.new(1, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = textBoxTheme.backgroundColor,
					BorderSizePixel = 0,
				}),

				DragArea = (not GetFFlagNoValueChangeDuringPlayback() or not readOnly) and Roact.createElement(DragListenerArea, {
					Size = UDim2.new(1, 0, 1, 0),
					Cursor = "SizeEW",
					OnDragMoved = self.onDragMoved,
					OnDragBegan = self.onDragBegan,
				}) or nil,
			}),

			TextBox = Roact.createElement(TextBox, {
				Size = UDim2.new(1, -nameWidth, 1, 0),
				Text = self:formatNumber(number),
				TextXAlignment = Enum.TextXAlignment.Left,
				ReadOnly = readOnly,
				LayoutOrder = 2,
				ClearTextOnFocus = false,
				FocusChanged = self.focusChanged,
			})
		})
end

ContextServices.mapToProps(NumberBox, {
	Theme = ContextServices.Theme,
})


return NumberBox
