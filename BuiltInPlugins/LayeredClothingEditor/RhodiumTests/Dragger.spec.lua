return function()
	local Plugin = script.Parent.Parent
	local Rhodium = require(Plugin.Packages.Dev.Rhodium)
	local XPath = Rhodium.XPath

	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	local Constants = require(Plugin.Src.Util.Constants)
	local MathUtil = require(Plugin.Src.Util.MathUtil)
	local ModelUtil = require(Plugin.Src.Util.ModelUtil)

	local SetFalloff = require(Plugin.Src.Actions.SetFalloff)
	local SetDraggerType = require(Plugin.Src.Actions.SetDraggerType)
	local SetSelectedLattice = require(Plugin.Src.Actions.SetSelectedLattice)

	local ScrollerPath = TestHelper.getMainScroller()
	local EditorFrame = ScrollerPath:cat(XPath.new("EditSwizzle.ViewArea.EditorFrame"))

	local PointToolTabButton =
		EditorFrame:cat(XPath.new("TabsRibbon.2 PointTool.1.Contents.TextButton"))

	local LatticeToolTabButton =
		EditorFrame:cat(XPath.new("TabsRibbon.1 LatticeTool.1.Contents.TextButton"))

	local function goToPointTool(store)
		TestHelper.addLCItemWithFullCageFromExplorer()
		TestHelper.clickXPath(PointToolTabButton)
		local state = store:getState()
		expect(state.status.toolMode).to.equal(Constants.TOOL_MODE.Point)
		expect(game.Workspace.RbfPoints).to.be.ok()
	end

	local function goToLatticeTool(store)
		TestHelper.addLCItemWithFullCageFromExplorer()
		TestHelper.clickXPath(LatticeToolTabButton)
		local state = store:getState()
		expect(state.status.toolMode).to.equal(Constants.TOOL_MODE.Lattice)
	end

	local function dragSelectPoints(store, context, fixture)
		local rbfPoints = game.Workspace:WaitForChild("RbfPoints")
		local pointsForclothes = rbfPoints:FindFirstChild(TestHelper.DefaultClothesName)
		local point = pointsForclothes:FindFirstChild("5")
		local pos = point.CFrame.p
		context:setCamera(CFrame.new(pos.X, pos.Y, pos.Z - 10, -1, 0, 0, 0, 1, 0, 0, 0, -1))

		fixture:select()
		fixture:mouseMove(0, 0)
		fixture:mouseDown()
		fixture:mouseMove(1, 1)
		fixture:mouseUp()
		fixture:deselect()
	end

	local function clickRbfPoint(index, store, context, fixture, doubleClick)
		local rbfPoints = game.Workspace:WaitForChild("RbfPoints")
		local pointsForclothes = rbfPoints:FindFirstChild(TestHelper.DefaultClothesName)
		local point = pointsForclothes:FindFirstChild(tostring(index))
		local pos = point.CFrame.p
		context:setCamera(CFrame.new(pos.X, pos.Y, pos.Z - 10, -1, 0, 0, 0, 1, 0, 0, 0, -1))

		fixture:mouseMove(0.5, 0.5)
		fixture:mouseDown()
		fixture:mouseUp()
		if doubleClick then
			fixture:mouseDown()
			fixture:mouseUp()
		end

		return pos
	end

	local function scaleRbfPoints(index, store, context, fixture, studs)
		local rbfPoints = game.Workspace:WaitForChild("RbfPoints")
		local pointsForclothes = rbfPoints:FindFirstChild(TestHelper.DefaultClothesName)
		clickRbfPoint(index, store, context, fixture, true)

		local state = store:getState()
		local pointData = state.cageData.pointData
		local pointsPerDeformer = pointData[Enum.CageType.Outer][TestHelper.DefaultClothesName]

		local positions = {}
		for pointIndex in pairs(pointsPerDeformer) do
			table.insert(positions, pointsForclothes:FindFirstChild(tostring(pointIndex)).CFrame.p)
		end
		local bounds = ModelUtil:getBounds(positions)
		local centroid = bounds.Centroid

		context:setCamera(CFrame.new(centroid.X - 10, centroid.Y, centroid.Z - 10, -1/math.sqrt(2), 0, -1/math.sqrt(2), 0, 1, 0, 1/math.sqrt(2), 0, -1/math.sqrt(2)))

		fixture:mouseMove(0.6, 0.5)
		fixture:mouseDown()
		fixture:mouseMove(0.6 + 0.1 * studs, 0.5)
		fixture:mouseUp()

		return bounds
	end

	local function dragLatticePoint(store, context, fixture, studs)
		local lattices = game.Workspace:WaitForChild("Lattices")
		local pointsForclothes = lattices:WaitForChild(TestHelper.DefaultClothesName)
		local point = pointsForclothes:FindFirstChild("clothes121")
		local pos = point.CFrame.p
		context:setCamera(CFrame.new(pos.X, pos.Y, pos.Z - 10, -1, 0, 0, 0, 1, 0, 0, 0, -1))

		fixture:mouseMove(0.5, 0.5)
		fixture:mouseDown()
		fixture:mouseUp()
		fixture:mouseMove(0.8, 0.5)
		fixture:mouseDown()
		fixture:mouseMove(0.8 + 0.1 * studs, 0.5)
		fixture:mouseUp()
	end

	local function dragRbfPoint(index, store, context, fixture, studs, doubleClick)
		local rbfPoints = game.Workspace:WaitForChild("RbfPoints")
		local pointsForclothes = rbfPoints:FindFirstChild(TestHelper.DefaultClothesName)
		local point = pointsForclothes:FindFirstChild(tostring(index))
		local pos = point.CFrame.p
		context:setCamera(CFrame.new(pos.X, pos.Y, pos.Z - 10, -1, 0, 0, 0, 1, 0, 0, 0, -1))

		fixture:mouseMove(0.5, 0.5)
		fixture:mouseDown()
		fixture:mouseUp()
		if doubleClick then
			fixture:mouseDown()
			fixture:mouseUp()
		end
		fixture:mouseMove(0.8, 0.5)
		fixture:mouseDown()
		fixture:mouseMove(0.8 + 0.1 * studs, 0.5)
		fixture:mouseUp()
	end

	describe("Move Handle", function()
		it("Dragging handle in Point Mode will properly move points", function()
			runRhodiumTest(function(container, store, dragger)
				store:dispatch(SetFalloff(0))
				store:dispatch(SetDraggerType(Enum.RibbonTool.Move))
				goToPointTool(store)

				local state = store:getState()
				local pointData = state.cageData.pointData
				local originalPosition = pointData[Enum.CageType.Outer][TestHelper.DefaultClothesName][5].Position

				dragger.Fixture:select()
				dragRbfPoint(5, store, dragger.Context, dragger.Fixture, 2)
				dragger.Fixture:deselect()

				state = store:getState()
				pointData = state.cageData.pointData
				local position = pointData[Enum.CageType.Outer][TestHelper.DefaultClothesName][5].Position
				local delta = position - originalPosition
				expect(MathUtil:fuzzyEq(math.abs(delta.X), 2)).to.equal(true)
			end, Enum.RibbonTool.Move)
		end)

		it("Dragging handle in Lattice Mode will properly move points", function()
			runRhodiumTest(function(container, store, dragger)
				store:dispatch(SetDraggerType(Enum.RibbonTool.Move))
				goToLatticeTool(store)
				store:dispatch(SetSelectedLattice(TestHelper.DefaultClothesName))

				local state = store:getState()
				local latticeData = state.latticeTool.latticeData
				local originalPosition = latticeData[Enum.CageType.Outer][TestHelper.DefaultClothesName].lattice[1][2][1].position

				dragger.Fixture:select()
				dragLatticePoint(store, dragger.Context, dragger.Fixture, 2)
				dragger.Fixture:deselect()

				state = store:getState()
				latticeData = state.latticeTool.latticeData
				local position =  latticeData[Enum.CageType.Outer][TestHelper.DefaultClothesName].lattice[1][2][1].position
				local delta = position - originalPosition
				expect(MathUtil:fuzzyEq(math.abs(delta.X), 2)).to.equal(true)
			end, Enum.RibbonTool.Move)
		end)
	end)

	describe("Scale Handle", function()
		it("Dragging handle in Point Mode will properly scale points", function()
			runRhodiumTest(function(container, store, dragger)
				store:dispatch(SetFalloff(0))
				store:dispatch(SetDraggerType(Enum.RibbonTool.Scale))

				goToPointTool(store)

				local rbfPoints = game.Workspace:WaitForChild("RbfPoints")
				local pointsForclothes = rbfPoints:FindFirstChild(TestHelper.DefaultClothesName)

				dragger.Fixture:select()
				local bounds = scaleRbfPoints(5, store, dragger.Context, dragger.Fixture, 1)
				dragger.Fixture:deselect()

				local state = store:getState()
				local pointData = state.cageData.pointData

				wait()

				local positions = {}
				for pointIndex in pairs(pointData[Enum.CageType.Outer][TestHelper.DefaultClothesName]) do
					table.insert(positions, pointsForclothes:FindFirstChild(tostring(pointIndex)).CFrame.p)
				end
				local newBounds = ModelUtil:getBounds(positions)

				expect(MathUtil:fuzzyEq(math.abs(newBounds.Width/bounds.Width), 3.046952)).to.equal(true)
				expect(MathUtil:fuzzyEq(math.abs(newBounds.Height/bounds.Height), 1)).to.equal(true)
				expect(MathUtil:fuzzyEq(math.abs(newBounds.Depth/bounds.Depth), 1)).to.equal(true)
			end, Enum.RibbonTool.Scale)
		end)

		it("Dragging handle with Ctrl pressed will scale uniformly", function()
			runRhodiumTest(function(container, store, dragger)
				store:dispatch(SetFalloff(0))
				store:dispatch(SetDraggerType(Enum.RibbonTool.Scale))

				goToPointTool(store)

				local rbfPoints = game.Workspace:WaitForChild("RbfPoints")
				local pointsForclothes = rbfPoints:FindFirstChild(TestHelper.DefaultClothesName)

				dragger.Fixture:select()
				dragger.Context:setCtrlAltShift(true, false, false)
				local bounds = scaleRbfPoints(5, store, dragger.Context, dragger.Fixture, 1)
				dragger.Context:setCtrlAltShift(false, false, false)
				dragger.Fixture:deselect()

				local state = store:getState()
				local pointData = state.cageData.pointData

				wait()

				local positions = {}
				for pointIndex in pairs(pointData[Enum.CageType.Outer][TestHelper.DefaultClothesName]) do
					table.insert(positions, pointsForclothes:FindFirstChild(tostring(pointIndex)).CFrame.p)
				end
				local newBounds = ModelUtil:getBounds(positions)

				expect(MathUtil:fuzzyEq(math.abs(newBounds.Width/bounds.Width), 3.046952)).to.equal(true)
				expect(MathUtil:fuzzyEq(math.abs(newBounds.Height/bounds.Height), 3.046952)).to.equal(true)
				expect(MathUtil:fuzzyEq(math.abs(newBounds.Depth/bounds.Depth), 3.046952)).to.equal(true)
			end, Enum.RibbonTool.Scale)
		end)
	end)

	describe("Select Handle", function()
		it("Can select a single point", function()
			runRhodiumTest(function(container, store, dragger)
				store:dispatch(SetFalloff(0))
				goToPointTool(store)
				dragger.Fixture:select()
				clickRbfPoint(3, store, dragger.Context, dragger.Fixture)
				dragger.Fixture:deselect()

				local state = store:getState()
				local selectedPoints = state.pointTool.selectedPoints

				expect(selectedPoints[TestHelper.DefaultClothesName][3]).to.equal(1)
			end, Enum.RibbonTool.Select)
		end)

		it("Can double click to select multiple points", function()
			runRhodiumTest(function(container, store, dragger)
				store:dispatch(SetFalloff(0))
				goToPointTool(store)
				dragger.Fixture:select()
				clickRbfPoint(5, store, dragger.Context, dragger.Fixture, true)
				dragger.Fixture:deselect()

				local state = store:getState()
				local selectedPoints = state.pointTool.selectedPoints
				local pointData = state.cageData.pointData

				for pointIndex in pairs(pointData[Enum.CageType.Outer][TestHelper.DefaultClothesName]) do
					expect(selectedPoints[TestHelper.DefaultClothesName][pointIndex]).to.equal(1)
				end
			end, Enum.RibbonTool.Select)
		end)

		it("Can multi-select via dragging", function()
			runRhodiumTest(function(container, store, dragger)
				store:dispatch(SetFalloff(0))
				goToPointTool(store)
				dragSelectPoints(store, dragger.Context, dragger.Fixture)

				local state = store:getState()
				local clickedPoints = state.pointTool.clickedPoints
				expect(#clickedPoints).to.equal(72)
			end, Enum.RibbonTool.Select)
		end)

		it("Can multi-select via ctrl + click", function()
			runRhodiumTest(function(container, store, dragger)
				store:dispatch(SetFalloff(0))
				goToPointTool(store)

				dragger.Fixture:select()
				dragger.Context:setCtrlAltShift(true, false, false)
				clickRbfPoint(3, store, dragger.Context, dragger.Fixture, false)
				-- wait for double click threshold to expire
				wait(0.5)
				clickRbfPoint(5, store, dragger.Context, dragger.Fixture, false)
				-- wait for double click threshold to expire
				wait(0.5)
				clickRbfPoint(9, store, dragger.Context, dragger.Fixture, false)
				dragger.Context:setCtrlAltShift(false, false, false)
				dragger.Fixture:deselect()

				local state = store:getState()
				local selectedPoints = state.pointTool.selectedPoints

				expect(selectedPoints[TestHelper.DefaultClothesName][3]).to.equal(1)
				expect(selectedPoints[TestHelper.DefaultClothesName][5]).to.equal(1)
				expect(selectedPoints[TestHelper.DefaultClothesName][9]).to.equal(1)
			end, Enum.RibbonTool.Select)
		end)
	end)
end