return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local ControlsPanelBlocker = require(script.Parent.ControlsPanelBlocker)

	local function createControlsPanelBlocker()
		return Roact.createElement(ControlsPanelBlocker, {
			Text = "test",
			OnFocused = function()
			end,
		})
	end

	it("should mount and unmount", function()
		runComponentTest(createControlsPanelBlocker())
	end)
end