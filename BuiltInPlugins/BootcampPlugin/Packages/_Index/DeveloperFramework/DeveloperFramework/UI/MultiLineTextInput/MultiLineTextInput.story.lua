local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local MultiLineTextInput = UI.MultiLineTextInput

local longText = [[I wanna be the very best Like no one ever was Catch them is my real test
To train them is my cause I will travel across the land Searching far and wide Teach Pokémon to
understand The power that's inside Pokémon! Gotta catch 'em all (It's you and me) I know its my destiny]]

return {
	stories = {
		{
			name = "FilledRoundedBorder",
			story = Roact.createElement(MultiLineTextInput, {
				LayoutOrder = 2,
				Size = UDim2.new(0, 200, 0, 100),
				Style = "FilledRoundedBorder",
				TextInputProps = {
					Text = longText,
				},
				OnTextChanged = function() print("OnTextChanged") end,
			})
		},
		{
			name = "FilledRoundedRedBorder",
			story = Roact.createElement(MultiLineTextInput, {
				LayoutOrder = 2,
				Size = UDim2.new(0, 200, 0, 100),
				Style = "FilledRoundedRedBorder",
				TextInputProps = {
					Text = longText,
				},
				OnTextChanged = function() print("OnTextChanged") end,
			})
		},
	}
}