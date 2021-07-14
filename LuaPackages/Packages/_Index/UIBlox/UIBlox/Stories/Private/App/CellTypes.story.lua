local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local Images = require(App.ImageSet.Images)
local Cell = require(App.Menu.Cell)

return {
	stories = {
		TextOnly = Roact.createElement(Cell, {
			text = "Title Case",
			onActivated = function() end,

			elementHeight = 56,
			hasRoundTop = false,
			hasRoundBottom = false,
			hasDivider = true,
			layoutOrder = 2,
		}),

		TextSelected = Roact.createElement(Cell, {
			text = "Title Case",
			selected = true,
			onActivated = function() end,

			elementHeight = 56,
			hasRoundTop = false,
			hasRoundBottom = false,
			hasDivider = true,
			layoutOrder = 2,
		}),

		TextAndIcon = Roact.createElement(Cell, {
			icon = Images["icons/menu/friends"],
			text = "Title Case",
			onActivated = function() end,

			elementHeight = 56,
			hasRoundTop = false,
			hasRoundBottom = false,
			hasDivider = true,
			layoutOrder = 2,
		}),

		CellWithKeyLabel = Roact.createElement(Cell, {
			icon = Images["icons/menu/friends"],
			text = "Title Case",
			keyCodeLabel = Enum.KeyCode.E,
			onActivated = function() end,

			elementHeight = 56,
			hasRoundTop = false,
			hasRoundBottom = false,
			hasDivider = true,
			layoutOrder = 2,
		}),

		Disabled = Roact.createElement(Cell, {
			icon = Images["icons/menu/friends"],
			text = "Title Case",
			onActivated = function()

			end,

			elementHeight = 56,
			hasRoundTop = false,
			hasRoundBottom = false,
			hasDivider = true,

			disabled = true,
			layoutOrder = 2,
		}),
	}
}
