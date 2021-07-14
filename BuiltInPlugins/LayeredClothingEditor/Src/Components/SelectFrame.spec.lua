return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local SelectFrame = require(script.Parent.SelectFrame)

	local function createSelectFrame()
		return Roact.createElement(SelectFrame, {
			PartName = "Test",
			ButtonEnabled = false,
			OnConfirmSelection = function() end,
		})
	end

	it("should mount and unmount", function()
		runComponentTest(createSelectFrame())
	end)

	it("should render correctly", function ()
		runComponentTest(
			createSelectFrame(),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local content = frame.ViewArea.Content
				local selectPartFrameLayout = content.Layout
				local textBoxLabel = content.TextBoxLabel
				local selectedPartBox = content.SelectedPartBox

				expect(frame).to.be.ok()
				expect(content).to.be.ok()
				expect(selectPartFrameLayout).to.be.ok()
				expect(selectedPartBox).to.be.ok()
				expect(textBoxLabel).to.be.ok()
			end
		)
	end)

end