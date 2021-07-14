return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	it("root should exist", function()
		runRhodiumTest(function()
			local rootPath = XPath.new("game.CoreGui.PluginMockGui")
			expect(TestHelper.waitForXPathInstance(rootPath)).to.be.ok()
		end)
	end)

	it("layered clothing editor should exist", function()
		runRhodiumTest(function()
			local rootPath = XPath.new("game.CoreGui.PluginMockGui")
			expect(TestHelper.waitForXPathInstance(rootPath)).to.be.ok()

			local layeredClothingEditorPath = rootPath:cat(XPath.new("LayeredClothingEditor"))
			expect(TestHelper.waitForXPathInstance(layeredClothingEditorPath)).to.be.ok()
		end)
	end)

	it("scroller should exist", function()
		runRhodiumTest(function()
			local scrollerPath = TestHelper.getMainScroller()
			expect(TestHelper.waitForXPathInstance(scrollerPath)).to.be.ok()
		end)
	end)
end