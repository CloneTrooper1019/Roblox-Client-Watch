return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local StyledDialog = require(script.Parent)
	local TestHelpers = require(Framework.TestHelpers)

	it("should create and destroy without errors", function()
		local element = TestHelpers.provideMockContext(nil, {
			StyledDialog = Roact.createElement(StyledDialog, {
				Title = "Test",
				MinContentSize = Vector2.new(200, 200),
				Buttons = {
					{ Key = "a", String = "a", Style = "RoundPrimary" }
				},
				OnButtonPressed = function(_) end,
				OnClose = function() end,
			}, {
				Message = Roact.createElement("TextLabel")
			})
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	describe("Other Styles", function()
		it("should render properly for Alert", function()
			local element = TestHelpers.provideMockContext(nil, {
				StyledDialog = Roact.createElement(StyledDialog, {
					Title = "Test2",
					MinContentSize = Vector2.new(400, 400),
					Buttons = {
						{ Key = "ono", String = "oh dang" }
					},
					Style = "Alert",
					OnButtonPressed = function(_) end,
					OnClose = function() end,
				})
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)

		it("should render properly for AcceptCancel", function()
			local element = TestHelpers.provideMockContext(nil, {
				StyledDialog = Roact.createElement(StyledDialog, {
					Title = "Test3",
					MinContentSize = Vector2.new(400, 400),
					Buttons = {
						{ Key = "accept", String = "Accept" },
						{ Key = "cancel", String = "Cancel" },
					},
					Style = "AcceptCancel",
					OnButtonPressed = function(_) end,
					OnClose = function() end,
				})
			})
			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end)
end
