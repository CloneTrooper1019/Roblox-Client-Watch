return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local SwitchButton = require(script.Parent.SwitchButton)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(SwitchButton, {
			Text = "test",
			Size = UDim2.new(1, 0, 1, 0),
			IsEnabled = true,
			OnClick = function()
			end,
		}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(SwitchButton, {
				Text = "test",
				Size = UDim2.new(1, 0, 1, 0),
				IsEnabled = true,
				OnClick = function()
				end
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local contents = frame.Contents
				local decoration = frame.Decoration
				local textButton = frame.Contents.TextButton
				local textLabel = frame.Contents.TextButton.TextLabel
				local bottomLine = frame.Contents.TextButton.BottomLine

				expect(frame).to.be.ok()

				expect(contents).to.be.ok()
				expect(decoration).to.be.ok()
				expect(textButton).to.be.ok()
				expect(bottomLine).to.be.ok()
				expect(textLabel).to.be.ok()
			end
		)
	end)

	it("should render different borders if isOn", function ()
		runComponentTest(
			Roact.createElement(SwitchButton, {
				Text = "test",
				Size = UDim2.new(1, 0, 1, 0),
				IsEnabled = true,
				IsOn = true,
				OnClick = function()
				end
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local contents = frame.Contents
				local topLine = frame.Contents.TextButton.TopLine
				local leftLine = frame.Contents.TextButton.LeftLine
				local rightLine = frame.Contents.TextButton.RightLine

				expect(frame).to.be.ok()

				expect(contents).to.be.ok()
				expect(topLine).to.be.ok()
				expect(leftLine).to.be.ok()
				expect(rightLine).to.be.ok()
			end
		)
	end)
end