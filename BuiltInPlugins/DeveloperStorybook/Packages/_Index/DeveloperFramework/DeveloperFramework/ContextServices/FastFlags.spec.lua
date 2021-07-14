return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local mapToProps = require(Framework.ContextServices.mapToProps)
	local provide = require(Framework.ContextServices.provide)

	local FastFlags = require(script.Parent.FastFlags)

	it("should construct just fine with no arguments", function()
		local flags = FastFlags.new()
		expect(flags).to.be.ok()
	end)

	it("should allow for simple mocking", function()
		local flags = FastFlags.mock(false)
		expect(flags).to.be.ok()
	end)

	it("should be providable as a ContextItem", function()
		local function testProvide(flagContextItem)
			local element = provide({flagContextItem}, {
				Frame = Roact.createElement("Frame"),
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end

		testProvide(FastFlags.new())
		
		testProvide(FastFlags.mock(false))
	end)

	it("should be consumable as a ContextItem", function()
		local didRender = false

		local TestElement = Roact.Component:extend("TestElement")
		function TestElement:render()
			didRender = true

			local fastFlags = self.props.flags
			local val = fastFlags:get("testFeatureName")
			expect(val).to.equal(true)			
			return Roact.createElement("Frame")
		end
		mapToProps(TestElement, {
			flags = FastFlags,
		})

		local fastFlagsMock = FastFlags.mock(false, {
			testFeatureName = true,
		})
		local element = provide({ fastFlagsMock },{
			TestElement = Roact.createElement(TestElement)
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)

		expect(didRender).to.equal(true)
	end)
end
