--[[
	A toggle button with on and off state.

	Necessary props:
		Position = explicit position, if not placed in UIListLayout

		bool Enabled = Whether or not this button can be clicked.
		bool IsOn = whether the button should be on or off

		function onToggle = The function that will be called when this button is clicked to turn on and off

	Optional pros:
		int LayoutOrder = The order this ToggleButton will sort to when placed in a UIListLayout
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local ToggleButton = Roact.PureComponent:extend("ToggleButton")

function ToggleButton:init(props)
	self.onToggle = function()
		self.props.onToggle(not self.props.IsOn)
	end
end

function ToggleButton:render()
	return withTheme(function(theme)
		local props = self.props

		local toogleButtonTheme = theme.toggleButton

		local backgroundImage
		if props.Enabled then
			if props.IsOn then
				backgroundImage = toogleButtonTheme.onImage
			else
				backgroundImage = toogleButtonTheme.offImage
			end
		else
			backgroundImage = toogleButtonTheme.disabledImage
		end

		return Roact.createElement("ImageButton", {
			BackgroundTransparency = 1, -- Necessary to make the rounded background
			Image = backgroundImage,

			Position = props.Position,
			Size = props.Size or UDim2.new(0, toogleButtonTheme.defaultWidth, 0, toogleButtonTheme.defaultHeight),

			LayoutOrder = props.LayoutOrder or 1,

			[Roact.Event.Activated] = self.onToggle,
		})
	end)
end

return ToggleButton
