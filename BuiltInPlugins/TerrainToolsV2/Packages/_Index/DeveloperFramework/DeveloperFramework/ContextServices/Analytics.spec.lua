return function()
	local Framework = script.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local mapToProps = require(Framework.ContextServices.mapToProps)
	local provide = require(Framework.ContextServices.provide)

	local testEvent = "testEvent"

	local Analytics = require(script.Parent.Analytics)

	it("should be consumable as a ContextItem", function()
		local didRender = false
		local testEventReported = false

		local TestElement = Roact.Component:extend("TestElement")
		function TestElement:render()
			didRender = true

			self.props.Analytics:report("testEvent", "foo", "bar")

			return Roact.createElement("Frame")
		end

		mapToProps(TestElement, {
			Analytics = Analytics,
		})

		local rbxAnalyticsStub = {}
		local function createEventHandlers(rbxAnalyticsService)
			expect(rbxAnalyticsService).to.equal(rbxAnalyticsStub)
			return {
				[testEvent] = function(event, a, b)
					testEventReported = true
					expect(event).to.equal(testEvent)

					expect(a).to.equal("foo")
					expect(b).to.equal("bar")
				end
			}
		end

		local element = provide({ Analytics.new(createEventHandlers, rbxAnalyticsStub) }, {
			TestElement = Roact.createElement(TestElement)
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)

		expect(didRender).to.equal(true)
		expect(testEventReported).to.equal(true)
	end)

	it("throws if no event handler is registered for a reported event", function()
		local testAnalytics = Analytics.new(function() return {} end, {})

		expect(function()
			testAnalytics:report("blah")
		end).to.throw()
	end)

	it("throws if event handler table is invalid", function()
		expect(function()
			Analytics.new(function() return {"hello"} end, {})
		end).to.throw()
	end)

	describe("mock", function()

		it("constructs a mock with report callable with any event", function()
			local mock = Analytics.mock()

			mock:report("blah")

			expect(function()
				-- No event passed
				mock:report()
			end).to.throw()
		end)
	end)
end