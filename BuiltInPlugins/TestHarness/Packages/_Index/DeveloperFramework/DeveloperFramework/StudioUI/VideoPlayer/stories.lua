local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local VideoPlayer = require(script.Parent)

return function()
	local baseProps = {
		VideoId = "rbxassetid://5608250999"
	}

	return {
		Default = Roact.createElement(VideoPlayer, baseProps),
	}
end