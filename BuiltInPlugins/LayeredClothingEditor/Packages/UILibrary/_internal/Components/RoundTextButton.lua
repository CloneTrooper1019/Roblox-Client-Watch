--[[
	A button with rounded corners.

	Supports one of two styles:
		"Blue": A blue button with white text and no border.
		"White": A white button with black text and a black border.

	Props:
		bool Active = Whether or not this button can be clicked.
		UDim2 Size = UDim2.new(0, Constants.BUTTON_WIDTH, 0, Constants.BUTTON_HEIGHT)
		int LayoutOrder = The order this RoundTextButton will sort to when placed in a UIListLayout.
		string Name = The text to display in this Button.
		function OnClicked = The function that will be called when this button is clicked.
		variant Value = Data that can be accessed from the OnClicked callback.
		int TextSize = The size of text
		table Style = {
			ButtonColor,
			ButtonColor_Hover,
			ButtonColor_Disabled,
			TextColor,
			TextColor_Disabled,
			BorderColor,
		}
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)
local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local BUTTON_WIDTH = 125
local BUTTON_HEIGHT = 35

local RoundTextButton = Roact.PureComponent:extend("RoundTextButton")

function RoundTextButton:init()
	self.state = {
		Hovering = false,
	}

	self.mouseEnter = function()
		self:setState({
			Hovering = true,
		})
	end

	self.mouseLeave = function()
		self:setState({
			Hovering = false,
		})
	end
end

function RoundTextButton:render()
	return withTheme(function(theme)
		local active = self.props.Active
		local hovering = self.state.Hovering
		local style = self.props.Style
		local match = self.props.BorderMatchesBackground
		local textSize = self.props.TextSize

		local backgroundProps = {
			-- Necessary to make the rounded background
			BackgroundTransparency = 1,
			Image = theme.roundFrame.backgroundImage,
			ImageTransparency = 0,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = theme.roundFrame.slice,

			Position = self.props.Position or UDim2.new(0, 0, 0, 0),
			Size = self.props.Size or UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT),
			AnchorPoint = self.props.AnchorPoint or Vector2.new(0, 0),

			LayoutOrder = self.props.LayoutOrder or 1,
			ZIndex = self.props.ZIndex or 1,

			[Roact.Event.MouseEnter] = self.mouseEnter,
			[Roact.Event.MouseLeave] = self.mouseLeave,

			[Roact.Event.Activated] = function()
				if active then
					self.props.OnClicked(self.props.Value)
				end
			end,
		}

		if active then
			backgroundProps.ImageColor3 = hovering and style.ButtonColor_Hover or style.ButtonColor
		else
			backgroundProps.ImageColor3 = style.ButtonColor_Disabled
		end

		return Roact.createElement("ImageButton", backgroundProps, {
			Border = Roact.createElement("ImageLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = theme.roundFrame.borderImage,
				ImageColor3 = match and backgroundProps.ImageColor3 or style.BorderColor,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = theme.roundFrame.slice,
				ZIndex = self.props.ZIndex or 1,
			}),

			Text = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Font = theme.textButton.font,
				TextColor3 = active and style.TextColor or style.TextColor_Disabled,
				TextSize = textSize,
				Text = self.props.Name,
				ZIndex = self.props.ZIndex or 1,
			}),
		})
	end)
end

return RoundTextButton
