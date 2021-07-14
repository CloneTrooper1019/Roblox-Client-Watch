return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local Vector3Entry = require(script.Parent.Vector3Entry)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(Vector3Entry, {
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 1,
			Title = "Hello",
			Enabled = true,
			VectorValue = Vector3.new(1, 1, 1),
			OnVectorValueChanged = function() end,
		}, {}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(Vector3Entry, {
				Size = UDim2.new(1, 0, 1, 0),
				LayoutOrder = 1,
				Title = "Hello",
				Enabled = true,
				VectorValue = Vector3.new(1, 1, 1),
				OnVectorValueChanged = function() end,
			}, {}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local label = frame.Label
				local inputBoxes = frame.InputBoxes
				local inputBoxesLayout = inputBoxes.Layout

				local xInputFrame = inputBoxes.XInputFrame
				local xInput = xInputFrame.XInput

				local yInputFrame = inputBoxes.YInputFrame
				local yInput = yInputFrame.YInput

				local zInputFrame = inputBoxes.ZInputFrame
				local zInput = zInputFrame.ZInput

				expect(frame).to.be.ok()
				expect(label).to.be.ok()
				expect(inputBoxes).to.be.ok()
				expect(inputBoxesLayout).to.be.ok()
				expect(xInputFrame).to.be.ok()
				expect(xInput).to.be.ok()
				expect(yInputFrame).to.be.ok()
				expect(yInput).to.be.ok()
				expect(zInputFrame).to.be.ok()
				expect(zInput).to.be.ok()
			end
		)
	end)
end