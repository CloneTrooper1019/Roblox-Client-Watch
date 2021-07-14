return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local EditingModeRadioButtonList = require(script.Parent.EditingModeRadioButtonList)

	local function createEditingModeRadioButtonList()
		return Roact.createElement(EditingModeRadioButtonList, {
			LayoutOrder = 1,
			Size = UDim2.new(0, 20, 0, 20),
		})
	end

	it("should mount and unmount", function()
		runComponentTest(createEditingModeRadioButtonList())
	end)

	it("should render correctly", function ()
		runComponentTest(
			createEditingModeRadioButtonList(),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local layout = frame.Layout
				local Outer = frame.Outer
				local Inner = frame.Inner
				local Mesh = frame.Mesh
				expect(frame).to.be.ok()
				expect(layout).to.be.ok()
				expect(Outer).to.be.ok()
				expect(Inner).to.be.ok()
				expect(Mesh).to.be.ok()
			end
		)
	end)

end