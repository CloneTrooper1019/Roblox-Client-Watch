local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local InformativeAlert = require(App.Dialog.Alert.InformativeAlert)

local InformativeAlertContainer = Roact.PureComponent:extend("InformativeAlertContainer")

local DUMMY_TEXT_LONG = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, " ..
	"sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nunc sed augue lacus viverra vitae congue. "

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
			title = "Informative Alert with long text. Title goes up to 2 lines. But then cuts off.",
			bodyText = DUMMY_TEXT_LONG,
			screenSize = self.state.screenSize,
		})
	})
end

return InformativeAlertContainer
