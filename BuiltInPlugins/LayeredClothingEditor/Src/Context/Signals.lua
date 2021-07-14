--[[
	Provides a global Signals object to context.

	Functions:
		get():
			Returns the signals which were passed in Signals.new.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local DraggerFramework = Plugin.Packages.DraggerFramework
local Signal = require(DraggerFramework.Utility.Signal)

local Framework = require(Plugin.Packages.Framework)
local ContextItem = Framework.ContextServices.ContextItem
local Provider = Framework.ContextServices.Provider

local Signals = ContextItem:extend("Signals")

function Signals.new(signalIDs)
	local self = {}

	setmetatable(self, Signals)

	self.signals = self:__mapSignalIDs(signalIDs)
	return self
end

function Signals:__mapSignalIDs(signalIDs)
    local signals = {}

	for _, signalID in pairs(signalIDs) do
		assert(signals[signalID] == nil, "Duplicate action, ID: " .. signalID)
		local signal = Signal.new()
		signals[signalID] = signal
	end

	return signals
end

function Signals:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
	}, {root})
end

function Signals:get(id)
	return self.signals[id]
end

return Signals