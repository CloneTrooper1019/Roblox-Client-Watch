local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local InformativeAlert = require(App.Dialog.Alert.InformativeAlert)

local InformativeAlertContainer = Roact.PureComponent:extend("InformativeAlertContainer")

function InformativeAlertContainer:init()
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

function InformativeAlertContainer:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		[Roact.Ref] = self.screenRef,
		[Roact.Change.AbsoluteSize] = self.changeScreenSize,
	}, {
		InformativeAlert = Roact.createElement(InformativeAlert, {
			anchorPoint = Vector2.new(0.5, 0),
			title = "Informative Alert",
			bodyText = "Only reposition the Alert when there is a keyboard present",
			screenSize = self.state.screenSize,
			position = UDim2.new(0.5, 0, 0, 10),
		})
	})
end

return InformativeAlertContainer
