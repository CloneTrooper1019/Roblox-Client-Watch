local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local RadioButtonList = require(App.InputButton.RadioButtonList)

return Roact.createElement(RadioButtonList, {
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