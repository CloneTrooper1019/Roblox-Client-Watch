-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Dialog\Alert.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local AlertRoot = script.Parent.Parent
local DialogRoot = AlertRoot.Parent
local AppRoot = DialogRoot.Parent
local UIBlox = AppRoot.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)

local Alert = require(AlertRoot.Alert)
local AlertType = require(AlertRoot.Enum.AlertType)
local ButtonType = require(AppRoot.Button.Enum.ButtonType)

local function close()
	print("close")
end

local function confirm()
	print("confirm")
end

local AlertContainer = Roact.PureComponent:extend("AlertContainer")

function AlertContainer:init()
	self.screenSize = nil
	self.screenRef = Roact.createRef()
	self.state = {
		screenSize = Vector2.new(0, 0),
	}

	self.changeScreenSize = function(rbx)
		if self.state.screenSize ~= rbx.AbsoluteSize then
			self:setState({
				screenSize = rbx.AbsoluteSize
			})
		end
	end

	self.renderTitle = function()
		return Roact.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(164, 86, 78),
			LayoutOrder = 3,
			Size = UDim2.new(1, 0, 0, 60),
		},{
			CustomInner = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Text = "Put custom title content here if icon is not sufficient",
				TextSize = 13,
				TextWrapped = true,
				Size = UDim2.new(1, 0, 1, 0),
			}),
		})
	end

	self.renderMiddle = function()
		return Roact.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(164, 86, 78),
			LayoutOrder = 3,
			Size = UDim2.new(1, 0, 0, 60),
		},{
			CustomInner = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Text = "Put any component you want here.",
				TextSize = 13,
				TextWrapped = true,
				Size = UDim2.new(1, 0, 1, 0),
			}),
		})
	end

	self.renderFooter = function()
		return Roact.createElement("Frame", {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(164, 86, 78),
			LayoutOrder = 3,
			Size = UDim2.new(1, 0, 0, 60),
		},{
			CustomInner = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Text = "Put custom footer content here if footer text is not sufficient",
				TextSize = 13,
				TextWrapped = true,
				Size = UDim2.new(1, 0, 1, 0),
			}),
		})
	end
end

function AlertContainer:didMount()
	self.screenSize = self.screenRef and self.screenRef.current.AbsoluteSize
end

function AlertContainer:render()
	return Roact.createElement(StoryItem, {
		size = UDim2.new(1, 0, 1, 0),
		title = "AlertContainer",
		subTitle = "<<internal>>",
	}, {
		Screen = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			[Roact.Ref] = self.screenRef,
			[Roact.Change.AbsoluteSize] = self.changeScreenSize,
		}, {
			Alert = Roact.createElement(Alert, {
				anchorPoint = Vector2.new(0.5, 0),
				alertType = AlertType.Interactive,
				position = UDim2.new(0.5, 0, 0, 10),
				screenSize = self.state.screenSize,
				title = "Alert Component. Title goes up to 2 lines max.",
				titleContent = self.renderTitle,
				middleContent = self.renderMiddle,
				isMiddleContentFocusable = true,
				buttonStackInfo = {
					buttons = {
						{
							props = {
								isDisabled = false,
								onActivated = close,
								text = "Cancel",
							},
						},
						{
							buttonType = ButtonType.PrimarySystem,
							props = {
								isDisabled = true,
								onActivated = confirm,
								text = "Confirm",
							},
						},
					},
				},
				footerContent = self.renderFooter,
				isFooterContentFocusable = true,
			})
		})
	})
end

return function(target)
	local story = Roact.createElement(StoryView, {}, {
		Roact.createElement(AlertContainer)
	})
	local handle = Roact.mount(story, target, "Alert")
	return function()
		Roact.unmount(handle)
	end
end
