return function()
	local Library = script.Parent.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local MockWrapper = require(Library.MockWrapper)

	local ToggleButton = require(script.Parent.ToggleButton)

	local function createTestToggleButton()
		return Roact.createElement(MockWrapper, {}, {
			ToggleButton = Roact.createElement(ToggleButton, {
				Size = UDim2.new(0, 20, 0, 20),
				Enabled = true,
				IsOn = true,

				OnClickedOn = function()
				end,

				OnClickedOff = function()
				end,
			}),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestToggleButton()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end