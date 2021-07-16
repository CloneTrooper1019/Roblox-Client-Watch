--[[
	The InspectorDebugInterface class is used by the DeveloperInspector plugin to attach to other
	sources of information.
]]
local Source = script.Parent.Parent

local BindableEventBridge = require(Source.Classes.BindableEventBridge)
local DebugInterface = require(Source.Classes.DebugInterface)
local RoactInspectorApi = require(Source.RoactInspector.Classes.RoactInspectorApi)
local EventName = require(Source.EventName)

local InspectorDebugInterface = DebugInterface:extend("InspectorDebugInterface", function(handlers)
	local pluginBridge = BindableEventBridge.new(game:GetService("StudioService"))
	local coreGuiBridge = BindableEventBridge.new(game:GetService("CoreGui"))
	local libraryBridge = BindableEventBridge.new(game:GetService("ReplicatedStorage"), true)
	local interface = DebugInterface.new("Inspector", "Inspector", {pluginBridge, coreGuiBridge, libraryBridge})
	interface.handlers = handlers
	return interface
end)

function InspectorDebugInterface:_init()
	self:_connectInspector()
end

function InspectorDebugInterface:getTargetApi()
	return self.targetApi
end

function InspectorDebugInterface:closeTargetApi()
	if self.targetApi then
		self.targetApi:close()
	end
end

function InspectorDebugInterface:_connectInspector()
	self:_connect({
		eventName = EventName.ShowTargets,
		onEvent = function(message)
			self.handlers.onAddTargets(message)
		end
	})
end

function InspectorDebugInterface:getTargets()
	self:_send({
		eventName = EventName.GetTargets
	})
end

function InspectorDebugInterface:attachRoactTree(bridgeId, targetId)
	local roactInspectorApi = RoactInspectorApi.new(self, bridgeId, targetId)
	roactInspectorApi:attach(self.handlers.RoactInspector)
	self.targetApi = roactInspectorApi
	return self.targetApi
end

return InspectorDebugInterface
