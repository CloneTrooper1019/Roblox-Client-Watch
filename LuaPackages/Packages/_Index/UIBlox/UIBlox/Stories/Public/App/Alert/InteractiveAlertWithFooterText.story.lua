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
end

function InteractiveAlertContainer:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		[Roact.Ref] = self.screenRef,
		[Roact.Change.AbsoluteSize] = self.changeScreenSize,
	}, {
		InteractiveAlert = Roact.createElement(InteractiveAlert, {
			title = "Interactive Alert",
			bodyText = "Body text goes here.",
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
			footerText = "Footer text goes here",
			screenSize = self.state.screenSize,
		})
	})
end

return InteractiveAlertContainer
