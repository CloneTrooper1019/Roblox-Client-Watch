local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local Images = require(App.ImageSet.Images)

local Core = Packages.UIBlox.Core
local GenericButton = require(Core.Button.GenericButton)

local withStyle = require(Core.Style.withStyle)
local ControlState = require(Core.Control.Enum.ControlState)

local Story = Roact.PureComponent:extend("GenericButtonOverviewComponent")

function Story:render()
	local isDisabled = self.props.controls.isDisabled
	local isLoading = self.props.controls.isLoading
	local userInteractionEnabled = self.props.controls.userInteractionEnabled
	local buttonImage = Images["component_assets/circle_17"]
	return withStyle(function(style)
		return Roact.createElement(GenericButton, {
			Size = UDim2.new(0, 144, 0, 48),
			buttonImage = buttonImage,
			buttonStateColorMap = {
				[ControlState.Default] = "UIDefault",
				[ControlState.Hover] = "UIEmphasis",
			},
			contentStateColorMap = {
				[ControlState.Default] = "UIDefault",
			},
			isDisabled = isDisabled,
			isLoading = isLoading,
			userInteractionEnabled = userInteractionEnabled,
			onActivated = function()
				print("Generic Button Clicked!")
			end,
			onStateChanged = function(oldState, newState)
				if oldState ~= ControlState.Initialize then
					print("state changed \n oldState:", oldState, " newState:", newState)
				end
			end
		})
	end)
end

return {
	controls = {
		isDisabled = false,
		isLoading = false,
		userInteractionEnabled = true,
	},
	story = Story
}