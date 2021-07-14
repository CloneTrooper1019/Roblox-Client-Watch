return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	local ScrollerPath = TestHelper.getMainScroller()
	local SelectListPath =
		ScrollerPath:cat(XPath.new("SelectSwizzle.ViewArea.SelectFrame.SelectItemFrame.SelectItemList.Contents.Scroller"))

	local function getSelectionRowText(rowPath)
		return rowPath:cat(XPath.new("Contents.TextButton.Text"))
	end

	it("list exists with empty rows", function()
		runRhodiumTest(function()
			local selectList = TestHelper.waitForXPathInstance(SelectListPath)
			expect(selectList).to.be.ok()
			-- has one child layout
			expect(#selectList:GetChildren()).to.equal(1)
		end)
	end)

	it("exist one full cage avatar in workspace, list has one row with the same name", function()
		runRhodiumTest(function(_, store)
			local avatarName = "dummy"
			TestHelper.createAvatarWithFullCages(avatarName)
			local newRowPath = SelectListPath:cat(XPath.new("0"))
			expect(TestHelper.waitForXPathInstance(newRowPath)).to.be.ok()
			local newRowTextPath = getSelectionRowText(newRowPath)
			local newRowText = TestHelper.waitForXPathInstance(newRowTextPath)
			expect(newRowText).to.be.ok()
			expect(newRowText.Text).to.equal(avatarName)
		end)
	end)

	it("add an no cage avatar into list", function()
		runRhodiumTest(function(_, store)
			expect(#TestHelper.waitForXPathInstance(SelectListPath):GetChildren()).to.equal(1)
			TestHelper.addLCItemWithoutCageFromExplorer()
			expect(#TestHelper.waitForXPathInstance(SelectListPath):GetChildren()).to.equal(2)
		end)
	end)

	it("row name would change when the item's name changed", function()
		runRhodiumTest(function(_, store)
			local avatarName = "dummy"
			local avatarNewName = "dummyNew"
			local fullcageAvatar = TestHelper.createAvatarWithFullCages(avatarName)
			local newRowPath = SelectListPath:cat(XPath.new("0"))
			local newRowTextPath = getSelectionRowText(newRowPath)
			local newRowText = TestHelper.waitForXPathInstance(newRowTextPath)
			expect(newRowText.Text).to.equal(avatarName)
			fullcageAvatar.Name = avatarNewName
			expect(TestHelper.waitForPropertyEqualTo(newRowText, "Text", avatarNewName)).to.equal(true)
		end)
	end)

	it("destroy an item would delete it in list", function()
		runRhodiumTest(function(_, store)
			local fullcageAvatar = TestHelper.createAvatarWithFullCages()
			local newRowPath = SelectListPath:cat(XPath.new("0"))
			expect(TestHelper.waitForXPathInstance(newRowPath)).to.be.ok()
			fullcageAvatar:Destroy()
			local selectList = TestHelper.waitForXPathInstance(SelectListPath)
			expect(TestHelper.waitForChildrenCountEqualTo(selectList, 1)).to.equal(true)
		end)
	end)
	local ManuallyHideLayeredClothingItem = require(Plugin.Src.Thunks.ManuallyHideLayeredClothingItem)
	it("delete an item would delete it in list", function()
		runRhodiumTest(function(_, store)
			local fullcageAvatar = TestHelper.createAvatarWithFullCages()
			local newRowPath = SelectListPath:cat(XPath.new("0"))
			expect(TestHelper.waitForXPathInstance(newRowPath)).to.be.ok()
			store:dispatch(ManuallyHideLayeredClothingItem(fullcageAvatar))

			local selectList = TestHelper.waitForXPathInstance(SelectListPath)
			expect(TestHelper.waitForChildrenCountEqualTo(selectList, 1)).to.equal(true)
		end)
	end)

	it("select a row will select the editing item", function()
		runRhodiumTest(function(_, store)
			local fullcageAvatar = TestHelper.createAvatarWithFullCages()
			local newRow = SelectListPath:cat(XPath.new("0"))
			local newRowButton = newRow:cat(XPath.new("Contents.TextButton"))
			expect(TestHelper.waitForXPathInstance(newRowButton)).to.be.ok()
			TestHelper.clickXPath(newRowButton)
			store:flush()
			local state = store:getState()
			expect(state.selectItem.editingItem).to.equal(fullcageAvatar)
		end)
	end)
end