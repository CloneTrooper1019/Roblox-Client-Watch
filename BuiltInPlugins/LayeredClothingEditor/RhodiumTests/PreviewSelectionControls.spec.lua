return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest
	local PluginTheme = require(Plugin.Src.Resources.PluginTheme)
	local isProductionEnvironment = require(Plugin.Src.Util.isProductionEnvironment)

	local ScrollerPath = TestHelper.getMainScroller()
	local editSwizzlePath = ScrollerPath:cat(XPath.new("EditSwizzle.TopBar.DoubleClickDetector.Swizzle"))
	local previewTabsFramePath = ScrollerPath:cat(XPath.new("PreviewSwizzle.ViewArea.PreviewFrame"))
	local previewAnimationTabPath =
		previewTabsFramePath:cat(XPath.new("PreviewTabsRibbon.3 TAB_KEY_Animations.1.Contents.TextButton"))
	local selectionControlsPath = previewTabsFramePath:cat(XPath.new("SelectionControls"))
	local previewTransparencySliderPath = selectionControlsPath:cat(XPath.new("Transparency"))
	local previewAnimationSliderPath = selectionControlsPath:cat(XPath.new("AnimPlaybackSlider"))
	local playPauseButtonPath = previewAnimationSliderPath:cat(XPath.new("PlayPauseButton"))
	local playTimeLabelPath = previewAnimationSliderPath:cat(XPath.new("PlayTimeLabel"))
	local GridPath = ScrollerPath:cat(XPath.new("PreviewSwizzle.ViewArea.PreviewFrame.Grid"))
	local GridScrollerPath = GridPath:cat(XPath.new("ScrollingFrame.Contents.Scroller"))

	local gridSecondChildTextButtonPath = GridScrollerPath:cat(XPath.new("2.Contents.TextButton"))

	local theme = PluginTheme.getMockTheme("AnimPlaybackSlider")

	it("selection controls is empty when not select any editing item", function()
		runRhodiumTest(function()
			expect(#TestHelper.waitForXPathInstance(selectionControlsPath):GetChildren()).to.equal(0)
		end)
	end)

	it("selection controls shows transparency when select an avatar", function()
		runRhodiumTest(function()
			local avatar = TestHelper.createAvatarWithFullCages()
			TestHelper.addLCItemWithFullCageFromExplorer(avatar)
			expect(TestHelper.waitForXPathInstance(previewTransparencySliderPath)).to.be.ok()
		end)
	end)

	-- todo: when change transparency slider, clothes' transparency would change too
	-- add this when real lc clothes gets in

	it("animation playback slider exist when select avatar as editing item and select animation in preview", function()
		runRhodiumTest(function()
			local avatar = TestHelper.createAvatarWithFullCages()
			TestHelper.addLCItemWithFullCageFromExplorer(avatar)

			expect(TestHelper.waitForXPathInstance(previewAnimationTabPath)).to.be.ok()
			TestHelper.clickXPath(previewAnimationTabPath)
			expect(TestHelper.waitForXPathInstance(previewAnimationSliderPath)).to.be.ok()

			-- play pause button is set to play
			local playPauseButton = TestHelper.waitForXPathInstance(playPauseButtonPath)
			expect(playPauseButton).to.be.ok()
			expect(playPauseButton.Image).to.equal(theme.PlayImage)

			-- play time is 0
			local playTimeLabel = TestHelper.waitForXPathInstance(playTimeLabelPath)
			expect(playPauseButton).to.be.ok()
			expect(playTimeLabel.Text).to.equal("0.00 / 0.00")
		end)
	end)

	it("select an animation, slider would play automatically", function()
		runRhodiumTest(function()
			if not isProductionEnvironment() then -- certain animation will only exist on production
				return
			end
			local avatar = TestHelper.createAvatarWithFullCages()
			TestHelper.addLCItemWithFullCageFromExplorer(avatar)
			TestHelper.clickXPath(previewAnimationTabPath)

			-- select second tile(first one is add from explorer) would auto play
			TestHelper.clickXPath(gridSecondChildTextButtonPath)

			-- play pause button is set to pause
			local playPauseButton = TestHelper.waitForXPathInstance(playPauseButtonPath)
			expect(playPauseButton.Image).to.equal(theme.PauseImage)

			-- play time should show time
			local playTimeLabel = TestHelper.waitForXPathInstance(playTimeLabelPath)
			expect(TestHelper.waitForValid(function()
				return playTimeLabel.Text ~= "0.00 / 0.00"
			end)).to.equal(true)

			-- wait and play time label would change
			local firstStepTime = playTimeLabel.Text
			wait()
			local secondStepTime = playTimeLabel.Text
			expect(secondStepTime).never.equal(firstStepTime)
		end)
	end)

	it("click pause button, animation would pause", function()
		runRhodiumTest(function()
			if not isProductionEnvironment() then -- certain animation will only exist on production
				return
			end
			local avatar = TestHelper.createAvatarWithFullCages()
			TestHelper.addLCItemWithFullCageFromExplorer(avatar)
			TestHelper.clickXPath(previewAnimationTabPath)

			-- minimize edit swizzle in case UI is too big and cuts off animation slider
			TestHelper.clickXPath(editSwizzlePath)

			local playPauseButton = TestHelper.waitForXPathInstance(playPauseButtonPath)
			expect(playPauseButton.Image).to.equal(theme.PlayImage)

			-- select second tile(first one is add from explorer) would auto play
			TestHelper.clickXPath(gridSecondChildTextButtonPath)

			local pauseButton = TestHelper.waitForXPathInstance(playPauseButtonPath)
			expect(pauseButton.Image).to.equal(theme.PauseImage)

			-- click pause button
			TestHelper.clickXPath(playPauseButtonPath)

			local playButton = TestHelper.waitForXPathInstance(playPauseButtonPath)
			expect(playButton.Image).to.equal(theme.PlayImage)

			-- wait and play time label would not change
			local playTimeLabel = TestHelper.waitForXPathInstance(playTimeLabelPath)
			local firstStepTime = playTimeLabel.Text
			wait()
			local secondStepTime = playTimeLabel.Text
			expect(secondStepTime).to.equal(firstStepTime)
		end)
	end)

	it("deselct animation, it will stop playing", function()
		runRhodiumTest(function()
			if not isProductionEnvironment() then -- certain animation will only exist on production
				return
			end
			local avatar = TestHelper.createAvatarWithFullCages()
			TestHelper.addLCItemWithFullCageFromExplorer(avatar)
			TestHelper.clickXPath(previewAnimationTabPath)

			-- select second tile(first one is add from explorer) would auto play
			TestHelper.clickXPath(gridSecondChildTextButtonPath)

			-- deselect
			TestHelper.clickXPath(gridSecondChildTextButtonPath)

			-- play pause button is set to play
			local playPauseButton = TestHelper.waitForXPathInstance(playPauseButtonPath)
			expect(playPauseButton).to.be.ok()
			expect(playPauseButton.Image).to.equal(theme.PlayImage)

			-- play time is 0
			local playTimeLabel = TestHelper.waitForXPathInstance(playTimeLabelPath)
			expect(playPauseButton).to.be.ok()
			expect(playTimeLabel.Text).to.equal("0.00 / 0.00")
		end)
	end)
end