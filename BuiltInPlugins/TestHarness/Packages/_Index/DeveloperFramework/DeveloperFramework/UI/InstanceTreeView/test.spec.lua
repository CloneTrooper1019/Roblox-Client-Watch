return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local provideMockContext = require(Framework.TestHelpers.provideMockContext)
	local InstanceTreeView = require(script.Parent)

	local function createInstanceTreeView()
		return provideMockContext(nil, {
			InstanceTreeView = Roact.createElement(InstanceTreeView, {
				Size = UDim2.new(0, 240, 0, 240),
				Instances = {game.Workspace},
				Selection = {},
				Expansion = {},
				OnSelectionChange = function(items) end,
				OnExpansionChange = function(items) end,
				Style = "Compact"
			}),
		})
	end

	it("should create and destroy without errors", function()
		local element = createInstanceTreeView()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end