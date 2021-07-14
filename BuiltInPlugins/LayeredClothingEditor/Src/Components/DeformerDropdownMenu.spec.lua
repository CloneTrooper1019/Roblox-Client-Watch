return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local DeformerDropdownMenu = require(script.Parent.DeformerDropdownMenu)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(DeformerDropdownMenu, {
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 1,
			Deformer = "Head",
			OnDeformerSelected = function() end,
		}, {}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(DeformerDropdownMenu, {
				Size = UDim2.new(1, 0, 1, 0),
				LayoutOrder = 1,
				Deformer = "Head",
				OnDeformerSelected = function() end,
			}, {}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local label = frame.Label
				local dropdownContainer = frame.Container
				local dropdownFrame = dropdownContainer.DropdownFrame
				local selectedLabel = dropdownFrame.Contents.TextButton.SelectedLabel
				local downArrow = dropdownFrame.Contents.TextButton.DownArrow
				local menu = dropdownFrame.Contents.TextButton.Menu

				expect(frame).to.be.ok()
				expect(label).to.be.ok()
				expect(dropdownContainer).to.be.ok()
				expect(dropdownFrame).to.be.ok()
				expect(selectedLabel).to.be.ok()
				expect(downArrow).to.be.ok()
				expect(menu).to.be.ok()
			end
		)
	end)
end