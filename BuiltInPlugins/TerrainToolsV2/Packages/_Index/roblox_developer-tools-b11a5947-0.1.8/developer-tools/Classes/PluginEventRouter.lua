--[[
	The PluginEventRouter class provides a means for a plugin that has code in a different
	data model to be inspected by the DeveloperTools plugin.
]]
local HttpService = game:GetService("HttpService")

local Source = script.Parent.Parent
local Packages = Source.Parent

local Dash = require(Packages.Dash)
local join = Dash.join
local class = Dash.class
local forEach = Dash.forEach

local PLUGIN_EVENT_NAME = "DeveloperTools"


local PluginEventRouter = class("PluginEventRouter", function(sourceName, plugin, bridges)
	return {
		routerId = HttpService:GenerateGUID(),
		sourceName = sourceName,
		plugin = plugin,
		bridges = bridges,
		-- A list of ids of PluginEvent bridges that have invoked our event
		outboundBridgeIds = {}
	}
end)

function PluginEventRouter:_init()
	self.connection = self.plugin:OnInvoke(PLUGIN_EVENT_NAME, function(message)
		-- Ignore messages from ourselves
		if message.fromRouter then
			return
		end
		-- Mark the bridge that this message originated from as accessible
		self.outboundBridgeIds[message.fromBridgeId] = true
		local outMessage = join(message, {
			sourceName = self.sourceName
		})
		forEach(self.bridges, function(bridge)
			bridge:send(outMessage)
		end)
	end)
	local function onEvent(message)
		-- Only route messages that have no particular destination
		-- or to bridges we know already exist behind our event
		local outMessage = join(message, {
			fromRouter = true
		})
		-- print("[DeveloperTools] Route (Plugin)", pretty(outMessage))
		self.plugin:Invoke(PLUGIN_EVENT_NAME, outMessage)
	end
	forEach(self.bridges, function(bridge)
		bridge:connect(onEvent)
	end)
end

function PluginEventRouter:destroy()
	self.connection:Disconnect()
end

return PluginEventRouter