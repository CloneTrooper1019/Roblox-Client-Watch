return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath
	local Element = Rhodium.Element

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	local PreviewConstants = require(Plugin.Src.Util.PreviewConstants)

	local LayeredClothingEditorPreviewPath = XPath.new("game.Workspace.LayeredClothingEditorPreview")
	local ScrollerPath = TestHelper.getMainScroller()

	it("LayeredClothingEditorPreview folder should exist in Workspace", function()
		runRhodiumTest(function()
			expect(TestHelper.waitForXPathInstance(LayeredClothingEditorPreviewPath)).to.be.ok()
		end)
	end)

	it("clicking an avatar grid tile should put it in the scene", function()
		runRhodiumTest(function()
			TestHelper.addLCItemWithoutCageFromExplorer() -- a clothes item for editing makes grid options selectable

			-- make sure we have the LayeredClothingEditorPreview folder, and it initially has no children
			expect(TestHelper.waitForXPathInstance(LayeredClothingEditorPreviewPath)).to.be.ok()
			expect(#TestHelper.waitForXPathInstance(LayeredClothingEditorPreviewPath):GetChildren()).to.equal(0)

			TestHelper.addAvatarToGrid() -- calling TestHelper.addLCItemWithoutCageFromExplorer() earlier makes avatar tab active

			-- click the avatar tile created with TestHelper.addAvatarToGrid() to put it in the scene
			TestHelper.clickEquippableGridTile(1) -- click the tile added with TestHelper.addAvatarToGrid()
			local previewAvatarPath = LayeredClothingEditorPreviewPath:cat(XPath.new(PreviewConstants.PreviewAvatarName))
			expect(TestHelper.waitForXPathInstance(previewAvatarPath)).to.be.ok()
		end)
	end)

	it("clicking an avatar grid tile twice should put it in the scene, then remove it", function()
		runRhodiumTest(function()
			TestHelper.addLCItemWithoutCageFromExplorer() -- a clothes item for editing makes grid options selectable

			-- make sure we have the LayeredClothingEditorPreview folder, and it initially has no children
			expect(TestHelper.waitForXPathInstance(LayeredClothingEditorPreviewPath)).to.be.ok()
			expect(#TestHelper.waitForXPathInstance(LayeredClothingEditorPreviewPath):GetChildren()).to.equal(0)

			TestHelper.addAvatarToGrid() -- calling TestHelper.addLCItemWithoutCageFromExplorer() earlier makes avatar tab active

			-- click the avatar tile created with TestHelper.addAvatarToGrid() to put it in the scene
			TestHelper.clickEquippableGridTile(1) -- click the tile added with TestHelper.addAvatarToGrid()
			local previewAvatarPath = LayeredClothingEditorPreviewPath:cat(XPath.new(PreviewConstants.PreviewAvatarName))
			expect(TestHelper.waitForXPathInstance(previewAvatarPath)).to.be.ok()

			-- click the avatar tile again to remove it from the scene
			TestHelper.clickEquippableGridTile(1)
			expect(#TestHelper.waitForXPathInstance(LayeredClothingEditorPreviewPath):GetChildren()).to.equal(0)
		end)
	end)

	it("clicking a clothes grid tile should make it a child of the preview avatar", function()
		runRhodiumTest(function(_, store)
			TestHelper.addLCItemWithFullCageFromExplorer() -- a clothes item for editing makes grid options selectable

			-- make sure we have the LayeredClothingEditorPreview folder, and it initially has no children
			expect(TestHelper.waitForXPathInstance(LayeredClothingEditorPreviewPath)).to.be.ok()
			expect(#TestHelper.waitForXPathInstance(LayeredClothingEditorPreviewPath):GetChildren()).to.equal(0)

			TestHelper.addAvatarToGrid() -- calling TestHelper.addLCItemWithoutCageFromExplorer() earlier makes avatar tab active

			-- click the avatar tile created with TestHelper.addAvatarToGrid() to put it in the scene
			TestHelper.clickEquippableGridTile(1) -- click the tile added with TestHelper.addAvatarToGrid()
			local previewAvatarPath = LayeredClothingEditorPreviewPath:cat(XPath.new(PreviewConstants.PreviewAvatarName))
			expect(TestHelper.waitForXPathInstance(previewAvatarPath)).to.be.ok()

			-- change to the clothes tab
			local PreviewTabsRibbonPath = ScrollerPath:cat(XPath.new("PreviewSwizzle.ViewArea.PreviewFrame.PreviewTabsRibbon"))
			local clothesButtonPath = PreviewTabsRibbonPath:cat(XPath.new("2 TAB_KEY_Clothing"))
			local clothesButtonDecorationPath = clothesButtonPath:cat(XPath.new("1.Decoration"))
			local clothesButtonTextButtonPath = clothesButtonPath:cat(XPath.new("1.Contents.TextButton"))

			local clothesButtonDecoration = Element.new(clothesButtonDecorationPath)
			TestHelper.clickXPath(clothesButtonTextButtonPath)
			expect(clothesButtonDecoration:getAttribute("BackgroundTransparency")).to.equal(0) -- clothes tab selected

			-- add a clothes item tile to the clothing grid
			TestHelper.addClothesItemToGrid()

			-- click the clothing grid tile we added with TestHelper.addClothesItemToGrid()
			TestHelper.clickEquippableGridTile(1)

			-- wait for the store to register the tile click
			expect(TestHelper.waitForValid(function()
				return nil ~= next(store:getState().previewStatus.selectedAssets[PreviewConstants.TABS_KEYS.Clothing])
			end)).to.equal(true)

			-- check the correct item exists as a child of the preview avatar
			local clothesItemName = next(store:getState().previewStatus.selectedAssets[PreviewConstants.TABS_KEYS.Clothing])
			local avatarClothesItemPath = XPath.new(PreviewConstants.PreviewAvatarName .. "." .. tostring(clothesItemName))
			local avatarClothesItem = LayeredClothingEditorPreviewPath:cat(avatarClothesItemPath)
			expect(TestHelper.waitForXPathInstance(avatarClothesItem)).to.be.ok()
		end)
	end)
end