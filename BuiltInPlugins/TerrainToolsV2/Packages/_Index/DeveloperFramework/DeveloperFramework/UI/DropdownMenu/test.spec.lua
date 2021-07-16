return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local provideMockContext = require(Framework.TestHelpers.provideMockContext)

	local DropdownMenu = require(script.Parent)

	local function createDropdownMenu(props)
		props = props or {}

		return provideMockContext(nil, {
			DropdownMenu = Roact.createElement(DropdownMenu, props),
		})
	end

	it("should create and destroy without errors", function()
		local element = Roact.createElement("Frame", {
			Size = UDim2.fromOffset(32, 32),
		}, {
			Menu = createDropdownMenu({
				Hide = false,
				Items = { "a", "b", "c", "d" },
				OnItemActivated = function() end,
				OnFocusLost = function() end,
			})
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end