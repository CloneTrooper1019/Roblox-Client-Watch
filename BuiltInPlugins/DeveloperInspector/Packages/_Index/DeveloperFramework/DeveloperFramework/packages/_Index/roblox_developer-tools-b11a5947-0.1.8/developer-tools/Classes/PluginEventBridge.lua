--[[
	The PluginEventBridge class provides a means for a plugin that has code in a different
	data model to be inspected by the DeveloperTools plugin.
]]
local HttpService = game:GetService("HttpService")

local Source = script.Parent.Parent
local Packages = Source.Parent

local Dash = require(Packages.Dash)
local class = Dash.class
local join = Dash.join
local forEach = Dash.forEach
local insert = table.insert

local PLUGIN_EVENT_NAME = "DeveloperTools"

local PluginEventBridge = class("PluginEventBridge", function(plugin)
	return {
		id = HttpService:GenerateGUID(),
		plugin = plugin,
		connections = {}
	}
end)

function PluginEventBridge:send(message)
	local outMessage = join(message, {
		fromBridgeId = self.id
	})
	-- print("[DeveloperTools] Send (Plugin):", pretty(outMessage))
	self.plugin:Invoke(PLUGIN_EVENT_NAME, outMessage)
end 

function PluginEventBridge:connect(listener)
	local function onEvent(message)
		if message.fromBridgeId ~= self.id then
			listener(message)
		end
	end
	local connection = self.plugin:OnInvoke(PLUGIN_EVENT_NAME, onEvent)
	insert(self.connections, connection)
end

function PluginEventBridge:destroy()
	forEach(self.connections, function(connection)
		connection:Disconnect()
	end)
end

return PluginEventBridge