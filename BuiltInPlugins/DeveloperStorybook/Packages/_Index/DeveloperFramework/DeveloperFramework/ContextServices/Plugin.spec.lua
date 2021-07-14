return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local provide = require(Framework.ContextServices.provide)

	local Plugin = require(script.Parent.Plugin)

	it("should be providable as a ContextItem", function()
		local plugin = Plugin.new({})
		local element = provide({plugin}, {
			Frame = Roact.createElement("Frame"),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should return the plugin via get", function()
		local test = {}
		local plugin = Plugin.new(test)
		expect(plugin:get()).to.equal(test)
	end)
end