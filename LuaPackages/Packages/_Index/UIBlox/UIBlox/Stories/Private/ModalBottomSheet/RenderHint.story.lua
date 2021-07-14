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

local renderDummyHint = function()
	return Roact.createElement("TextLabel", {
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(255, 255, 255),
		Text = "R",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
	})
end

local modalButtonSet = {
	{
		icon = ICON,
		text = "option 1",
		onActivated = doSomething,
		renderRightElement = renderDummyHint,
	},
	{
		icon = ICON,
		text = "longer option that will be truncated",
		onActivated = doSomething,
		renderRightElement = renderDummyHint,
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
			Text = "Spawn 2 Choice",
			Size = UDim2.new(1, 0, 0, 100),
			BackgroundColor3 = Color3.fromRGB(222, 0, 0),
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

return Story
