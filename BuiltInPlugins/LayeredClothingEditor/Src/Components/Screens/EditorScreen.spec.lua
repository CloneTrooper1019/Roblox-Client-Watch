return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local EditorScreen = require(script.Parent.EditorScreen)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(EditorScreen, {
			GoToNext = function() end,
			GoToPrevious = function() end,
		}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(EditorScreen, {
				GoToNext = function() end,
				GoToPrevious = function() end,
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local mainFrame = frame.MainFrame
				local layout = mainFrame.UIListLayout
				local editAndPreviewContainer = mainFrame.EditAndPreviewContainer
				local editAndPreviewFrame = editAndPreviewContainer.EditAndPreviewFrame
				local editSwizzle = mainFrame.EditSwizzle
				local previewSwizzle = mainFrame.PreviewSwizzle

				expect(frame).to.be.ok()
				expect(layout).to.be.ok()
				expect(editAndPreviewContainer).to.be.ok()
				expect(editAndPreviewFrame).to.be.ok()
				expect(editSwizzle).to.be.ok()
				expect(previewSwizzle).to.be.ok()
			end
		)
	end)
end