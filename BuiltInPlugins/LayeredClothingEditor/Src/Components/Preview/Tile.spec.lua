return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local Tile = require(script.Parent.Tile)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(Tile, {
			OnClick = function()
			end,
			Text = "test"
		}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(Tile, {
				OnClick = function()
				end,
				Text = "test"
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local contents = frame.Contents
				local decoration = frame.Decoration
				local textButton = frame.Contents.TextButton
				local imageFrame = frame.Contents.TextButton.ImageFrame
				local image = frame.Contents.TextButton.ImageFrame.Image

				expect(frame).to.be.ok()
				expect(contents).to.be.ok()
				expect(decoration).to.be.ok()
				expect(textButton).to.be.ok()
				expect(imageFrame).to.be.ok()
				expect(image).to.be.ok()
			end
		)
	end)
end