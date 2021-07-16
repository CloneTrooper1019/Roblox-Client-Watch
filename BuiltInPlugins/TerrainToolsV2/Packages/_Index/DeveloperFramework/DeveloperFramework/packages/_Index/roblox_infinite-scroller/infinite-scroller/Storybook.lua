local Root = script:FindFirstAncestor("infinite-scroller").Parent
local Roact = require(Root.Roact)

Roact.setGlobalConfig({
	propValidation = true,
})

local SCREEN_SIZE = Vector2.new(800, 480)

return {
	name = "Scroller",
	storyRoot = script,
	middleware = function(story, target)
		local tree = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(30, 31, 28),
			Size = UDim2.new(0, SCREEN_SIZE.X, 0, SCREEN_SIZE.Y),
			ClipsDescendants = true,
		}, {
			Story = Roact.createElement(story)
		})

		local handle = Roact.mount(tree, target, "Root")
		return function()
			Roact.unmount(handle)
		end
	end,
}