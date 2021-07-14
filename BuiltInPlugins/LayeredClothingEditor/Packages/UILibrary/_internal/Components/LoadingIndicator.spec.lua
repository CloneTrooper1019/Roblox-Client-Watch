return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local LoadingIndicator = require(script.Parent.LoadingIndicator)

	it("should create and destroy without errors", function()
		local element = Roact.createElement(MockWrapper, {}, {
			LoadingIndicator = Roact.createElement(LoadingIndicator),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
