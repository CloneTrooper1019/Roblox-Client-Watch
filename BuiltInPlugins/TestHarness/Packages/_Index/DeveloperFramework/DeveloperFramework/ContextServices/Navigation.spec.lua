return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local provide = require(Framework.ContextServices.provide)

	local Navigation = require(script.Parent.Navigation)

	it("should be providable as a ContextItem", function()
		local navigation = Navigation.new({})
		local element = provide({navigation}, {
			Frame = Roact.createElement("Frame"),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should return the navigation via get", function()
		local test = {}
		local navigation = Navigation.new(test)
		expect(navigation:get()).to.equal(test)
	end)
end