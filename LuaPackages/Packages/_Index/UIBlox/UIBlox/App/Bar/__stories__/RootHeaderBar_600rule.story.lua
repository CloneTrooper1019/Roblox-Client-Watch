-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Bar\RootHeaderBar_600rule.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local UIBlox = require(script:FindFirstAncestor("UIBlox"))
local Packages = script:FindFirstAncestor("Packages")
local Roact = require(Packages.Roact)

local App = UIBlox.App
local HeaderBar = App.Bar.HeaderBar

return function(target)
	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(StoryItem, {
				backgroundColor3 = Color3.fromRGB(177, 177, 177),
				size = UDim2.new(1, 0, 1, 0),
				title = "HeaderBar",
				subTitle =
					"On landscape, if the screen height is 600pt or less\n" ..
					"the Common Header Bar is used instead of Root Header Bar!",
			}, {
				layout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 10),
				}),
				frame1 = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(550, 45),
				}, {
					headerBar = Roact.createElement(HeaderBar, {
						title = "600+",
						renderLeft = nil,
					}),
				}),
				frame2 = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(550, 45),
				}, {
					headerBar = Roact.createElement(HeaderBar, {
						title = "600-",
						renderLeft = function()
							return nil
						end,
					}),
				}),
			})
	}), target, "HeaderBar")
	return function()
		Roact.unmount(handle)
	end
end
