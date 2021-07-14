return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local wrapMedia = require(script.Parent.wrapMedia)

	local function createTestComponent()
		local TEST_WRAPPER = Roact.PureComponent:extend("TEST_WRAPPER")
		function TEST_WRAPPER:render()
			return Roact.createElement("Frame")
		end
		return TEST_WRAPPER
	end

	it("should create and destroy without errors", function()
		local element = wrapMedia(createTestComponent())
		local component = Roact.createElement(element, {}, {})
		local instance = Roact.mount(component)

		Roact.unmount(instance)
	end)

	it("should add props into the component parameter", function()
		local hasNewProps
		local testComponent = createTestComponent()
		function testComponent:init()
			local expectedProps = {
				"_CurrentTime",
				"_IsPlaying",
				"_MediaPlayingUpdateSignal",
				"_OnMediaEnded",
				"_Pause",
				"_Play",
				"_SetCurrentTime",
			}
			hasNewProps = (self.props._CurrentTime ~= nil)
			for _,value in pairs(expectedProps) do
				hasNewProps = hasNewProps and (self.props[value] ~= nil)
			end
		end

		local element = wrapMedia(testComponent)
		local component = Roact.createElement(element, {}, {})
		local instance = Roact.mount(component)

		Roact.unmount(instance)
		expect(hasNewProps).to.be.equal(true)
	end)
end