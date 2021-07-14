local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local UIBlox = Packages.UIBlox
local ModalBottomSheet = require(UIBlox.ModalBottomSheet.ModalBottomSheet)
local Images = require(UIBlox.App.ImageSet.Images)

local ICON = Images["component_assets/circle_17"]

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

local function getModalButtons(option)
	local buttons = {}
	for i = 1, option do
		table.insert(buttons, {
			icon = ICON,
			text = "option " .. i,
			onActivated = doSomething,
		})
	end

	return buttons
end

function Story:render()
	local showModal = self.state.showModal
	local option = self.props.controls.option
	local modalButtonSet = getModalButtons(option)
	local abSize = self.ref.AbsoluteSize

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 500),
		[Roact.Ref] = self.ref,
	}, {
		TestButton1 = Roact.createElement("TextButton", {
			Text = "Show Modal",
			Size = UDim2.new(1, 0, 0, 100),
			BackgroundColor3 = Color3.fromRGB(0, 111, 0),
			AutoButtonColor = false,
			[Roact.Event.Activated] = self.ShowModal,
		}),
		modal = showModal and Roact.createElement(ModalBottomSheet, {
			bottomGap = 10,
			screenWidth = abSize and abSize.X or 0,
			onDismiss = self.OnDismiss,
			buttonModels = modalButtonSet,
		})
	})
end

return {
	controls = {
		option = {1, 2, 9},
	},
	story = Story,
}
