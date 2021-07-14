return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local MediaProgressBar = require(Library.Components.Preview.MediaProgressBar)

	local function createTestAsset(container, name)
		local emptyFunc = function() end

		local element = Roact.createElement(MockWrapper, {}, {
			Roact.createElement(MediaProgressBar, {
				CurrentValue = 0,
				LayoutOrder = 2,
				Min = 0,
				Max = 1,
				OnValuesChanged = emptyFunc,
				OnInputEnded = emptyFunc,
			})
		})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end