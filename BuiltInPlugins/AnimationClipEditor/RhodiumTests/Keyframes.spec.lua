return function()
	local Plugin = script.Parent.Parent
	local isEmpty = require(Plugin.Src.Util.isEmpty)
	local Constants = require(Plugin.Src.Util.Constants)

	local ValueChanged = require(Plugin.Src.Thunks.ValueChanged)
	local DeleteSelectedKeyframes = require(Plugin.Src.Thunks.Selection.DeleteSelectedKeyframes)
	local CopySelectedKeyframes = require(Plugin.Src.Thunks.Selection.CopySelectedKeyframes)
	local PasteKeyframes = require(Plugin.Src.Thunks.PasteKeyframes)

	local Framework = require(Plugin.Packages.Framework)

	local Analytics = Framework.ContextServices.Analytics


	local TestHelpers = require(Plugin.RhodiumTests.TestHelpers)
	local TestPaths = require(Plugin.RhodiumTests.TestPaths)
	local VirtualInput = require(Plugin.Rhodium.VirtualInput)
	local Element = require(Plugin.Rhodium.Element)
	local runTest = TestHelpers.runTest

	local Templates = require(Plugin.Src.Util.Templates)

	local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

	local emptyData = Templates.animationData()
	local testAnimationData = Templates.animationData()

	testAnimationData.Instances = {
		Root = {
			Tracks = {
				Head = {
					Type = GetFFlagFacialAnimationSupport() and Constants.TRACK_TYPES.CFrame or nil,
					Keyframes = {0, 1},
					Data = {
						[0] = {
							Value = CFrame.new(),
						},
						[1] = {
							Value = CFrame.new(),
						},
					},
				},
				UpperTorso = {
					Type = GetFFlagFacialAnimationSupport() and Constants.TRACK_TYPES.CFrame or nil,
					Keyframes = {0, 1},
					Data = {
						[0] = {
							Value = CFrame.new(),
						},
						[1] = {
							Value = CFrame.new(),
						},
					},
				},
			},
		},
	}

	itSKIP("should be able to add a keyframe without a track", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			local analytics = Analytics.mock()

			TestHelpers.loadAnimation(store, emptyData)
			if GetFFlagFacialAnimationSupport() then
				store:dispatch(ValueChanged("Root", "Head", Constants.TRACK_TYPES.CFrame, 0, CFrame.new(), analytics))
			else
				store:dispatch(ValueChanged("Root", "Head", 0, CFrame.new(), analytics))
			end
			TestHelpers.delay()

			local testTrack = TestPaths.getTrack(container, "Track_Head")
			expect(#testTrack:GetChildren()).to.equal(1)
			local summaryTrack = TestPaths.getTrack(container, "SummaryTrack")
			expect(#summaryTrack:GetChildren()).to.equal(1)

			local trackList = TestPaths.getTrackList(container)
			expect(trackList:FindFirstChild("Track_Head")).to.be.ok()
		end)
	end)

	it("should be able to add a keyframe to an existing track", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			local analytics = Analytics.mock()
			TestHelpers.loadAnimation(store, emptyData)
			if GetFFlagFacialAnimationSupport() then
				store:dispatch(ValueChanged("Root", "Head", Constants.TRACK_TYPES.CFrame, 0, CFrame.new(), analytics))
				store:dispatch(ValueChanged("Root", "Head", Constants.TRACK_TYPES.CFrame, 1, CFrame.new(), analytics))
			else
				store:dispatch(ValueChanged("Root", "Head", 0, CFrame.new(), analytics))
				store:dispatch(ValueChanged("Root", "Head", 1, CFrame.new(), analytics))
			end
			TestHelpers.delay()

			local testTrack = TestPaths.getTrack(container, "Track_Head")
			expect(#testTrack:GetChildren()).to.equal(2)
			local summaryTrack = TestPaths.getTrack(container, "SummaryTrack")
			expect(#summaryTrack:GetChildren()).to.equal(2)
		end)
	end)

	it("should be able to add a keyframe under an existing summary keyframe", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			local analytics = Analytics.mock()

			TestHelpers.loadAnimation(store, emptyData)
			if GetFFlagFacialAnimationSupport() then
				store:dispatch(ValueChanged("Root", "Head", Constants.TRACK_TYPES.CFrame, 0, CFrame.new(), analytics))
				store:dispatch(ValueChanged("Root", "UpperTorso", Constants.TRACK_TYPES.CFrame, 0, CFrame.new(), analytics))
			else
				store:dispatch(ValueChanged("Root", "Head", 0, CFrame.new(), analytics))
				store:dispatch(ValueChanged("Root", "UpperTorso", 0, CFrame.new(), analytics))
			end
			TestHelpers.delay()

			local testTrack = TestPaths.getTrack(container, "Track_Head")
			expect(#testTrack:GetChildren()).to.equal(1)
			local testTrack2 = TestPaths.getTrack(container, "Track_UpperTorso")
			expect(#testTrack2:GetChildren()).to.equal(1)
			local summaryTrack = TestPaths.getTrack(container, "SummaryTrack")
			expect(#summaryTrack:GetChildren()).to.equal(1)
		end)
	end)

	it("should be able to delete a selected keyframe", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			local analytics = Analytics.mock()

			TestHelpers.loadAnimation(store, testAnimationData)
			local testTrack = TestPaths.getTrack(container, "Track_Head")

			TestHelpers.clickInstance(testTrack["1"])
			store:dispatch(DeleteSelectedKeyframes(analytics))
			TestHelpers.delay()

			expect(#testTrack:GetChildren()).to.equal(1)
		end)
	end)

	it("should be able to delete multiple selected keyframes", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			local analytics = Analytics.mock()

			TestHelpers.loadAnimation(store, testAnimationData)
			local testTrack = TestPaths.getTrack(container, "Track_Head")
			local testTrack2 = TestPaths.getTrack(container, "Track_UpperTorso")
			local summaryTrack = TestPaths.getTrack(container, "SummaryTrack")

			TestHelpers.clickInstance(testTrack["1"])
			VirtualInput.pressKey(Enum.KeyCode.LeftControl)
			TestHelpers.clickInstance(testTrack2["1"])
			VirtualInput.releaseKey(Enum.KeyCode.LeftControl)
			store:dispatch(DeleteSelectedKeyframes(analytics))
			TestHelpers.delay()

			expect(#testTrack:GetChildren()).to.equal(1)
			expect(#testTrack2:GetChildren()).to.equal(1)
			expect(#summaryTrack:GetChildren()).to.equal(1)
		end)
	end)

	it("should be able to copy and paste a keyframe", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			local analytics = Analytics.mock()

			TestHelpers.loadAnimation(store, testAnimationData)
			local testTrack = TestPaths.getTrack(container, "Track_Head")
			local summaryTrack = TestPaths.getTrack(container, "SummaryTrack")

			TestHelpers.clickInstance(testTrack["1"])
			store:dispatch(CopySelectedKeyframes())
			store:dispatch(PasteKeyframes(3, analytics))
			TestHelpers.delay()

			expect(#testTrack:GetChildren()).to.equal(3)
			expect(#summaryTrack:GetChildren()).to.equal(3)
		end)
	end)

	it("should be able to copy and paste multiple keyframes", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			local analytics = Analytics.mock()

			TestHelpers.loadAnimation(store, testAnimationData)
			local testTrack = TestPaths.getTrack(container, "Track_Head")
			local testTrack2 = TestPaths.getTrack(container, "Track_UpperTorso")
			local summaryTrack = TestPaths.getTrack(container, "SummaryTrack")

			TestHelpers.clickInstance(summaryTrack["1"])
			VirtualInput.pressKey(Enum.KeyCode.LeftControl)
			TestHelpers.clickInstance(summaryTrack["2"])
			VirtualInput.releaseKey(Enum.KeyCode.LeftControl)
			store:dispatch(CopySelectedKeyframes())
			store:dispatch(PasteKeyframes(3, analytics))
			TestHelpers.delay()

			expect(#testTrack:GetChildren()).to.equal(4)
			expect(#testTrack2:GetChildren()).to.equal(4)
			expect(#summaryTrack:GetChildren()).to.equal(4)
		end)
	end)

	it("should be able to move a selected keyframe", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			TestHelpers.loadAnimation(store, testAnimationData)
			local testTrack = TestPaths.getTrack(container, "Track_Head")
			TestHelpers.clickInstance(testTrack["2"])

			local keyframeElement = Element.new(testTrack["2"])
			local endPoint = keyframeElement:getCenter() + Vector2.new(20, 0)

			VirtualInput.setCurrentWindow(container)
			VirtualInput.mouseLeftDown(keyframeElement:getCenter())
			TestHelpers.delay()
			VirtualInput.mouseMove(keyframeElement:getCenter() + Vector2.new(10, 0))
			TestHelpers.delay()
			VirtualInput.mouseMove(endPoint)
			TestHelpers.delay()

			-- Note: Extra jitter was required to get the keyframe to move.
			-- This may be because the DragArea pops up once the mouse starts moving.
			VirtualInput.mouseMove(keyframeElement:getCenter())
			TestHelpers.delay()
			VirtualInput.mouseMove(endPoint)
			TestHelpers.delay()

			VirtualInput.mouseLeftUp(endPoint)
			TestHelpers.delay()

			local selectedKeyframes = store:getState().Status.SelectedKeyframes
			local animationData = store:getState().AnimationData
			local endFrame = animationData.Metadata.EndFrame
			expect(selectedKeyframes.Root).to.be.ok()
			expect(selectedKeyframes.Root.Head).to.be.ok()
			expect(selectedKeyframes.Root.Head[1]).never.to.be.ok()
			expect(selectedKeyframes.Root.Head[endFrame]).to.be.ok()
		end)
	end)

	it("should be able to move multiple selected keyframes", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			TestHelpers.loadAnimation(store, testAnimationData)
			local summaryTrack = TestPaths.getTrack(container, "SummaryTrack")
			TestHelpers.clickInstance(summaryTrack["1"])
			VirtualInput.pressKey(Enum.KeyCode.LeftControl)
			TestHelpers.clickInstance(summaryTrack["2"])
			VirtualInput.releaseKey(Enum.KeyCode.LeftControl)

			local keyframeElement = Element.new(summaryTrack["1"])
			local endPoint = keyframeElement:getCenter() + Vector2.new(20, 0)

			VirtualInput.setCurrentWindow(container)
			VirtualInput.mouseLeftDown(keyframeElement:getCenter())
			TestHelpers.delay()
			VirtualInput.mouseMove(keyframeElement:getCenter() + Vector2.new(10, 0))
			TestHelpers.delay()
			VirtualInput.mouseMove(endPoint)
			TestHelpers.delay()
			VirtualInput.mouseLeftUp(endPoint)
			TestHelpers.delay()

			local selectedKeyframes = store:getState().Status.SelectedKeyframes
			local animationData = store:getState().AnimationData
			local endFrame = animationData.Metadata.EndFrame
			expect(selectedKeyframes.Root).to.be.ok()
			expect(selectedKeyframes.Root.Head).to.be.ok()
			expect(selectedKeyframes.Root.Head[0]).never.to.be.ok()
			expect(selectedKeyframes.Root.Head[endFrame]).to.be.ok()
			expect(selectedKeyframes.Root.Head[endFrame - 1]).to.be.ok()
			expect(selectedKeyframes.Root.UpperTorso).to.be.ok()
			expect(selectedKeyframes.Root.UpperTorso[0]).never.to.be.ok()
			expect(selectedKeyframes.Root.UpperTorso[endFrame]).to.be.ok()
			expect(selectedKeyframes.Root.UpperTorso[endFrame - 1]).to.be.ok()
		end)
	end)

	it("should maintain selection after moving keyframes", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			TestHelpers.loadAnimation(store, testAnimationData)
			local summaryTrack = TestPaths.getTrack(container, "SummaryTrack")
			TestHelpers.clickInstance(summaryTrack["1"])

			local keyframeElement = Element.new(summaryTrack["1"])
			local endPoint = keyframeElement:getCenter() + Vector2.new(20, 0)

			VirtualInput.setCurrentWindow(container)
			VirtualInput.mouseLeftDown(keyframeElement:getCenter())
			TestHelpers.delay()
			VirtualInput.mouseMove(keyframeElement:getCenter() + Vector2.new(10, 0))
			TestHelpers.delay()
			VirtualInput.mouseMove(endPoint)
			TestHelpers.delay()
			VirtualInput.mouseLeftUp(endPoint)
			TestHelpers.delay()

			local selectedKeyframes = store:getState().Status.SelectedKeyframes
			expect(isEmpty(selectedKeyframes)).to.equal(false)
		end)
	end)

	itSKIP("should be able to scale multiple selected keyframes", function()
		runTest(function(test)
			local store = test:getStore()
			local container = test:getContainer()
			TestHelpers.loadAnimation(store, testAnimationData)
			local summaryTrack = TestPaths.getTrack(container, "SummaryTrack")
			local dopeSheetContainer = TestPaths.getDopeSheetController(container)
				:WaitForChild("DopeSheetContainer")

			TestHelpers.clickInstance(summaryTrack["1"])
			expect(dopeSheetContainer:FindFirstChild("ScaleControls")).never.to.be.ok()
			VirtualInput.pressKey(Enum.KeyCode.LeftControl)
			TestHelpers.clickInstance(summaryTrack["2"])
			VirtualInput.releaseKey(Enum.KeyCode.LeftControl)
			expect(dopeSheetContainer:FindFirstChild("ScaleControls")).to.be.ok()

			local scaleControls = dopeSheetContainer.ScaleControls
			local rightBar = scaleControls.RightHandle.DragListenerArea

			local barElement = Element.new(rightBar)
			local endPoint = barElement:getCenter() + Vector2.new(20, 0)

			VirtualInput.setCurrentWindow(container)
			VirtualInput.mouseLeftDown(barElement:getCenter())
			TestHelpers.delay()
			VirtualInput.mouseMove(barElement:getCenter() + Vector2.new(10, 0))
			TestHelpers.delay()
			VirtualInput.mouseMove(endPoint)
			TestHelpers.delay()
			VirtualInput.mouseLeftUp(endPoint)
			TestHelpers.delay()

			local selectedKeyframes = store:getState().Status.SelectedKeyframes
			local animationData = store:getState().AnimationData
			local endFrame = animationData.Metadata.EndFrame
			expect(selectedKeyframes.Root).to.be.ok()
			expect(selectedKeyframes.Root.Head).to.be.ok()
			expect(selectedKeyframes.Root.Head[0]).to.be.ok()
			expect(selectedKeyframes.Root.Head[1]).never.to.be.ok()
			expect(selectedKeyframes.Root.Head[endFrame]).to.be.ok()
			expect(selectedKeyframes.Root.UpperTorso).to.be.ok()
			expect(selectedKeyframes.Root.UpperTorso[0]).to.be.ok()
			expect(selectedKeyframes.Root.UpperTorso[1]).never.to.be.ok()
			expect(selectedKeyframes.Root.UpperTorso[endFrame]).to.be.ok()
		end)
	end)
end