local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local TextWithInlineLink = UI.TextWithInlineLink

return function()
	return Roact.createElement(TextWithInlineLink, {
        TextProps = {
            TextSize = 12,
            Font = Enum.Font.SourceSans
        },
        MaxWidth = 100,
		Text = "Hello here is a {link} that is going to cause this to wrap onto another line and this line after the link will wrap on its own it's that long!",
        LinkText = "Link",
        LinkPlaceholder = "{link}",
		OnLinkClicked = function()
			print("Clicked!")
		end,
	})
end
