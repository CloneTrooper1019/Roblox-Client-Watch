return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local SliderSetting = require(script.Parent.SliderSetting)

	local function render(value, usePercent, isDisabled)
		return Roact.createElement(SliderSetting, {
			Title = "test",
			Value = value,
			MaxValue = 20,
			Size = UDim2.new(100, 0, 0, 36),
			UsePercentage = usePercent,
			LayoutOrder = 1,
			IsDisabled = isDisabled,
			SetValue = function() end,
		})
	end

	it("should create and destroy without errors", function()
		runComponentTest(render(0, false, false))
	end)

	it("should render correctly", function ()
		runComponentTest(
			render(0, false, false),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local layout = frame.Layout
				local label = frame.Label
				local sliderContainer = frame.SliderContainer
				local sliderLayout = sliderContainer.Layout
				local valueTextBoxFrame = sliderContainer.ValueTextBoxFrame
				local valueTextBoxLayout = valueTextBoxFrame.Layout
				local valueTextBox = valueTextBoxFrame.ValueTextBox
				local percentageLabel = valueTextBoxFrame:FindFirstChild("PercentageLabel")
				local slider = sliderContainer.ValueSlider

				expect(frame).to.be.ok()
				expect(layout).to.be.ok()
				expect(label).to.be.ok()
				expect(sliderContainer).to.be.ok()
				expect(sliderLayout).to.be.ok()
				expect(valueTextBoxLayout).to.be.ok()
				expect(valueTextBox).to.be.ok()
				expect(percentageLabel).never.to.be.ok()
				expect(slider).to.be.ok()

				-- DevFramework TextInput Hierarchy
				expect(string.find(valueTextBox.Contents.TextBox.Text, "%%")).to.equal(nil)
			end
		)
	end)

	it("should display percent", function ()
		runComponentTest(
			render(0, true, false),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local sliderContainer = frame.SliderContainer
				local valueTextBoxFrame = sliderContainer.ValueTextBoxFrame
				local percentageLabel = valueTextBoxFrame.PercentageLabel

				expect(frame).to.be.ok()
				expect(percentageLabel).to.be.ok()
			end
		)
	end)
end