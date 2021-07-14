return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local wrapDraggableMedia = require(script.Parent.wrapDraggableMedia)

	local function createTestComponent()
		local TEST_WRAPPER = Roact.PureComponent:extend("TEST_WRAPPER")
		function TEST_WRAPPER:render()
			return Roact.createElement("Frame")
		end
		return TEST_WRAPPER
	end

	it("should create and destroy without errors", function()
		local element = wrapDraggableMedia(createTestComponent())
		local component = Roact.createElement(element, {}, {})
		local instance = Roact.mount(component)

		Roact.unmount(instance)
	end)

	it("should add props into the component parameter", function()
		local hasNewProps
		local testComponent = createTestComponent()
		function testComponent:init()
			hasNewProps = (self.props._OnSliderInputChanged ~= nil)
			hasNewProps = hasNewProps and (self.props._OnSliderInputEnded ~= nil)
		end

		local element = wrapDraggableMedia(testComponent)
		local component = Roact.createElement(element, {}, {})
		local instance = Roact.mount(component)

		Roact.unmount(instance)
		expect(hasNewProps).to.be.equal(true)
	end)
end