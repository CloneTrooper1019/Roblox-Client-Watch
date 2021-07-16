--[[
	The Bridge interface allows code in different plugins / data-models / libraries to communicate
	with each other.

	The BindableEventBridge implementation uses a BindableEvent in the data model to act as a
	message passing interface.
]]

local HttpService = game:GetService("HttpService")

local Source = script.Parent.Parent
local Packages = Source.Parent

local Dash = require(Packages.Dash)
local join = Dash.join
local class = Dash.class
local forEach = Dash.forEach
local insert = table.insert

local BINDABLE_EVENT_NAME = "DeveloperTools"

local BindableEventBridge = class("BindableEventBridge", function(parent: Instance, noCreate: boolean)
	local id = HttpService:GenerateGUID()
	return {
		id = id,
		connections = {},
		noCreate = noCreate
	}
end)

function BindableEventBridge:_createEvent(parent: Instance)
	if self.noCreate then
		return nil
	end
	local event = Instance.new("BindableEvent")
	event.Name = BINDABLE_EVENT_NAME
	event.Parent = parent
	return event
end

function BindableEventBridge:_init(parent: Instance)
	self.event = parent:FindFirstChild(BINDABLE_EVENT_NAME) or self:_createEvent(parent)
end

function BindableEventBridge:send(message)
	local outMessage = join(message, {
		fromBridgeId = self.id
	})
	if self.event then
		self.event:Fire(outMessage)
	end
end 

function BindableEventBridge:connect(listener)
	local function onEvent(message)
		if message.fromBridgeId ~= self.id then
			listener(message)
		end
	end
	if self.event then
		local connection = self.event.Event:Connect(onEvent)
		insert(self.connections, connection)
		return connection
	end
end

function BindableEventBridge:destroy()
	forEach(self.connections, function(connection)
		connection:Disconnect()
	end)
end

return BindableEventBridge