return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local PreviewFrame = require(script.Parent.PreviewFrame)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(PreviewFrame, {
			Size = UDim2.new(1, 0, 1, 0),
			UpdateUserAddedAssets = function() end,
			UserAddedAssets = {}
		}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(PreviewFrame, {
				Size = UDim2.new(1, 0, 1, 0),
				UpdateUserAddedAssets = function() end,
				UserAddedAssets = {}
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local uiListLayout = frame.UIListLayout
				local grid = frame.Grid
				local PreviewTabsRibbon = frame.PreviewTabsRibbon
				local selectionControls = frame.SelectionControls

				expect(frame).to.be.ok()
				expect(uiListLayout).to.be.ok()
				expect(grid).to.be.ok()
				expect(PreviewTabsRibbon).to.be.ok()
				expect(selectionControls).to.be.ok()
			end
		)
	end)
end