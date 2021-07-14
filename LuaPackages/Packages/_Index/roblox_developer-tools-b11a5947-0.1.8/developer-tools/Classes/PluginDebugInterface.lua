--[[
	The PluginDebugInterface class is used to attach the DeveloperInspector to another plugin.
]]
local Source = script.Parent.Parent

local BindableEventBridge = require(Source.Classes.BindableEventBridge)
local DebugInterface = require(Source.Classes.DebugInterface)
local Services = require(Source.Services)

local PluginDebugInterface = DebugInterface:extend("PluginDebugInterface", function(pluginName: string, plugin, rootInstance: Instance?)

	local bridge = BindableEventBridge.new(Services.getStudioService())
	local interface = DebugInterface.new("Plugin", pluginName, {bridge})
	if rootInstance then
		interface:setGuiOptions({
			rootInstance = rootInstance
		})
	else
		-- Default to finding the root instance under the plugin gui service
		spawn(function()
			-- Wait for the UI to populate
			local gui = Services.getRobloxPluginGuiService():WaitForChild(pluginName, 10)
			if gui then
				interface:setGuiOptions({
					rootInstance = gui
				})
			end
		end)
	end
	return interface
end)

return PluginDebugInterface