-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Bar\FullscreenTitleBar.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local Bar = script.Parent.Parent
local App = Bar.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent
local Roact = require(Packages.Roact)

local FullscreenTitleBar = require(script.Parent.Parent.FullscreenTitleBar)

local DISAPPEAR_DELAY = 0.5

local TitleBarStory = Roact.PureComponent:extend("TitleBarStory")

function TitleBarStory:init()
	self:setState({
		isTriggered = false,
	})

	self.triggerTitleBar = function()
		print("Mouse entering trigger area")
		if not self.state.isTriggered then
			self:setState({
				isTriggered = true,
			})
		end
	end

	self.hideTitleBar = function()
		print("Mouse leaving Title Bar area")
		if self.state.isTriggered then
			delay(DISAPPEAR_DELAY, function()
				self:setState({
					isTriggered = false,
				})
			end)
		end
	end

	self.buttonControl = function()
		self:setState(function(prevState)
			return {
				isTriggered = not prevState.isTriggered,
			}
		end)
	end
end

function TitleBarStory:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}),
		ControlsFrame = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			LayoutOrder = 1,
		}, {
			TestButton = Roact.createElement("TextButton", {
				Text = self.state.isTriggered and "Dismiss" or "Activate",
				Size = UDim2.fromOffset(200, 50),
				[Roact.Event.Activated] = self.buttonControl,
			}),
		}),
		StoryItem = Roact.createElement(StoryItem, {
			size = UDim2.fromScale(1, 1),
			title = "FullscreenTitleBar",
			subTitle = "App.Bar.FullscreenTitleBar",
			layoutOrder = 2,
			showDivider = true,
		}, {
			Demo = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
			}, {
				TriggerArea = Roact.createElement("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 255, 255),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 1),
					[Roact.Event.MouseEnter] = self.triggerTitleBar,
				}),
				TitleBar = Roact.createElement(FullscreenTitleBar, {
					title = "Roblox",
					isTriggered = self.state.isTriggered,
					onDisappear = self.hideTitleBar,
					exitFullscreen =  function()
						print "Exit Fullscreen"
					end,
					closeRoblox = function()
						print "Close Roblox"
					end,
				}),
			})
		}),
	})
end

return function(target)
	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(TitleBarStory),
	}), target, "FullscreenTitleBar")
	return function()
		Roact.unmount(handle)
	end
end
