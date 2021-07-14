--[[
	The PluginDebugInterface class is used to attach the DeveloperInspector to another plugin.
]]
local Source = script.Parent.Parent

local BindableEventBridge = require(Source.Classes.BindableEventBridge)
local DebugInterface = require(Source.Classes.DebugInterface)
local RobloxPluginGuiService = game:GetService("RobloxPluginGuiService")

local PluginDebugInterface = DebugInterface:extend("PluginDebugInterface", function(pluginName: string, plugin, rootInstance: Instance?)
	local bridge = BindableEventBridge.new(game:GetService("StudioService"))
	local interface = DebugInterface.new("Plugin", pluginName, {bridge})
	if rootInstance then
		interface:setGuiOptions({
			rootInstance = rootInstance
		})
	else
		-- Default to finding the root instance under the plugin gui service
		spawn(function()
			-- Wait for the UI to populate
			local gui = RobloxPluginGuiService:WaitForChild(pluginName, 10)
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