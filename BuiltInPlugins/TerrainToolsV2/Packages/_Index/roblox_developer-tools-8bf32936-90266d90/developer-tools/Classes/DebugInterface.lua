--[[
	The DebugInterface class controls interactions between consumers of the DeveloperTools library
	and the DeveloperTools inspector plugin itself.
]]
local HttpService = game:GetService("HttpService")

local Source = script.Parent.Parent
local Packages = Source.Parent

local Dash = require(Packages.Dash)
local class = Dash.class
local forEach = Dash.forEach

local insert = table.insert

local EventName = require(Source.EventName)
local PluginEventRouter = require(Source.Classes.PluginEventRouter)
local RoactInspectorWorker = require(Source.RoactInspector.Classes.RoactInspectorWorker)

local DebugInterface = class("DebugInterface", function(sourceKind: string, sourceName: string, bridges)
	return {
		sourceId = HttpService:GenerateGUID(),
		sourceKind = sourceKind,
		sourceName = sourceName, 
		bridges = bridges,
		routers = {},
		targets = {},
		workers = {},
		connectionsForListener = {},
		outboundBridgeForBridgeId = {}
	}
end)

function DebugInterface:addRoactTree(targetName: string, roactTree)
	assert(typeof(targetName) == "string", "targetName must be a string")
	assert(roactTree, "roactTree must be defined")
	
	self:_addTarget(targetName, function(targetId: string, toBridgeId: string)
		return RoactInspectorWorker.new(self, targetId, toBridgeId, roactTree)
	end)
end

function DebugInterface:addPluginRouter(plugin)
	insert(self.routers, PluginEventRouter.new(self.sourceName, plugin, self.bridges))
end

function DebugInterface:_connectTargets()
	-- Ensure that GetTargets is only connected to once.
	-- If targets have already been added we don't need to add another listener
	if #self.targets > 0 then
		return
	end
	self:_connect({
		eventName = EventName.GetTargets,
		onEvent = function(message)
			self:_send({
				eventName = EventName.ShowTargets,
				toBridgeId = message.fromBridgeId,
				sourceId = self.sourceId,
				sourceName = self.sourceName,
				sourceKind = self.sourceKind,
				targets = self.targets,
			})
		end
	})
end

function DebugInterface:_send(message)
	if not (game:GetService("StudioService"):HasInternalPermission()) then
		return
	end
	if not message.toBridgeId then
		forEach(self.bridges, function(bridge)
			bridge:send(message)
		end)
	else
		local bridge = self.outboundBridgeForBridgeId[message.toBridgeId]
		if not bridge then
			error(("[DeveloperTools] No bridge to other bridge %s"):format(message.toBridgeId))
		end
		bridge:send(message)
	end
end

function DebugInterface:_connect(listener)
	if not (game:GetService("StudioService"):HasInternalPermission()) then
		return
	end
	local connections = {}
	self.connectionsForListener[listener] = connections
	forEach(self.bridges, function(bridge)
		local newListener = function(message)
			self.outboundBridgeForBridgeId[message.fromBridgeId] = bridge
			local matchesEvent = listener.eventName == nil or listener.eventName == message.eventName
			local matchesBridge = listener.bridgeId == nil or listener.bridgeId == message.toBridgeId
			local matchesTarget = listener.targetId == nil or listener.targetId == message.toTargetId
			if matchesEvent and matchesBridge and matchesTarget then
				listener.onEvent(message)
			end
		end
		local connection = bridge:connect(newListener)
		insert(connections, connection)
	end)
end

function DebugInterface:_disconnect(listener)
	local connections = self.connectionsForListener[listener]
	forEach(connections, function(connection)
		connection:Disconnect()
	end)
end

function DebugInterface:_addTarget(targetName: string, getWorker)
	self:_connectTargets()
	local id = HttpService:GenerateGUID()
	local target = {
		id = id,
		name = targetName,
	}
	self.targets[id] = target
	self:_connect({
		targetId = id,
		eventName = EventName.AttachTarget,
		onEvent = function(message)
			local worker = self.workers[id] or getWorker(id, message.fromBridgeId)
			self.workers[id] = worker
		end
	})
end

function DebugInterface:_removeWorker(id)
	local worker = self.workers[id]
	if worker then
		worker:destroy()
	end
	self.workers[id] = nil
end

function DebugInterface:setGuiOptions(guiOptions)
	self.rootInstance = guiOptions.rootInstance
	self.pickerParent = guiOptions.pickerParent
	self.rootPath = guiOptions.rootPath
	self.rootPrefix = guiOptions.rootPrefix
end

function DebugInterface:destroy()
	forEach(self.bridges, function(bridge)
		bridge:destroy()
	end)
	forEach(self.routers, function(router)
		router:destroy()
	end)
	forEach(self.workers, function(worker)
		worker:destroy()
	end)
end

return DebugInterface