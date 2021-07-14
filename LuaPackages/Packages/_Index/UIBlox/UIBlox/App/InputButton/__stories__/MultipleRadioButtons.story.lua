-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\InputButton\MultipleRadioButtons.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local RadioButtonList = require(script.Parent.Parent.RadioButtonList)

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)

return function(target)
	local styleProvider = Roact.createElement(StoryView, {}, {
		Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(55, 55, 55),
		}, {
			Roact.createElement(RadioButtonList, {
				radioButtons = {
					{
						label = "Bulbasaur"
					},
					"Squirtle",
					"Charmander",
					{
						label = "Mewtwo",
						isDisabled = true,
					},
				},
				onActivated = function(value)
					print("The current value is: ", value)
				end,
				selectedValue = 2,
				elementSize = UDim2.new(0, 480, 0, 54),
			})
		})
	})
	local handle = Roact.mount(styleProvider, target, "MultipleRadioButtons")
	return function()
		Roact.unmount(handle)
	end
end
