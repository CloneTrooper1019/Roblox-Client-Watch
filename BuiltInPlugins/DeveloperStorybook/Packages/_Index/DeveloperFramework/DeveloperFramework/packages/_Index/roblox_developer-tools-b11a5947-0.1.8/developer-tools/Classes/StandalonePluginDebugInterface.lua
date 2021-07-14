--[[
	The StandalonePluginDebugInterface class is used to attach the DeveloperInspector to a standalone plugin.
]]
local Source = script.Parent.Parent
local Packages = Source.Parent

local PluginEventBridge = require(Source.Classes.PluginEventBridge)
local DebugInterface = require(Source.Classes.DebugInterface)

local StandalonePluginDebugInterface = DebugInterface:extend("StandalonePluginDebugInterface", function(pluginName: string, plugin, guiOptions)
	local bridge = PluginEventBridge.new(plugin)
	local interface = DebugInterface.new("StandalonePlugin", pluginName, {bridge})
	interface:setGuiOptions(guiOptions)
	return interface
end)

return StandalonePluginDebugInterface