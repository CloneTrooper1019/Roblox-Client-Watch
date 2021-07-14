--[[
	A widget that contains a hyperlink.

	Props:
		bool Enabled = Whether this widget should be interactable.
		string Text = The hyperlink text
		int TextSize = The size of the text
		int LayoutOrder = The order in which this element is displayed if in a UIListLayout.
		function OnClick = what happens when the hyperlink is clicked
		Mouse = plugin mouse for changing the mouse icon
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Mouse = require(script.Parent.Internal.Mouse)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local Hyperlink = Roact.PureComponent:extend("hyperlink")

local function calculateTextSize(text, textSize, font)
	local hugeFrameSizeNoTextWrapping = Vector2.new(5000, 5000)
	local size = game:GetService("TextService"):GetTextSize(text, textSize, font, hugeFrameSizeNoTextWrapping)
	return UDim2.new(0, size.X, 0, size.Y)
end

function Hyperlink:render()
	return withTheme(function(theme)
		if self.props.Enabled == nil then
			self.props.Enabled = true
		end

		local textSize = self.props.TextSize or 22

		return Roact.createElement("TextButton", {
			BackgroundTransparency = 1,
			Text = self.props.Text,
			TextSize = textSize,
			Font = Enum.Font.SourceSans,
			TextColor3 = theme.hyperlink.textColor,
			Size = self.props.Size or calculateTextSize(self.props.Text, textSize, Enum.Font.SourceSans),
			Position = self.props.Position,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = self.props.LayoutOrder,

			[Roact.Event.MouseEnter] = function() if self.props.Enabled then Mouse.onEnter(self.props.Mouse) end end,
			[Roact.Event.MouseLeave] = function() if self.props.Enabled then Mouse.onLeave(self.props.Mouse) end end,

			[Roact.Event.Activated] = function()
				if self.props.Enabled and nil ~= self.props.OnClick then
					self.props.OnClick()
				end
			end,
		})
	end)
end

return Hyperlink