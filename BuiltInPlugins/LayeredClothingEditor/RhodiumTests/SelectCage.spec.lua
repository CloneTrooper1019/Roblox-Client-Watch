return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	local Constants = require(Plugin.Src.Util.Constants)

	local ScrollerPath = TestHelper.getMainScroller()
	local SelectCageRadioButtonListPath =
		ScrollerPath:cat(XPath.new("EditSwizzle.ViewArea.EditorFrame.EditingModeFrame.EditingModeRadioButtonList"))
	local SelectInnerCageRadioButtonPath =
		SelectCageRadioButtonListPath:cat(XPath.new("Inner.RadioImage.Contents"))
	local SelectOuterCageRadioButtonPath =
		SelectCageRadioButtonListPath:cat(XPath.new("Outer.RadioImage.Contents"))

	it("cage selection buttons exist but non get selected", function()
		runRhodiumTest(function()
			local innerCageButton = TestHelper.waitForXPathInstance(SelectInnerCageRadioButtonPath)
			expect(innerCageButton).to.be.ok()
			local innerCageForegroundPath = SelectInnerCageRadioButtonPath:cat(XPath.new("Foreground"))
			expect(innerCageForegroundPath:getFirstInstance()).to.equal(nil)
			local outerCageButton = TestHelper.waitForXPathInstance(SelectOuterCageRadioButtonPath)
			expect(outerCageButton).to.be.ok()
			local outerCageForegroundPath = SelectOuterCageRadioButtonPath:cat(XPath.new("Foreground"))
			expect(outerCageForegroundPath:getFirstInstance()).to.equal(nil)
		end)
	end)

	it("select outer cage when select a full cage avatar", function()
		runRhodiumTest(function()
			local fullCageAvatar = TestHelper.createAvatarWithFullCages()
			TestHelper.addLCItemWithFullCageFromExplorer(fullCageAvatar)
			local outerCageForegroundPath = SelectOuterCageRadioButtonPath:cat(XPath.new("Foreground"))
			expect(TestHelper.waitForXPathInstance(outerCageForegroundPath)).to.be.ok()
		end)
	end)

	it("select cage would change selected button and value in store", function()
		runRhodiumTest(function(_, store)
			expect(store:getState().selectItem.editingCage).to.equal(nil)

			TestHelper.addLCItemWithFullCageFromExplorer()
			expect(store:getState().selectItem.editingCage).to.equal(Enum.CageType.Outer)
			TestHelper.selectCage(Enum.CageType.Inner)
			local innerCageForegroundPath = SelectInnerCageRadioButtonPath:cat(XPath.new("Foreground"))
			expect(TestHelper.waitForXPathInstance(innerCageForegroundPath)).to.be.ok()
			expect(store:getState().selectItem.editingCage).to.equal(Enum.CageType.Inner)
		end)
	end)
end