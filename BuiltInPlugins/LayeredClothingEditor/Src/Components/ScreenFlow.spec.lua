return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local GenerateScreen = require(Plugin.Src.Components.Screens.GenerateScreen)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local ScreenFlow = require(script.Parent.ScreenFlow)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(ScreenFlow, {
			Screens = {GenerateScreen},
			GetNextIndex = function() end,
			GetPreviousIndex = function() end,
			OnScreenChanged = function() end
		}))
	end)

	it("should render correctly", function()
		runComponentTest(
			Roact.createElement(ScreenFlow, {
				Screens = {GenerateScreen},
				GetNextIndex = function() end,
				GetPreviousIndex = function() end,
				OnScreenChanged = function() end
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				expect(frame).to.be.ok()
			end
		)
	end)
end