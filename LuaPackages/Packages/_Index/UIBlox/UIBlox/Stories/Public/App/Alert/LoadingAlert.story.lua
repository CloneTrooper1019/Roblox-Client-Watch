local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local LoadingAlert = require(App.Dialog.Alert.LoadingAlert)

local LoadingAlertContainer = Roact.PureComponent:extend("LoadingAlertContainer")

function LoadingAlertContainer:init()
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

function LoadingAlertContainer:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		[Roact.Ref] = self.screenRef,
		[Roact.Change.AbsoluteSize] = self.changeScreenSize,
	}, {
		LoadingAlert = Roact.createElement(LoadingAlert, {
			title = "Loading Alert",
			screenSize = self.state.screenSize,
		})
	})
end

return LoadingAlertContainer