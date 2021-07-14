local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Rodux = require(Plugin.Packages.Rodux)

local PluginTheme = require(Plugin.Src.Resources.PluginTheme)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local TestHelpers = Framework.TestHelpers
local Http = Framework.Http
local provideMockContext = TestHelpers.provideMockContext

local Constants = require(Plugin.Src.Util.Constants)
local TestHelper = require(Plugin.Src.Util.TestHelper)
local makeMockNetworkLayer = require(Plugin.Src.Util.makeMockNetworkLayer)
local Signals = require(Plugin.Src.Context.Signals)
local PreviewContext = require(Plugin.Src.Context.PreviewContext)
local EditingItemContext = require(Plugin.Src.Context.EditingItemContext)

local TransformPoints = require(Plugin.Src.Thunks.TransformPoints)
local TransformLatticePoints = require(Plugin.Src.Thunks.TransformLatticePoints)
local AddWaypoint = require(Plugin.Src.Thunks.AddWaypoint)
local SetHovered = require(Plugin.Src.Actions.SetHovered)
local SelectRbfPoint = require(Plugin.Src.Thunks.SelectRbfPoint)
local SetSelectedControlPoints = require(Plugin.Src.Actions.SetSelectedControlPoints)

local DraggerFramework = Plugin.Packages.DraggerFramework
local DraggerToolFixture = require(DraggerFramework.DraggerTools.DraggerToolFixture)
local DraggerContext_FixtureImpl = require(DraggerFramework.Implementation.DraggerContext_FixtureImpl)
local DraggerSchema = require(Plugin.Src.Util.DraggerSchema.DraggerSchema)
local MoveHandles = require(DraggerFramework.Handles.MoveHandles)
local ExtrudeHandles = require(DraggerFramework.Handles.ExtrudeHandles)

local MainReducer = require(Plugin.Src.Reducers.MainReducer)

local LayeredClothingEditor = require(Plugin.Src.Components.LayeredClothingEditor)

local TestRunner = {}

local function connectStoreToDragger(store, context, selection)
	store.changed:connect(function(newState, oldState)
		context.toolMode = newState.status.toolMode
		context.pointData = newState.cageData.pointData
		context.boundsData = newState.cageData.boundsData
		context.selectedLattice = newState.latticeTool.selectedLattice
		context.latticeData = newState.latticeTool.latticeData
		context.latticeBoundsData = newState.latticeTool.latticeBoundsData
		context.editingCage = newState.selectItem.editingCage
		context.editingItem = newState.selectItem.editingItem

		selection.toolMode = newState.status.toolMode
		selection.clickedPoints = newState.pointTool.clickedPoints
		selection.selectedControlPoints = newState.status.selectedControlPoints
	end)

	local makeDispatch = function(action)
		return function(...)
			store:dispatch(action(...))
		end
	end
	context.transformPoints = makeDispatch(TransformPoints)
	context.transformLatticePoints = makeDispatch(TransformLatticePoints)
	context.addWaypoint = makeDispatch(AddWaypoint)
	context.selectRbfPoint = makeDispatch(SelectRbfPoint)
	context.setSelectedControlPoints = makeDispatch(SetSelectedControlPoints)
	context.setHovered = makeDispatch(SetHovered)

	selection.selectRbfPoint = makeDispatch(SelectRbfPoint)
	selection.setSelectedControlPoints = makeDispatch(SetSelectedControlPoints)
end

local function setupDragger(store, signals, draggerType)
	local selectionSignal = signals:get(Constants.SIGNAL_KEYS.SelectionChanged)
	local toolChangedSignal = signals:get(Constants.SIGNAL_KEYS.ToolChanged)

	local selection = DraggerSchema.Selection.new(selectionSignal)
	local context = DraggerContext_FixtureImpl.new(nil, selection)
	context.ToolChangedSignal = toolChangedSignal

	context.SelectedPointMeta = {
		__eq = function(p1, p2)
			return p1.Deformer == p2.Deformer and
				p1.Index == p2.Index
		end,
	}
	context.selectedControlPointMeta = {
		__eq = function(p1, p2)
			return p1.Deformer == p2.Deformer and
				p1.ID == p2.ID and
				p1.GridPosition.X == p2.GridPosition.X and
				p1.GridPosition.Y == p2.GridPosition.Y and
				p1.GridPosition.Z == p2.GridPosition.Z
		end
	}

	connectStoreToDragger(store, context, selection)

	local handle = nil
	if draggerType == Enum.RibbonTool.Scale then
		handle = ExtrudeHandles.new(context, {
			ShowBoundingBox = false,
		}, DraggerSchema.ExtrudeHandlesImplementation.new(context))
	else
		handle = MoveHandles.new(context, {
			ShowBoundingBox = false,
		}, DraggerSchema.TransformHandlesImplementation.new(context))
	end

	local fixture = DraggerToolFixture.new(context, DraggerSchema, {
		AnalyticsName = "TestFixture",
		HandlesList = {handle},
	})
	return context, fixture
end

local function run(testChildren, container, testRunner, draggerType)
	local middlewares = {Rodux.thunkMiddleware}
	local store = Rodux.Store.new(MainReducer, nil, middlewares)
	local signals = Signals.new(Constants.SIGNAL_KEYS)
	local editingItemContext = EditingItemContext.new()

	local previewContext
	if not draggerType then
		previewContext = PreviewContext.new()
	end

	local element = provideMockContext({
		PluginTheme.mock(),
		ContextServices.Store.new(store),
		ContextServices.API.new({
			networking = Http.Networking.mock({
				onRequest = makeMockNetworkLayer,
			}),
		}),
		ContextServices.Focus.new(container),
		signals,
		editingItemContext,
		previewContext,
	}, testChildren)
	local handle = Roact.mount(element, container)

	local dragger
	if draggerType == Enum.RibbonTool.Move or draggerType == Enum.RibbonTool.Rotate or
		draggerType == Enum.RibbonTool.Select or draggerType == Enum.RibbonTool.Scale then
		local context, fixture = setupDragger(store, signals, draggerType)
		dragger = {
			Context = context,
			Fixture = fixture,
		}
	end

	local success, result = pcall(function()
		if testRunner then
			testRunner(container, store, dragger)
		end
	end)

	Roact.unmount(handle)
	container:Destroy()
	store:destruct()
	TestHelper.cleanTempInstances()

	if not success then
		error(result)
	end
end

function TestRunner.runTestMinimal(testRunner)
	local success, result = pcall(function()
		if testRunner then
			testRunner()
		end
	end)

	TestHelper.cleanTempInstances()

	if not success then
		error(result)
	end
end

function TestRunner.runComponentTest(component, testRunner)
	run({test = component}, Instance.new("ScreenGui"), testRunner)
end

local function makeContainer()
	local screen = Instance.new("ScreenGui", game.CoreGui)
	screen.Name = "PluginMockGui"
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	return screen
end

function TestRunner.runRhodiumTest(testRunner, draggerType)
	run({LayeredClothingEditor = Roact.createElement(LayeredClothingEditor)}, makeContainer(), testRunner, draggerType)
end

return TestRunner