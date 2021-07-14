return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	local Constants = require(Plugin.Src.Util.Constants)

	local SelectRbfPoint = require(Plugin.Src.Thunks.SelectRbfPoint)

	local ScrollerPath = TestHelper.getMainScroller()
	local EditorFrame = ScrollerPath:cat(XPath.new("EditSwizzle.ViewArea.EditorFrame"))

	local PointToolTabButton =
		EditorFrame:cat(XPath.new("TabsRibbon.2 PointTool.1.Contents.TextButton"))

	local LatticeToolTabButton =
		EditorFrame:cat(XPath.new("TabsRibbon.1 LatticeTool.1.Contents.TextButton"))

	local PointToolSettings =
		EditorFrame:cat(XPath.new("SettingView.PointToolSettings"))

	local FalloffInput =
			PointToolSettings:cat(XPath.new("FalloffSetting.SliderContainer.ValueTextBoxFrame.ValueTextBox.Contents.TextBox"))

	local function selectPoint(store)
		TestHelper.addLCItemWithFullCageFromExplorer()
		TestHelper.clickXPath(PointToolTabButton)
		local state = store:getState()
		expect(state.status.toolMode).to.equal(Constants.TOOL_MODE.Point)

		store:dispatch(SelectRbfPoint({
			{
				Deformer = "RightHand",
				Index = 1,
			}
		}))
	end

	it("Tool Button should be inactive if avatar has no cages", function()
		runRhodiumTest(function(container, store)
			expect(TestHelper.waitForXPathInstance(PointToolTabButton)).to.be.ok()
			TestHelper.clickXPath(PointToolTabButton)
			local state = store:getState()
			expect(state.status.toolMode).to.equal(Constants.TOOL_MODE.None)
		end)
	end)

	itSKIP("Changing falloff value should change selected points and their weight", function()
		runRhodiumTest(function(container, store)
			selectPoint(store)

			expect(TestHelper.waitForXPathInstance(FalloffInput)).to.be.ok()

			-- default is 0.5
			local state = store:getState()
			expect(#state.pointTool.clickedPoints).to.equal(1)
			expect(state.pointTool.selectedPoints["RightHand"][1]).to.equal(1)
			local multiplePoints = false
			for deformer, pointsPerDeformer in pairs(state.pointTool.selectedPoints) do
				for pointIndex, weight in pairs(pointsPerDeformer) do
					if deformer ~= "RightHand" and pointIndex ~= 1 then
						multiplePoints = true
						expect(weight >= 0 and weight < 1).to.equal(true)
					end
				end
			end
			expect(multiplePoints).to.equal(true)

			TestHelper.sendInputToXPath(FalloffInput, 0)
			state = store:getState()
			expect(#state.pointTool.clickedPoints).to.equal(1)
			expect(state.pointTool.selectedPoints["RightHand"][1]).to.equal(1)

			TestHelper.sendInputToXPath(FalloffInput, 20)
			state = store:getState()
			expect(#state.pointTool.clickedPoints).to.equal(1)
			expect(state.pointTool.selectedPoints["RightHand"][1]).to.equal(1)
			local count = 0
			for _, pointsPerDeformer in pairs(state.pointTool.selectedPoints) do
				for _, weight in pairs(pointsPerDeformer) do
					count = count + 1
				end
			end
			expect(count).to.equal(565)
		end)
	end)

	itSKIP("Changing tool should deselect points", function()
		runRhodiumTest(function(container, store)
			selectPoint(store)
			TestHelper.clickXPath(LatticeToolTabButton)

			local state = store:getState()
			expect(state.status.toolMode).to.equal(Constants.TOOL_MODE.Lattice)
			expect(next(state.pointTool.clickedPoints)).to.equal(nil)
			expect(next(state.pointTool.selectedPoints)).to.equal(nil)
		end)
	end)
end