local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local InteractiveAlert = require(App.Dialog.Alert.InteractiveAlert)
local ButtonType = require(App.Button.Enum.ButtonType)

local function close()
	print("close")
end

local function confirm()
	print("confirm")
end

local InteractiveAlertContainer = Roact.PureComponent:extend("InteractiveAlertContainer")

function InteractiveAlertContainer:init()
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
end

function InteractiveAlertContainer:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		[Roact.Ref] = self.screenRef,
		[Roact.Change.AbsoluteSize] = self.changeScreenSize,
	}, {
		InteractiveAlert = Roact.createElement(InteractiveAlert, {
			title = "Interactive Alert",
			titleContent = self.renderTitle,
			bodyText = "An alert that has buttons you can interact with.",
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
							onActivated = confirm,
							text = "Confirm",
						},
					},
				},
			},
			screenSize = self.state.screenSize,
		})
	})
end

return InteractiveAlertContainer