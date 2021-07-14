return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local ResetSettings = require(script.Parent.ResetSettings)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(ResetSettings, {
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 1,
		}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(ResetSettings, {
				Size = UDim2.new(1, 0, 1, 0),
				LayoutOrder = 1,
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local button = frame.Button

				expect(frame).to.be.ok()
				expect(button).to.be.ok()
			end
		)
	end)
end