return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath
	local Element = Rhodium.Element

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	local PreviewConstants = require(Plugin.Src.Util.PreviewConstants)
	local PreviewConstantsInterface = require(Plugin.Src.Util.PreviewConstantsInterface)

	local isProductionEnvironment = require(Plugin.Src.Util.isProductionEnvironment)

	local SelectPreviewTab = require(Plugin.Src.Actions.SelectPreviewTab)

	local ScrollerPath = TestHelper.getMainScroller()
	local GridPath = ScrollerPath:cat(XPath.new("PreviewSwizzle.ViewArea.PreviewFrame.Grid"))
	local GridScrollerPath = GridPath:cat(XPath.new("ScrollingFrame.Contents.Scroller"))

	local function isSelected(instance)
		return 0 == instance.Decoration.BackgroundTransparency
	end

	local function getScrollerChildInstanceAndButtonPath(index)
		local gridScrollerChildPath = GridScrollerPath:cat(XPath.new(tostring(index)))
		local buttonPath = gridScrollerChildPath:cat(XPath.new("Contents.TextButton"))
		return {
			instance = TestHelper.waitForXPathInstance(gridScrollerChildPath),
			buttonPath = buttonPath
		}
	end

	it("grid should exist", function()
		runRhodiumTest(function()
			expect(TestHelper.waitForXPathInstance(GridPath)).to.be.ok()
		end)
	end)

	it("grid scroller should exist", function()
		runRhodiumTest(function()
			expect(TestHelper.waitForXPathInstance(GridScrollerPath)).to.be.ok()
		end)
	end)

	it("no tiles should be initially selected", function()
		runRhodiumTest(function()
			-- start at 2 as the LayoutOrder is reused for the child table index, and LayoutOrder 1 is the add from explorer tile
			local tileIndex = 2
			local gridScrollerChildPath = GridScrollerPath:cat(XPath.new(tostring(tileIndex)))
			while gridScrollerChildPath:getFirstInstance() do
				expect(isSelected(gridScrollerChildPath:getFirstInstance())).to.equal(false)

				tileIndex = tileIndex + 1
				gridScrollerChildPath = GridScrollerPath:cat(XPath.new(tostring(tileIndex)))
			end
		end)
	end)

	it("the 2nd tile should be selected after clicking it", function()
		runRhodiumTest(function()
			if not isProductionEnvironment() then -- grid tiles will only exist on production
				return
			end

			TestHelper.addLCItemWithoutCageFromExplorer() -- an editing item makes tabs selectable

			expect(isSelected(TestHelper.getEquippableGridTileInstance(1))).to.equal(false)
			TestHelper.clickEquippableGridTile(1)
			expect(isSelected(TestHelper.getEquippableGridTileInstance(1))).to.equal(true)
		end)
	end)

	it("the 3rd tile should be selected after clicking, and the 2nd tile deselected when not multi-select", function()
		runRhodiumTest(function(_, store)
			if not isProductionEnvironment() then -- grid tiles will only exist on production
				return
			end

			TestHelper.addLCItemWithoutCageFromExplorer() -- an editing item makes tabs selectable

			-- check the starting state is what we expect
			local state = store:getState()
			local selectedTab = state.previewStatus.selectedTab
			expect(selectedTab).to.equal(PreviewConstants.TABS_KEYS.Avatars)
			expect(PreviewConstantsInterface.isTabMultiSelect(selectedTab)).to.equal(false)

			-- get the second grid tile and click it
			local secondChild = getScrollerChildInstanceAndButtonPath(2)
			expect(isSelected(secondChild.instance)).to.equal(false)
			TestHelper.clickXPath(secondChild.buttonPath)
			expect(isSelected(secondChild.instance)).to.equal(true)

			-- get the third grid tile and click it
			local thirdChild = getScrollerChildInstanceAndButtonPath(3)
			expect(isSelected(thirdChild.instance)).to.equal(false)
			TestHelper.clickXPath(thirdChild.buttonPath)

			-- check final state - only a single tile is selected
			expect(isSelected(secondChild.instance)).to.equal(false)
			expect(isSelected(thirdChild.instance)).to.equal(true)
		end)
	end)

	it("the 3rd tile should be selected after clicking it, and the 2nd tile still selected, when multi-select", function()
		runRhodiumTest(function(_, store)
			if not isProductionEnvironment() then -- grid tiles will only exist on production
				return
			end

			TestHelper.addLCItemWithoutCageFromExplorer() -- an editing item makes tabs selectable

			-- change to a multi-select tab
			store:dispatch(SelectPreviewTab(PreviewConstants.TABS_KEYS.Clothing))

			-- check the starting state is what we expect
			local state = store:getState()
			local selectedTab = state.previewStatus.selectedTab
			expect(selectedTab).to.equal(PreviewConstants.TABS_KEYS.Clothing)
			expect(PreviewConstantsInterface.isTabMultiSelect(selectedTab)).to.equal(true)

			-- get the second grid tile and click it
			local secondChild = getScrollerChildInstanceAndButtonPath(2)
			expect(isSelected(secondChild.instance)).to.equal(false)
			TestHelper.clickXPath(secondChild.buttonPath)
			expect(isSelected(secondChild.instance)).to.equal(true)

			-- get the third grid tile and click it
			local thirdChild = getScrollerChildInstanceAndButtonPath(3)
			expect(isSelected(thirdChild.instance)).to.equal(false)
			TestHelper.clickXPath(thirdChild.buttonPath)

			-- check final state - only a single tile is selected
			expect(isSelected(secondChild.instance)).to.equal(true)
			expect(isSelected(thirdChild.instance)).to.equal(true)
		end)
	end)

	it("there should be a tile for adding from explorer when required", function()
		runRhodiumTest(function(_, store)
			TestHelper.addLCItemWithoutCageFromExplorer() -- an editing item makes tabs selectable

			-- change to a tab with an 'add new' tile
			store:dispatch(SelectPreviewTab(PreviewConstants.TABS_KEYS.Avatars))

			-- check the tab change worked, and the data is what we expect
			local state = store:getState()
			local selectedTab = state.previewStatus.selectedTab
			expect(selectedTab).to.equal(PreviewConstants.TABS_KEYS.Avatars)

			local tabInfo = PreviewConstantsInterface.getTabInfo(selectedTab)
			expect(tabInfo.CanAddNew).to.equal(true)

			-- check state - an 'add new' tile is found
			local gridScrollerChildAddNewPath = GridScrollerPath:cat(XPath.new("AddNewTile"))
			expect(TestHelper.waitForXPathInstance(gridScrollerChildAddNewPath)).to.be.ok()
		end)
	end)

	it("clicking the tile to add from explorer should activate the controls panel blocker", function()
		runRhodiumTest(function(_, store)
			TestHelper.addLCItemWithoutCageFromExplorer() -- an editing item makes tabs selectable

			-- change to a tab with an 'add new' tile
			store:dispatch(SelectPreviewTab(PreviewConstants.TABS_KEYS.Avatars))

			local topLevelDetectorPath =
				XPath.new("game.CoreGui.PluginMockGui.TopLevelDetector")
			expect(topLevelDetectorPath:getFirstInstance()).to.equal(nil)

			local gridScrollerChildAddNewPath = GridScrollerPath:cat(XPath.new("AddNewTile"))
			expect(TestHelper.waitForXPathInstance(gridScrollerChildAddNewPath)).to.be.ok()

			TestHelper.clickXPath(gridScrollerChildAddNewPath)
			expect(TestHelper.waitForXPathInstance(topLevelDetectorPath)).to.be.ok()
		end)
	end)

	it("tile name should be correct", function()
		runRhodiumTest(function(_, store)
			if not isProductionEnvironment() then
				return
			end

			TestHelper.addLCItemWithoutCageFromExplorer() -- an editing item makes tabs selectable
			-- check the starting state is what we expect
			local state = store:getState()
			local selectedTab = state.previewStatus.selectedTab
			expect(selectedTab).to.equal(PreviewConstants.TABS_KEYS.Avatars)

			local gridScrollerChildPath = GridScrollerPath:cat(XPath.new(tostring(2)))
			local textLabelPath = gridScrollerChildPath:cat(XPath.new("Contents.TextButton.TextLabelFrame.TextLabel"))
			expect(TestHelper.waitForXPathInstance(textLabelPath)).to.be.ok()

			while "Merely's ROBLOX Tablet" ~= Element.new(textLabelPath):getAttribute("Text") do
				wait() --  we need to spin until the ui updates from getting the mock netwrok results back
			end
			-- check state, correct name used from makeMockNetworkLaer.lua
			expect(Element.new(textLabelPath):getAttribute("Text")).to.equal("Merely's ROBLOX Tablet")
		end)
	end)
end