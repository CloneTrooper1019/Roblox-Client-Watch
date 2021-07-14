return function()
	local Library = script.Parent.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local MediaControl = require(Library.Components.Preview.MediaControl)

	local function createTestAsset(container, name)
		local emptyFunc = function() end

		local element = Roact.createElement(MockWrapper, {}, {
			Roact.createElement(MediaControl, {
				AnchorPoint = Vector2.new(0, 0),
				IsPlaying = false,
				IsLoaded = true,
				LayoutOrder = 1,
				OnPause = emptyFunc,
				OnPlay = emptyFunc,
				Position = UDim2.new(0, 0, 0, 0),
				ShowTreeView = false,
				TimeLength = 1,
				TimePassed = 0,
			})
		})

		return Roact.mount(element, container or nil, name or "")
	end

	it("should create and destroy without errors", function()
		local instance = createTestAsset()
		Roact.unmount(instance)
	end)
end