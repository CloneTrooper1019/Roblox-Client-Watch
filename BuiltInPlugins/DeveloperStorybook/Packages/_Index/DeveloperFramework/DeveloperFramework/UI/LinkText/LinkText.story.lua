local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local LinkText = UI.LinkText

return function()
	return Roact.createElement(LinkText, {
		Text = "Click Me!",
		OnClick = function()
			print("Clicked!")
		end,
	})
end
