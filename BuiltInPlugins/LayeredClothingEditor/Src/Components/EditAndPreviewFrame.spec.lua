return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local EditAndPreviewFrame = require(script.Parent.EditAndPreviewFrame)

	local function createEditAndPreviewFrame()
		return Roact.createElement(EditAndPreviewFrame, {
			GoToNext = function() end,
			GoToPrevious = function() end,
		})
	end

	it("should mount and unmount", function()
		runComponentTest(createEditAndPreviewFrame())
	end)

	it("should render correctly", function ()
		runComponentTest(
			createEditAndPreviewFrame(),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local viewArea = frame.ViewArea

				local uiPadding_Main = viewArea.UIPadding
				local prompt = viewArea.Prompt
				local nextBackButtonContainer = viewArea.NextAndBackButtonContainer
				local nextButton = nextBackButtonContainer.NextButton
				local backButton = nextBackButtonContainer.BackButton

				expect(frame).to.be.ok()
				expect(viewArea).to.be.ok()
				expect(uiPadding_Main).to.be.ok()
				expect(prompt).to.be.ok()
				expect(backButton).to.be.ok()
				expect(nextButton).to.be.ok()
			end
		)
	end)

end