return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local AudioPreview = require(Library.Components.Preview.AudioPreview)

	local function createTestAsset(container, name)
		local element = Roact.createElement(MockWrapper, {}, {
			Roact.createElement(AudioPreview, {
				SoundId = 123,
				ReportPlay = function() end,
				ReportPause = function() end,
			})
		})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end