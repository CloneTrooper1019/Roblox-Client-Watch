return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	local Framework = require(Plugin.Packages.Framework)
	local ContextServices = Framework.ContextServices
	local Localization = ContextServices.Localization

	local ScrollerPath = TestHelper.getMainScroller()
	local AddItemFromExplorerButton =
		ScrollerPath:cat(XPath.new("SelectSwizzle.ViewArea.SelectFrame.SelectItemFrame.AddItemFromExplorerButton.ImageButton"))

	it("add button should exist", function()
		runRhodiumTest(function()
			expect(TestHelper.waitForXPathInstance(AddItemFromExplorerButton)).to.be.ok()
		end)
	end)

	it("clicking the button should activate the controls panel blocker, can click it again to cancel", function()
		runRhodiumTest(function(_, store)
			local topLevelDetectorPath = XPath.new("game.CoreGui.PluginMockGui.TopLevelDetector")
			expect(topLevelDetectorPath:getFirstInstance()).to.equal(nil)

			TestHelper.clickXPath(AddItemFromExplorerButton)
			expect(TestHelper.waitForXPathInstance(topLevelDetectorPath)).to.be.ok()

			TestHelper.clickXPath(AddItemFromExplorerButton)
			expect(topLevelDetectorPath:getFirstInstance()).to.equal(nil)
		end)
	end)

	it("select a full cage avatar and confirm should end selection", function()
		runRhodiumTest(function(_, store)
			local fullCageAvatar = TestHelper.createAvatarWithFullCages()

			TestHelper.clickXPath(AddItemFromExplorerButton)

			local Selection = game:GetService("Selection")
			Selection:Set({fullCageAvatar})
			TestHelper.delay()

			local localization = Localization.mock()
			local screenGuiName = localization:getText("Dialog","DefaultTitle")
			local dialogPath = XPath.new(game.CoreGui[screenGuiName])
			expect(TestHelper.waitForXPathInstance(dialogPath)).to.be.ok()

			--dialog should has 3 children, two buttons and a layout
			local dialogButtonsPath = dialogPath:cat(XPath.new("SolidBackground.ButtonContainer.Contents"))
			expect(TestHelper.waitForXPathInstance(dialogButtonsPath)).to.be.ok()
			expect(#TestHelper.waitForXPathInstance(dialogButtonsPath):GetChildren()).to.equal(3)

			--click confirm button would end selection
			local dialogConfirmButtonPath = dialogButtonsPath:cat(XPath.new("1.Contents.TextButton"))
			expect(TestHelper.waitForXPathInstance(dialogConfirmButtonPath)).to.be.ok()
			TestHelper.clickXPath(dialogConfirmButtonPath)
			expect(dialogPath:getFirstInstance()).to.equal(nil)
			local topLevelDetectorPath = XPath.new("game.CoreGui.PluginMockGui.TopLevelDetector")
			expect(topLevelDetectorPath:getFirstInstance()).to.equal(nil)
		end)
	end)

	it("select a avatar without cages and confirm should popup another dialog", function()
		runRhodiumTest(function(_, store)
			local noCageAvatar = TestHelper.createAvatarWithoutCages()

			TestHelper.clickXPath(AddItemFromExplorerButton)

			local Selection = game:GetService("Selection")
			Selection:Set({noCageAvatar})
			TestHelper.delay()

			local localization = Localization.mock()
			local screenGuiName = localization:getText("Dialog","DefaultTitle")
			local dialogPath = XPath.new(game.CoreGui[screenGuiName])
			expect(TestHelper.waitForXPathInstance(dialogPath)).to.be.ok()

			--dialog should has 3 children, two buttons and a layout
			local dialogButtonsPath = dialogPath:cat(XPath.new("SolidBackground.ButtonContainer.Contents"))
			expect(TestHelper.waitForXPathInstance(dialogButtonsPath)).to.be.ok()
			expect(#TestHelper.waitForXPathInstance(dialogButtonsPath):GetChildren()).to.equal(3)

			--click confirm button would pop up another dialog
			--click confirm again would end selection
			local dialogConfirmButtonPath = dialogButtonsPath:cat(XPath.new("1.Contents.TextButton"))
			expect(TestHelper.waitForXPathInstance(dialogConfirmButtonPath)).to.be.ok()
			TestHelper.clickXPath(dialogConfirmButtonPath)
			expect(TestHelper.waitForXPathInstance(dialogButtonsPath)).to.be.ok()
			expect(#TestHelper.waitForXPathInstance(dialogButtonsPath):GetChildren()).to.equal(2)
			TestHelper.clickXPath(dialogConfirmButtonPath)

			expect(dialogPath:getFirstInstance()).to.equal(nil)
			local topLevelDetectorPath = XPath.new("game.CoreGui.PluginMockGui.TopLevelDetector")
			expect(topLevelDetectorPath:getFirstInstance()).to.equal(nil)

		end)
	end)

	it("select a full cage avatar and cancel should keep selection", function()
		runRhodiumTest(function(_, store)
			local fullCageAvatar = TestHelper.createAvatarWithFullCages()

			TestHelper.clickXPath(AddItemFromExplorerButton)

			local Selection = game:GetService("Selection")
			Selection:Set({fullCageAvatar})
			TestHelper.delay()

			local localization = Localization.mock()
			local dialogName = localization:getText("Dialog","DefaultTitle")
			local dialogPath = XPath.new(game.CoreGui[dialogName])
			expect(TestHelper.waitForXPathInstance(dialogPath)).to.be.ok()

			--dialog should has 3 children, two buttons and a layout
			local dialogButtonsPath = dialogPath:cat(XPath.new("SolidBackground.ButtonContainer.Contents"))
			expect(TestHelper.waitForXPathInstance(dialogButtonsPath)).to.be.ok()
			expect(#TestHelper.waitForXPathInstance(dialogButtonsPath):GetChildren()).to.equal(3)

			--click cancel button would keep selection
			local dialogCancelButtonPath = dialogButtonsPath:cat(XPath.new("2.Contents.TextButton"))
			expect(TestHelper.waitForXPathInstance(dialogCancelButtonPath)).to.be.ok()
			TestHelper.clickXPath(dialogCancelButtonPath)

			expect(dialogPath:getFirstInstance()).to.equal(nil)
			local topLevelDetectorPath = XPath.new("game.CoreGui.PluginMockGui.TopLevelDetector")
			expect(TestHelper.waitForXPathInstance(topLevelDetectorPath)).to.be.ok()
		end)
	end)

	it("select a non avatar and confirm should keep selection", function()
		runRhodiumTest(function(_, store)
			local nonAvatar = TestHelper.createNonAvatar()

			TestHelper.clickXPath(AddItemFromExplorerButton)

			local Selection = game:GetService("Selection")
			Selection:Set({nonAvatar})
			TestHelper.delay()

			local localization = Localization.mock()
			local dialogName = localization:getText("Dialog","DefaultTitle")
			local dialogPath = XPath.new(game.CoreGui[dialogName])

			--dialog should has 2 children, 1 buttons and a layout
			local dialogButtonsPath = dialogPath:cat(XPath.new("SolidBackground.ButtonContainer.Contents"))
			expect(TestHelper.waitForXPathInstance(dialogButtonsPath)).to.be.ok()
			expect(#TestHelper.waitForXPathInstance(dialogButtonsPath):GetChildren()).to.equal(2)

			--click confirm button would keep selection
			local dialogConfirmButtonPath =
				dialogPath:cat(XPath.new("SolidBackground.ButtonContainer.Contents.1.Contents.TextButton"))
			expect(TestHelper.waitForXPathInstance(dialogConfirmButtonPath)).to.be.ok()
			TestHelper.clickXPath(dialogConfirmButtonPath)

			expect(dialogPath:getFirstInstance()).to.equal(nil)
			local topLevelDetectorPath = XPath.new("game.CoreGui.PluginMockGui.TopLevelDetector")
			expect(TestHelper.waitForXPathInstance(topLevelDetectorPath)).to.be.ok()
		end)
	end)
end