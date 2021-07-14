-- TODO: Delete file when FFlagRemoveUILibraryTimeline is retired
return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local Keyframe = require(script.Parent.Keyframe)

	local function createTestKeyframe(enabled, selected)
		return Roact.createElement(MockWrapper, {}, {
			keyframe = Roact.createElement(Keyframe),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestKeyframe()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestKeyframe(), container)
		local frame = container:FindFirstChildOfClass("ImageButton")

		expect(frame).to.be.ok()

		Roact.unmount(instance)
	end)
end