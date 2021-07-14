local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local UIBlox = Packages.UIBlox
local ModalBottomSheet = require(UIBlox.ModalBottomSheet.ModalBottomSheet)

local doSomething = function(a)
	print(a, "was pressed!")
end

local Story = Roact.Component:extend("Story")

function Story:init()
	self.state = {

	}
	self.ShowModal = function()
		self:setState({
			showModal = true,
		})
	end
	self.OnDismiss = function()
		self:setState({
			showModal = false,
		})
	end
	self.ref = Roact.createRef()
end

local modalButtonSet = {
	{
		text = "Stay on click",
		onActivated = doSomething,
		stayOnActivated = true,
	},
	{
		text = "Dismiss on click",
		onActivated = doSomething,
		stayOnActivated = false,
	},
}

function Story:render()
	local showModal = self.state.showModal
	local abSize = self.ref.AbsoluteSize

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 500),
		[Roact.Ref] = self.ref,
	}, {
		TestButton1 = Roact.createElement("TextButton", {
			Text = "Spawn Choices",
			Size = UDim2.new(1, 0, 0.2, 0),
			BackgroundColor3 = Color3.fromRGB(22, 22, 222),
			AutoButtonColor = false,
			[Roact.Event.Activated] = self.ShowModal,
		}),
		modal = showModal and Roact.createElement(ModalBottomSheet, {
			bottomGap = 10,
			screenWidth = abSize and abSize.X or 0,
			onDismiss = self.OnDismiss,
			showImages = false,
			buttonModels = modalButtonSet,
		})
	})
end

return Story
