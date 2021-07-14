-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\Core\Bar\ThreeSectionBar.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)

local Bar = script.Parent.Parent
local Core = Bar.Parent
local UIBlox = Core.Parent
local Packages = UIBlox.Parent
local Roact = require(Packages.Roact)

local ThreeSectionBar = require(Bar.ThreeSectionBar)

return function(target)
	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(ThreeSectionBar, {
			renderLeft = function()
				return Roact.createElement("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(222, 255, 255),
					Size = UDim2.new(0, 50, 1, 0),
					Text = "Left",
				})
			end,
			renderCenter = function()
				return Roact.createElement("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(222, 222, 255),
					Size = UDim2.new(0, 50, 1, 0),
					Text = "Center",
				})
			end,
			renderRight = function()
				return Roact.createElement("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(222, 255, 222),
					Size = UDim2.new(0, 50, 1, 0),
					Text = "Right",
				})
			end
		}),
	}), target, "ThreeSectionBar")
	return function()
		Roact.unmount(handle)
	end
end
