-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Container\HorizontalPageMargin\Resizing.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoryComponents = ReplicatedStorage.Packages.StoryComponents
local StoryView = require(StoryComponents.StoryView)
local StoryLeftBar = require(StoryComponents.StoryLeftBar)
local ResizingFrame = require(StoryComponents.ResizingFrame)
local SectionHeader = require(StoryComponents.SectionHeader)

local Container = script:FindFirstAncestor("Container")
local HorizontalPageMargin = require(Container.HorizontalPageMargin)

local Packages = Container:FindFirstAncestor("Packages")
local Roact = require(Packages.Roact)

return function(target)
	local tree = Roact.createElement(StoryView, nil, {
		leftBar = Roact.createElement(StoryLeftBar, {
			title = "HorizontalPageMargin: Resizing",
			subtitle = table.concat({
				"Page margins are either 12pt, 24pt, or 48pt, depending on container width.",
				"Interact with the red rulers to resize the demonstration.",
			}, "\n\n")
		}, {
			layout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 50),
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			iconButtonsSection = Roact.createElement(SectionHeader, {
				title = "HorizontalPageMargin With Icon Buttons",
				subtitle = "",
				LayoutOrder = 1,
			}),
			resizeDemo1 = Roact.createElement(ResizingFrame, {
				startingWidth = 360,
				startingHeight = 80,
				horizontalRulers = { 360, 540, 680 },
				LayoutOrder = 2,
			}, {
				demo = Roact.createElement(HorizontalPageMargin, {
					backgroundColor3 = Color3.fromRGB(155, 10, 155),
				}, {
					text = Roact.createElement("TextLabel", {
						Text = "text",
						Size = UDim2.fromScale(1, 1),
					}),
				}),
			}),
			textButtonSection = Roact.createElement(SectionHeader, {
				title = "HorizontalPageMargin with Text Buttons",
				subtitle = "",
				LayoutOrder = 3,
			}),
			resizeDemo2 = Roact.createElement(ResizingFrame, {
				startingWidth = 360,
				startingHeight = 80,
				horizontalRulers = { 360, 540, 680 },
				LayoutOrder = 4,
			}, {
				demo = Roact.createElement(HorizontalPageMargin, {
					backgroundColor3 = Color3.fromRGB(155, 10, 155),
				}, {
					text = Roact.createElement("TextLabel", {
						Text = "text",
						Size = UDim2.fromScale(1, 1),
					}),
				}),
			}),
		}),
	})
	local handle = Roact.mount(tree, target)

	return function()
		Roact.unmount(handle)
	end
end
