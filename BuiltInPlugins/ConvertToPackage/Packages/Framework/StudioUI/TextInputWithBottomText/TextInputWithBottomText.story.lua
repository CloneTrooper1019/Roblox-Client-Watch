local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local StudioUI = require(Framework.StudioUI)
local TextInputWithBottomText = StudioUI.TextInputWithBottomText

return {
	stories = {
		{
			name = "Default",
			story = Roact.createElement(TextInputWithBottomText, {
				BottomText = "Bottom text",
				Size = UDim2.new(0, 150, 0, 20),
				TextInputProps = {
					PlaceholderText = "hello world!",
				},
			})
		},
		{
			name = "MultiLined",
			story = Roact.createElement(TextInputWithBottomText, {
				BottomText = "Bottom text",
				Size = UDim2.new(0, 150, 0, 100),
				TextInputProps = {
					MultiLine = true,
					PlaceholderText = "hello world!",
				},
			})
		},
		{
			name = "Error",
			story = Roact.createElement(TextInputWithBottomText, {
				BottomText = "Bottom text",
				Size = UDim2.new(0, 150, 0, 20),
				Style = "Error",
				TextInputProps = {
					PlaceholderText = "hello world!",
				},
			})
		},
	}
}