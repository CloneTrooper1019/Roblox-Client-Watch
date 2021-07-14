return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath
	local Element = Rhodium.Element

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	local ScrollerPath = TestHelper.getMainScroller()
	local PreviewTabsRibbonPath = ScrollerPath:cat(XPath.new("PreviewSwizzle.ViewArea.PreviewFrame.PreviewTabsRibbon"))

	it("main tabs ribbon should exist", function()
		runRhodiumTest(function()
			expect(TestHelper.waitForXPathInstance(PreviewTabsRibbonPath)).to.be.ok()
		end)
	end)

	it("avatar button should be initially selected after selecting an editing item", function()
		runRhodiumTest(function()
			TestHelper.addLCItemWithoutCageFromExplorer() -- an editing item makes tabs selectable

			local avatarButtonPath = PreviewTabsRibbonPath:cat(XPath.new("1 TAB_KEY_Avatars"))
			expect(TestHelper.waitForXPathInstance(avatarButtonPath)).to.be.ok()

			local avatarButtonTextButtonPath = avatarButtonPath:cat(XPath.new("1.Contents.TextButton"))
			expect(TestHelper.waitForXPathInstance(avatarButtonTextButtonPath)).to.be.ok()

			local avatarButtonTopLine = avatarButtonTextButtonPath:cat(XPath.new("TopLine"))
			expect(TestHelper.waitForXPathInstance(avatarButtonTopLine)).to.be.ok()
		end)
	end)

	it("clothes button should be selected after clicking it", function()
		runRhodiumTest(function()
			TestHelper.addLCItemWithoutCageFromExplorer() -- an editing item makes tabs selectable

			local clothesButtonPath = PreviewTabsRibbonPath:cat(XPath.new("2 TAB_KEY_Clothing"))
			expect(TestHelper.waitForXPathInstance(clothesButtonPath)).to.be.ok()

			local clothesButtonTextButtonPath = clothesButtonPath:cat(XPath.new("1.Contents.TextButton"))
			expect(TestHelper.waitForXPathInstance(clothesButtonTextButtonPath)).to.be.ok()

			local clothesButtonBottomLine = clothesButtonTextButtonPath:cat(XPath.new("BottomLine"))
			expect(TestHelper.waitForXPathInstance(clothesButtonBottomLine)).to.be.ok()

			local clothesButtonTopLine = clothesButtonTextButtonPath:cat(XPath.new("TopLine"))

			TestHelper.clickXPath(clothesButtonTextButtonPath)
			expect(TestHelper.waitForXPathInstance(clothesButtonTopLine)).to.be.ok()

		end)
	end)
end