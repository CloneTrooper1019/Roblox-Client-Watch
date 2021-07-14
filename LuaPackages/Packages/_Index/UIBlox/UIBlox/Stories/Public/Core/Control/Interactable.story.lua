local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent

local UIBlox = require(Packages.UIBlox)
local Roact = require(Packages.Roact)

local withStyle = UIBlox.Core.Style.withStyle
local Interactable = UIBlox.Core.Control.Interactable

local InteractableStory = Roact.Component:extend("InteractableStory")

function InteractableStory:init()
	self.labelText, self.updateLabelText = Roact.createBinding("No Control State")

	-- With Roact bindings, UI treatment can be computed based on
	-- the Interactable's ControlState
	self.onStateChanged = function(oldState, newState)
		self.updateLabelText(tostring(newState))
	end
end

function InteractableStory:render()
	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		return Roact.createElement(Interactable, {
			Size = UDim2.fromOffset(250, 100),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			BackgroundColor3 = theme.BackgroundDefault.Color,
			onStateChanged = self.onStateChanged,
		}, {
			StateLabel = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextScaled = true,
				TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Center,
				Text = self.labelText,
			}),
		})
	end)
end

return {
	summary = "Interactable With BackgroundUIDefault Theme",
	story = InteractableStory
}
