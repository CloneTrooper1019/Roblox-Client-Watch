-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\Core\GenericButton.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryWithControls = require(ReplicatedStorage.Packages.StoryComponents.StoryWithControls)

local Button = script.Parent.Parent
local Core = Button.Parent
local UIBlox = Core.Parent
local Packages = UIBlox.Parent
local Roact = require(Packages.Roact)

local App = UIBlox.App
local Images = require(App.ImageSet.Images)

local withStyle = require(UIBlox.Core.Style.withStyle)
local ControlState = require(UIBlox.Core.Control.Enum.ControlState)

local GenericButton = require(Button.GenericButton)

local GenericButtonOverviewComponent = Roact.PureComponent:extend("GenericButtonOverviewComponent")

function GenericButtonOverviewComponent:init()
	self.isMounted = false
	self.state = {
		isDisabled = false,
		isLoading = false,
		userInteractionEnabled = true,
	}

	self.toggleDisabled = function()
		if self.isMounted then
			self:setState({
				isDisabled = not self.state.isDisabled
			})
		end
	end

	self.toggleLoading = function()
		if self.isMounted then
			self:setState({
				isLoading = not self.state.isLoading
			})
		end
	end

	self.toggleUserInteraction = function()
		if self.isMounted then
			self:setState({
				userInteractionEnabled = not self.state.userInteractionEnabled
			})
		end
	end
end

function GenericButtonOverviewComponent:render()
	local isDisabled = self.state.isDisabled
	local isLoading = self.state.isLoading
	local userInteractionEnabled = self.state.userInteractionEnabled
	local buttonImage = Images["component_assets/circle_17"]
	return withStyle(function(style)
		return Roact.createElement(StoryWithControls, {
			title = "Generic Button",
			subTitle = "<<internal>>",
			controls = {
				{
					text = self.state.disabled and "Enable Buttons" or "Disable Buttons",
					onActivated = self.toggleDisabled,
				},
				{
					text = isLoading and "Load Buttons" or "Unload Buttons",
					onActivated = self.toggleLoading,
				},
				{
					text = "userInteractionEnabled = "..tostring(userInteractionEnabled),
					onActivated = self.toggleUserInteraction,
				},
			},
		}, {
			Button = Roact.createElement(GenericButton, {
				Size = UDim2.new(0, 144, 0, 48),
				buttonImage = buttonImage,
				buttonStateColorMap = {
					[ControlState.Default] = "UIDefault",
					[ControlState.Hover] = "UIEmphasis",
				},
				contentStateColorMap = {
					[ControlState.Default] = "UIDefault",
				},
				isDisabled = isDisabled,
				isLoading = isLoading,
				userInteractionEnabled = userInteractionEnabled,
				onActivated = function()
					print("Generic Button Clicked!")
				end,
				onStateChanged = function(oldState, newState)
					if oldState ~= ControlState.Initialize then
						print("state changed \n oldState:", oldState, " newState:", newState)
					end
				end
			})
		})
	end)
end

function GenericButtonOverviewComponent:didMount()
	self.isMounted = true
end

function GenericButtonOverviewComponent:willUnmount()
	self.isMounted = false
end

return function(target)
	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(GenericButtonOverviewComponent),
	}), target, "Button")

	return function()
		Roact.unmount(handle)
	end
end
