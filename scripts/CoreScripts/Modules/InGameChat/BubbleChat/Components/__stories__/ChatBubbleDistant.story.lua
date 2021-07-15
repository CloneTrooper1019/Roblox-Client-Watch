local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Packages.Roact)
local ChatBubbleDistant = require(script.Parent.Parent.ChatBubbleDistant)

return function(props)
	return Roact.createElement(ChatBubbleDistant, {
		chatSettings = props.chatSettings
	})
end
