--[[
	The entry point for the DeveloperTools library.

	These static methods each create a new DebugInterface that provides a method of communication
	to the Developer Inspector plugin from the information source you are trying to inspect.

	Each interface uses a slightly different way to communicate based on the current level of
	security and ability to use built-in services.
]]
local PluginDebugInterface = require(script.Classes.PluginDebugInterface)
local CoreGuiDebugInterface = require(script.Classes.CoreGuiDebugInterface)
local StandalonePluginDebugInterface = require(script.Classes.StandalonePluginDebugInterface)
local LibraryDebugInterface = require(script.Classes.LibraryDebugInterface)
local InspectorDebugInterface = require(script.Classes.InspectorDebugInterface)
local RoactInspectorApi = require(script.RoactInspector.Classes.RoactInspectorApi)

local helpfulErrorMessage = "%s must be a string, did you write DeveloperTools:%s() instead of DeveloperTools.%s() by mistake?"

export type GuiOptions = {
	rootInstance: Instance?;
	pickerParent: Instance?;
}

return {
	-- Get an inspector instance for a local, installed or built-in plugin
	forPlugin = function(pluginName: string, plugin)
		assert(typeof(pluginName) == "string", helpfulErrorMessage:format(pluginName, "forPlugin", "forPlugin"))
		assert(plugin, "DeveloperTools:forPlugin() expected plugin for argument #2")
		return PluginDebugInterface.new(pluginName, plugin)
	end,
	-- Get an inspector instance for a standalone plugin
	forStandalonePlugin = function(pluginName: string, plugin, rootInstance)
		assert(typeof(pluginName) == "string", helpfulErrorMessage:format(pluginName, "forStandalonePlugin", "forStandalonePlugin"))
		assert(plugin, "DeveloperTools:forStandalonePlugin() expected plugin for argument #2")
		return StandalonePluginDebugInterface.new(pluginName, plugin, rootInstance)
	end,
	-- Get an inspector instance for an interface placed in the CoreGui
	forCoreGui = function(appName: string, guiOptions: GuiOptions)
		assert(typeof(appName) == "string", helpfulErrorMessage:format(appName, "appName", "appName"))
		return CoreGuiDebugInterface.new(appName, guiOptions)
	end,
	-- Get an inspector instance for a library, such as UniversalApps or a set of ModuleScripts
	-- which are stored in ReplicatedStorage
	forLibrary = function(libraryName: string, guiOptions: GuiOptions)
		assert(typeof(libraryName) == "string", helpfulErrorMessage:format(libraryName, "libraryName", "libraryName"))
		return LibraryDebugInterface.new(libraryName, guiOptions)
	end,
	-- Used by the Developer Inspector plugin itself to communicate with all available channels
	forInspector = function(handlers)
		return InspectorDebugInterface.new(handlers)
	end,
	-- A reference to the RoactInspectorApi class.
	-- You can use the static isInstance method to check if the current api is a RoactInspectorApi
	-- i.e. RoactInspectorApi.isInstance(inspector:getCurrentApi())
	RoactInspectorApi = RoactInspectorApi
}