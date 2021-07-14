return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local SelectItemScreen = require(script.Parent.SelectItemScreen)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(SelectItemScreen, {
			GoToNext = function() end,
			GoToPrevious = function() end,
		}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(SelectItemScreen, {
				GoToNext = function() end,
				GoToPrevious = function() end,
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local selectFrame = frame.SelectFrame

				expect(frame).to.be.ok()
				expect(selectFrame).to.be.ok()
			end
		)
	end)
end