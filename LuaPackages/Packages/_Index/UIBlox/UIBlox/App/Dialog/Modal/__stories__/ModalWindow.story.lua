-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Dialog\ModalWindow.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local ModalsRoot = script.Parent.Parent
local DialogRoot = ModalsRoot.Parent
local AppRoot = DialogRoot.Parent
local UIBlox = AppRoot.Parent
local Packages = UIBlox.Parent
local Roact = require(Packages.Roact)

local ModalWindow = require(ModalsRoot.ModalWindow)

local PortraitModal = Roact.PureComponent:extend("PortraitModal")

function PortraitModal:init()
	self.screenSize = nil
	self.screenRef = Roact.createRef()
	self.state = {
		screenSize = Vector2.new(0, 0),
		isFullHeight = false
	}

	self.changeScreenSize = function(rbx)
		if self.state.screenSize ~= rbx.AbsoluteSize then
			self:setState({
				screenSize = rbx.AbsoluteSize
			})
		end
	end

	self.toggleisFullHeight = function()
		self:setState({
			isFullHeight = not self.state.isFullHeight
		})
	end
end

function PortraitModal:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}),
		ButtonControlsFrame = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			LayoutOrder = 1,
		}, {
			Grid = Roact.createElement("UIGridLayout", {
				CellSize = UDim2.new(0, 200, 0, 45),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			DisableControl = Roact.createElement("TextButton", {
				Text = self.state.isFullHeight and "Fit" or "Full Height",
				[Roact.Event.Activated] = self.toggleisFullHeight,
				LayoutOrder = 1,
			}),
		}),
		Overview = Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -50),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		}, {
			Roact.createElement(StoryItem, {
				size = UDim2.new(1, 0, 1, 0),
				title = "ModalWindowContainer",
				subTitle = "Expand and shrink the width of the window to see how the modal behaves on different widths",
			}, {
				ViewFrame = Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 1, 0),
					[Roact.Ref] = self.screenRef,
					[Roact.Change.AbsoluteSize] = self.changeScreenSize,
				} , {
					ModalWindowContainer = Roact.createElement(ModalWindow, {
						isFullHeight = self.state.isFullHeight,
						screenSize = self.state.screenSize,
					}, {
						Custom = Roact.createElement("Frame", {
							BorderSizePixel = 0,
							BackgroundTransparency = 1,
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
						}),
					})
				})
			})
		})
	})
end

return function(target)
	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(PortraitModal),
	}), target, "PortraitModal")

	return function()
		Roact.unmount(handle)
	end
end
