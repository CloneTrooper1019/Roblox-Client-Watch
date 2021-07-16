return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local Rodux = require(Framework.Parent.Rodux)
	local provide = require(Framework.ContextServices.provide)

	local Store = require(script.Parent.Store)

	it("should expect a Rodux store", function()
		expect(function()
			Store.new()
		end).to.throw()
	end)

	it("should be providable as a ContextItem", function()
		local storeObject = Rodux.Store.new(function()
		end)
		local store = Store.new(storeObject)

		local element = provide({store}, {
			Frame = Roact.createElement("Frame"),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end