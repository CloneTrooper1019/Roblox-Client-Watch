--[[
	The TargetWorker class is a base for functionality that tracks and notifies the inspector of
	any changes to a local state value.
]]
local Source = script.Parent.Parent
local Packages = Source.Parent
local EventName= require(Source.EventName)

local Dash = require(Packages.Dash)
local class = Dash.class
local forEach = Dash.forEach
local join = Dash.join

local insert = table.insert

local TargetWorker = class("TargetWorker", function(debugInterface, targetId, toBridgeId)
	return {
		targetId = targetId,
		toBridgeId = toBridgeId,
		debugInterface = debugInterface,
		listeners = {}
	}
end)

function TargetWorker:connectEvents()
	self:connect({
		eventName = EventName.CloseTarget,
		onEvent = function(message)
			self.debugInterface:_removeWorker(self.targetId)
		end
	})
end

function TargetWorker:connect(listener)
	local newListener = join(listener, {
		targetId = self.targetId,
	})
	self.debugInterface:_connect(newListener)
	insert(self.listeners, newListener)
end

function TargetWorker:send(message)
	local newMessage = join(message, {
		fromTargetId = self.targetId,
		toBridgeId = self.toBridgeId,
	})
	self.debugInterface:_send(newMessage)
end

function TargetWorker:destroy()
	forEach(self.listeners, function(listener)
		self.debugInterface:_disconnect(listener)
	end)
end

return TargetWorker