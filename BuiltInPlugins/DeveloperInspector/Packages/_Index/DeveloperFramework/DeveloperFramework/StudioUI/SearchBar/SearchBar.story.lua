local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local UI = require(Framework.UI)
local Pane = UI.Pane

local StudioUI = require(Framework.StudioUI)
local SearchBar = StudioUI.SearchBar

return Roact.createElement(Pane, {
	Size = UDim2.new(1, 0, 0, 30),
	Layout = Enum.FillDirection.Vertical,
	Spacing = 10,
}, {
	Default = Roact.createElement(SearchBar, {
		OnSearchRequested = function(searchTerm)
			print("Search: " .. searchTerm)
		end
	}),
	WithIcon = Roact.createElement(SearchBar, {
		ShowSearchIcon = true,
		ShowSearchButton = false,
		OnTextChanged = function(searchTerm)
			print("Search: " .. searchTerm)
		end
	})
})
