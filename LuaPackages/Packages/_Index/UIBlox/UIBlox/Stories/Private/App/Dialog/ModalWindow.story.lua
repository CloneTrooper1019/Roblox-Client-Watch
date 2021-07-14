local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local ModalWindow = require(App.Dialog.Modal.ModalWindow)

local PortraitModal = Roact.PureComponent:extend("PortraitModal")

function PortraitModal:init()
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

function PortraitModal:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 250),
		[Roact.Change.AbsoluteSize] = self.changeScreenSize,
	} , {
		ModalWindowContainer = Roact.createElement(ModalWindow, {
			isFullHeight = self.props.controls.isFullHeight,
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
end

return {
	name = "Modal Window Container",
	summary = "Expand and shrink the width of the window to see how the modal behaves on different widths",
	controls = {
		isFullHeight = true,
	},
	story = PortraitModal,
}
