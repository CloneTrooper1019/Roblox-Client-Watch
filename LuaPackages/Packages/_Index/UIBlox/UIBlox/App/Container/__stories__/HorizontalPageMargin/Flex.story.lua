-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Container\HorizontalPageMargin\Flex.story.lua`

local Container = script:FindFirstAncestor("Container")
local HorizontalPageMargin = require(Container.HorizontalPageMargin)

local Packages = Container:FindFirstAncestor("Packages")
local Roact = require(Packages.Roact)

return function(target)
	local tree = Roact.createElement(HorizontalPageMargin, {
		backgroundColor3 = Color3.fromRGB(150, 10, 150),
	}, {
		text = Roact.createElement("TextLabel", {
			Text = "Hello",
			Size = UDim2.fromScale(1, 1),
		})
	})
	local handle = Roact.mount(tree, target, "HorizontalPageMargin")
	return function()
		Roact.unmount(handle)
	end
end
