return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath

	local GetTransparency = require(Plugin.Src.Util.GetTransparency)

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	local Constants = require(Plugin.Src.Util.Constants)
	local ModelUtil = require(Plugin.Src.Util.ModelUtil)

	local nearLimit = 1e-5 -- when set transparency, there might be some value precision issue

	local ScrollerPath = TestHelper.getMainScroller()
	local PointToolTabButton =
		ScrollerPath:cat(XPath.new("EditSwizzle.ViewArea.EditorFrame.TabsRibbon.2 PointTool.1.Contents.TextButton"))
	local TransparencyViewPath =
		ScrollerPath:cat(XPath.new("EditSwizzle.ViewArea.EditorFrame.TransparencyView"))
	local InnerCageValueTextBoxPath =
		TransparencyViewPath:cat(XPath.new("InnerCage.SliderContainer.ValueTextBoxFrame"))
	local OuterCageValueTextBoxPath =
		TransparencyViewPath:cat(XPath.new("OuterCage.SliderContainer.ValueTextBoxFrame"))
	local MeshValueTextBoxPath =
		TransparencyViewPath:cat(XPath.new("Mesh.SliderContainer.ValueTextBoxFrame"))
	local OuterCageRadioButton =
		ScrollerPath:cat(XPath.new("EditSwizzle.ViewArea.EditorFrame.EditingModeFrame.EditingModeRadioButtonList.Outer.RadioImage.Contents.TextButton"))
	local InnerCageRadioButton =
		ScrollerPath:cat(XPath.new("EditSwizzle.ViewArea.EditorFrame.EditingModeFrame.EditingModeRadioButtonList.Inner.RadioImage.Contents.TextButton"))
	local MeshRadioButton =
		ScrollerPath:cat(XPath.new("EditSwizzle.ViewArea.EditorFrame.EditingModeFrame.EditingModeRadioButtonList.Mesh.RadioImage.Contents.TextButton"))

	local function getTextBox(path)
		return path:cat(XPath.new("ValueTextBox.Contents.TextBox"))
	end

	it("transparency sliders exist", function()
		runRhodiumTest(function()
			expect(TestHelper.waitForXPathInstance(MeshValueTextBoxPath)).to.be.ok()
			expect(TestHelper.waitForXPathInstance(OuterCageValueTextBoxPath)).to.equal(nil)
			expect(TestHelper.waitForXPathInstance(InnerCageValueTextBoxPath)).to.equal(nil)
		end)
	end)

	it("change mesh transparency for clothes", function()
		runRhodiumTest(function(container, store)
			local fullCageClothes = TestHelper.addLCItemWithFullCageFromExplorer()
			local MeshValueTextPath = getTextBox(MeshValueTextBoxPath)
			expect(TestHelper.waitForXPathInstance(MeshValueTextPath)).to.be.ok()

			TestHelper.sendInputToXPath(MeshValueTextPath,"20")

			expect(TestHelper.waitForXPathInstance(MeshValueTextPath).Text).to.equal("20")
			expect(GetTransparency(fullCageClothes)).to.near(20, nearLimit)
		end)
	end)

	it("change inner cage transparency for clothes", function()
		runRhodiumTest(function(container, store)
			TestHelper.addLCItemWithFullCageFromExplorer()
			expect(TestHelper.waitForXPathInstance(PointToolTabButton)).to.be.ok()
			TestHelper.clickXPath(PointToolTabButton)
			expect(TestHelper.waitForXPathInstance(InnerCageRadioButton)).to.be.ok()
			TestHelper.clickXPath(InnerCageRadioButton)
			local InnerValueTextPath = getTextBox(InnerCageValueTextBoxPath)
			expect(TestHelper.waitForXPathInstance(InnerValueTextPath)).to.be.ok()
			TestHelper.sendInputToXPath(InnerValueTextPath,"20")
			local innerValueText = TestHelper.waitForXPathInstance(InnerValueTextPath)
			expect(TestHelper.waitForPropertyEqualTo(innerValueText,"Text","20")).to.equal(true)
		end)
	end)

	it("change outer cage transparency for clothes", function()
		runRhodiumTest(function()
			TestHelper.addLCItemWithFullCageFromExplorer()
			expect(TestHelper.waitForXPathInstance(PointToolTabButton)).to.be.ok()
			TestHelper.clickXPath(PointToolTabButton)
			expect(TestHelper.waitForXPathInstance(OuterCageRadioButton)).to.be.ok()
			TestHelper.clickXPath(OuterCageRadioButton)
			local OuterValueTextPath = getTextBox(OuterCageValueTextBoxPath)
			expect(TestHelper.waitForXPathInstance(OuterValueTextPath)).to.be.ok()

			TestHelper.sendInputToXPath(OuterValueTextPath,"20")
			local outerValueText = TestHelper.waitForXPathInstance(OuterValueTextPath)
			expect(TestHelper.waitForPropertyEqualTo(outerValueText,"Text","20")).to.equal(true)
		end)
	end)
end