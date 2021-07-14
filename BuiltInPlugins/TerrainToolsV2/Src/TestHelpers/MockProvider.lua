local Plugin = script.Parent.Parent.Parent

local Framework = require(Plugin.Packages.Framework)
local Roact = require(Plugin.Packages.Roact)
local Rodux = require(Plugin.Packages.Rodux)

local ContextServices = Framework.ContextServices
local ContextItems = require(Plugin.Src.ContextItems)

local Http = Framework.Http

local MockPlugin = Framework.TestHelpers.Instances.MockPlugin
local MockTerrain = require(Plugin.Src.TestHelpers.MockTerrain)

local UILibraryCompat = Plugin.Src.UILibraryCompat
local Localization = require(UILibraryCompat.Localization)

local MainReducer = require(Plugin.Src.Reducers.MainReducer)

local PluginTheme = require(Plugin.Src.Resources.PluginTheme)
local makeTheme = require(Plugin.Src.Resources.makeTheme)

local PluginActivationController = require(Plugin.Src.Util.PluginActivationController)

local TerrainInterfaces = Plugin.Src.TerrainInterfaces
local TerrainGeneration = require(TerrainInterfaces.TerrainGenerationInstance)
local TerrainImporter = require(TerrainInterfaces.TerrainImporterInstance)
local SeaLevel = require(TerrainInterfaces.TerrainSeaLevel)
local PartConverter = require(TerrainInterfaces.PartConverter)

local ImageUploader = require(Plugin.Src.Util.ImageUploader)

local MockProvider = Roact.PureComponent:extend(script.Name)

local EMPTY_USERID = 0

function MockProvider.createMocks()
	local plugin = MockPlugin.new()

	return {
		plugin = plugin,
		mouse = plugin:GetMouse(),
		store = Rodux.Store.new(MainReducer),
		theme = PluginTheme.mock(),
		localization = Localization.mock(),
		terrain = MockTerrain.new(),
		networking = Http.Networking.mock(),
	}
end

function MockProvider.createMockContextItems(mocks)
	local analytics = ContextServices.Analytics.mock()
	local imageUploader = ImageUploader.new(mocks.networking)

	return {
		plugin = ContextServices.Plugin.new(mocks.plugin),
		mouse = ContextServices.Mouse.new(mocks.mouse),
		store = ContextServices.Store.new(mocks.store),
		theme = ContextItems.UILibraryTheme.new(mocks.theme),
		devFrameworkThemeItem = makeTheme(true),
		localization = ContextItems.UILibraryLocalization.new(mocks.localization),
		analytics = analytics,
		networking = mocks.networking,
		imageUploader = imageUploader,
		terrain = ContextItems.Terrain.new(mocks.terrain),
		pluginActivationController = PluginActivationController.new(mocks.plugin),
		terrainImporter = TerrainImporter.new({
			terrain = mocks.terrain,
			localization = mocks.localization,
			analytics = analytics,
			imageUploader = imageUploader,
			userId = EMPTY_USERID,
		}),
		terrainGeneration = TerrainGeneration.new({
			terrain = mocks.terrain,
			localization = mocks.localization,
			analytics = analytics,
		}),
		seaLevel = SeaLevel.new({
			terrain = mocks.terrain,
			localization = mocks.localization,
		}),
		partConverter = PartConverter.new({
			terrain = mocks.terrain,
			localization = mocks.localization,
			analytics = analytics,
		}),
	}
end

function MockProvider.cleanupMocks(mocks, mockItems)
	mockItems.partConverter:destroy()
	mockItems.seaLevel:destroy()
	mockItems.terrainGeneration:destroy()
	mockItems.terrainImporter:destroy()
	mockItems.pluginActivationController:destroy()
	mockItems.imageUploader:destroy()

	mockItems.localization:destroy()
	mockItems.devFrameworkThemeItem:destroy()
	mockItems.theme:destroy()

	mocks.store:destruct()

	mocks.plugin:Destroy()
end

function MockProvider:init()
	self.mocks = MockProvider.createMocks()
	self.mockItems = MockProvider.createMockContextItems(self.mocks)
end

function MockProvider:willUnmount()
	MockProvider.cleanupMocks(self.mocks, self.mockItems)

	self.mocks = {}
	self.mockItems = {}
end

function MockProvider:render()
	return ContextServices.provide({
		self.mockItems.plugin,
		self.mockItems.mouse,
		self.mockItems.store,
		self.mockItems.theme,
		self.mockItems.localization,
		self.mockItems.analytics,
		self.mockItems.pluginActivationController,
		self.mockItems.terrainImporter,
		self.mockItems.terrainGeneration,
		self.mockItems.seaLevel,
		self.mockItems.partConverter,
	}, {
		WrappedComponent = Roact.createFragment(self.props[Roact.Children]),
	})
end

function MockProvider.createElementWithMockContext(component, props, children)
	assert(type(component) == "function"
		or (type(component) == "table" and type(component.render) == "function"),
		"MockWrapper.createElementWithMockContext passed invalid component")

	return Roact.createElement(MockProvider, {
		MyComponent = Roact.createElement(component, props, children)
	})
end

return MockProvider
