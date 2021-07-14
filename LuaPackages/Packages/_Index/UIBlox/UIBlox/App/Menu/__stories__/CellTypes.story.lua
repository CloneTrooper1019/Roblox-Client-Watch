-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\CellTypes.story.lua`

local Menu = script.Parent.Parent
local App = Menu.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local Images = require(Packages.UIBlox.App.ImageSet.Images)

local StoryView = require(Packages.StoryComponents.StoryView)
local StoryItem = require(Packages.StoryComponents.StoryItem)

local Cell = require(Menu.Cell)

local CellTypesOverviewComponent = Roact.Component:extend("CellTypesOverviewComponent")

function CellTypesOverviewComponent:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Overview = Roact.createElement("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			Grid = Roact.createElement("UIGridLayout", {
				CellSize = UDim2.fromOffset(300, 200),
				FillDirectionMaxCells = 2,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 20),
			}),

			TextOnly = Roact.createElement(StoryItem, {
				size = UDim2.fromOffset(300, 128),
				layoutOrder = 1,
				title = "Text Only",
				subTitle = "",
				showDivider = true,
			}, {
				Button = Roact.createElement(Cell, {
					text = "Title Case",
					onActivated = function()

					end,

					elementHeight = 56,
					hasRoundTop = false,
					hasRoundBottom = false,
					hasDivider = true,

					layoutOrder = 2,
				}),
			}),

			TextSelected = Roact.createElement(StoryItem, {
				size = UDim2.fromOffset(300, 128),
				layoutOrder = 2,
				title = "Text Selected",
				subTitle = "",
				showDivider = true,
			}, {
				Button = Roact.createElement(Cell, {
					text = "Title Case",
					selected = true,
					onActivated = function()

					end,

					elementHeight = 56,
					hasRoundTop = false,
					hasRoundBottom = false,
					hasDivider = true,

					layoutOrder = 2,
				}),
			}),

			TextAndIcon = Roact.createElement(StoryItem, {
				size = UDim2.fromOffset(300, 128),
				layoutOrder = 3,
				title = "Text and Icon",
				subTitle = "",
				showDivider = true,
			}, {
				Button = Roact.createElement(Cell, {
					icon = Images["icons/menu/friends"],
					text = "Title Case",
					onActivated = function()

					end,

					elementHeight = 56,
					hasRoundTop = false,
					hasRoundBottom = false,
					hasDivider = true,

					layoutOrder = 2,
				}),
			}),

			CellWithKeyLabel = Roact.createElement(StoryItem, {
				size = UDim2.fromOffset(300, 128),
				layoutOrder = 4,
				title = "Cell with KeyLabel",
				subTitle = "",
				showDivider = true,
			}, {
				Button = Roact.createElement(Cell, {
					icon = Images["icons/menu/friends"],
					text = "Title Case",
					keyCodeLabel = Enum.KeyCode.E,
					onActivated = function()

					end,

					elementHeight = 56,
					hasRoundTop = false,
					hasRoundBottom = false,
					hasDivider = true,

					layoutOrder = 2,
				}),
			}),

			Disabled = Roact.createElement(StoryItem, {
				size = UDim2.fromOffset(300, 128),
				layoutOrder = 5,
				title = "Disabled",
				subTitle = "",
				showDivider = true,
			}, {
				Button = Roact.createElement(Cell, {
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
			}),
		})
	})
end

return function(target)
	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(CellTypesOverviewComponent),
	}), target, "CellTypes")

	return function()
		Roact.unmount(handle)
	end
end
