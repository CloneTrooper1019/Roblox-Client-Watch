return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local SelectionControls = require(script.Parent.SelectionControls)

	local function createSelectionControls()
		return Roact.createElement(SelectionControls, {
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 1,
		})
	end

	it("should mount and unmount", function()
		runComponentTest(createSelectionControls())
	end)

	it("should render correctly", function ()
		runComponentTest(
			createSelectionControls(),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local Transparency = frame.Transparency
				expect(frame).to.be.ok()
				expect(Transparency).to.be.ok()
			end
		)
	end)
end