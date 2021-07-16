local FFlagTextInputDialogDevFramework = game:GetFastFlag("TextInputDialogDevFramework")
if not FFlagTextInputDialogDevFramework then
	return function() end
else
	return function()
		local Framework = script.Parent.Parent.Parent
		local Roact = require(Framework.Parent.Roact)
		local TextInputDialog = require(script.Parent)
		local TestHelpers = require(Framework.TestHelpers)

		it("should create and destroy without errors", function()
			local element = TestHelpers.provideMockContext(nil, {
				TextInputDialog = Roact.createElement(TextInputDialog, {
					Body = "Body",
					Buttons = {
						{ Key = "a", Text = "a"},
						{ Key = "b", Text = "b"},
					},
					OnButtonPressed = function(_,_) end,
					OnClose = function(_) end,
				})
			})

			local instance = Roact.mount(element)
			Roact.unmount(instance)
		end)
	end
end