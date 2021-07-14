local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Favorites = require(script.Parent)

return function()
	return {
		LowCount = Roact.createElement(Favorites, {
			Count = 5,
			IsFavorited = false,
			OnClick = function() end
		}),
		Favorited = Roact.createElement(Favorites, {
			Count = 10,
			IsFavorited = true,
			OnClick = function() end
		}),
		HighCount = Roact.createElement(Favorites, {
			Count = 10500,
			IsFavorited = false,
			OnClick = function() end
		})
	}
end