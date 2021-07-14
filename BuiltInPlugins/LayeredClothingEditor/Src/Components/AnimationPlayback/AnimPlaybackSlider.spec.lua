return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local AnimPlaybackSlider = require(script.Parent.AnimPlaybackSlider)

	local function createAnimPlaybackSlider()
		return Roact.createElement(AnimPlaybackSlider, {
			Size = UDim2.new(0, 20, 0, 20),
		})
	end

	it("should create and destroy without errors", function()
		runComponentTest(createAnimPlaybackSlider())
	end)

	it("should render correctly", function ()
		runComponentTest(
			createAnimPlaybackSlider(),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local PlayPauseButton = frame.PlayPauseButton
				local PlayTimeLabel = frame.PlayTimeLabel
				expect(frame).to.be.ok()
				expect(PlayPauseButton).to.be.ok()
				expect(PlayTimeLabel).to.be.ok()
			end
		)
	end)
end