return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local mapToProps = require(Framework.ContextServices.mapToProps)
	local provide = require(Framework.ContextServices.provide)

	local API = require(script.Parent.API)

	it("should construct just fine with no arguments", function()
		local apiContext = API.new()
		expect(apiContext).to.be.ok()
	end)

	it("should be providable as a ContextItem", function()
		local apiContext = API.new()

		local element = provide({apiContext}, {
			Frame = Roact.createElement("Frame"),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should be consumable as a ContextItem", function()
		local didRender = false

		local TestElement = Roact.Component:extend("TestElement")
		function TestElement:render()
			didRender = true

			local apiImpl = self.props.api:get()
			local requestObj = apiImpl.Develop.V1.plugin({123})
			expect(type(requestObj)).to.equal("table")
			expect(type(requestObj:getUrl())).to.equal("string")

			return Roact.createElement("Frame")
		end
		mapToProps(TestElement, {
			api = API,
		})

		local element = provide({ API.new()	},{
			TestElement = Roact.createElement(TestElement)
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)

		expect(didRender).to.equal(true)
	end)
end