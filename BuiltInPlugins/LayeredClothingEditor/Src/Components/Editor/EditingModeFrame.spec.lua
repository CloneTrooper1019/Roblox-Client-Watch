return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local EditingModeFrame = require(script.Parent.EditingModeFrame)

	local function createEditingModeFrame()
		return Roact.createElement(EditingModeFrame, {
			LayoutOrder = 1,
			Size = UDim2.new(0, 20, 0, 20),
		})
	end

	it("should mount and unmount", function()
		runComponentTest(createEditingModeFrame())
	end)

	it("should render correctly", function ()
		runComponentTest(
			createEditingModeFrame(),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local layout = frame.Layout
				local Text = frame.Text
				local EditingModeRadioButtonList = frame.EditingModeRadioButtonList
				expect(frame).to.be.ok()
				expect(layout).to.be.ok()
				expect(Text).to.be.ok()
				expect(EditingModeRadioButtonList).to.be.ok()
			end
		)
	end)

end