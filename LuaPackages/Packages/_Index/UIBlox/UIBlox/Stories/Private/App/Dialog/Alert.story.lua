local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local AlertRoot = App.Dialog.Alert
local Alert = require(AlertRoot.Alert)
local AlertType = require(AlertRoot.Enum.AlertType)
local ButtonType = require(App.Button.Enum.ButtonType)

local function close()
	print("close")
end

local function confirm()
	print("confirm")
end

local AlertContainer = Roact.PureComponent:extend("AlertContainer")

function AlertContainer:init()
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
	self:setState(function()
		return {
			screenSize = self.screenRef and self.screenRef.current.AbsoluteSize
		}
	end)
end

function AlertContainer:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromOffset(250, 500),
		BackgroundTransparency = 1,
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
end

return AlertContainer
