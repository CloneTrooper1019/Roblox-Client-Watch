-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\ModalBottomSheet\DefaultOptions.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)

local Packages = script.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local ModalBottomSheet = require(script.Parent.Parent.ModalBottomSheet)
local Images = require(Packages.UIBlox.App.ImageSet.Images)

local doSomething = function(a)
	print(a, "was pressed!")
end

local dummyModalButtons2 = {
	{
		icon = Images["component_assets/circle_17"],
		text = "option 1, with no images",
		onActivated = doSomething,
	},
	{
		text = "option 2, with no images",
		onActivated = doSomething,
	},
}

local function withStyle(tree)
	return Roact.createElement(StoryView, {}, {
		oneChild = tree,
	})
end

local function mountWithStyle(tree, target, name)
	local styledTree = withStyle(tree)

	return Roact.mount(styledTree, target, name)
end

local overlayComponent = Roact.Component:extend("overlayComponent")

function overlayComponent:render()
	local ModalContainer = self.props.ModalContainer
	local showModal = self.state.showModal

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
	}, {
		Layout = Roact.createElement("UIListLayout", {

		}),
		TestButton1 = Roact.createElement("TextButton", {
			Text = "Spawn 2 Choice",
			Size = UDim2.new(1, 0, 0.2, 0),
			BackgroundColor3 = Color3.fromRGB(22, 22, 222),
			AutoButtonColor = false,
			[Roact.Event.Activated] = function()
				self:setState({
					showModal = true,
				})
			end
		}),
		modal = showModal and Roact.createElement(Roact.Portal, {
			target = ModalContainer,
		}, {
			sheet = Roact.createElement(ModalBottomSheet, {
				bottomGap = 10,
				screenWidth = self.props.width,
				onDismiss = function()
					self:setState({
						showModal = false,
					})
				end,
				showImages = false,
				buttonModels = dummyModalButtons2,
			})
		})
	})
end

return function(target)
	local ModalContainer = Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 10,
	})

	Roact.mount(ModalContainer, target, "ModalContainer")

	local handle = mountWithStyle(Roact.createElement(overlayComponent, {
		ModalContainer = target:FindFirstChild("ModalContainer"),
		width = 0,
	}), target, "preview")

	local connection = target:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local tree = withStyle(Roact.createElement(overlayComponent, {
			ModalContainer = target:FindFirstChild("ModalContainer"),
			width = target.AbsoluteSize.X,
		}))

		Roact.update(handle, tree)
	end)

	return function()
		connection:Disconnect()
		Roact.unmount(handle)
	end
end
