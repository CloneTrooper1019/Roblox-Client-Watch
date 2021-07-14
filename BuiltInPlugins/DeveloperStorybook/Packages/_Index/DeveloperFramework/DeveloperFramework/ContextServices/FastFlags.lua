--[[
	FastFlags is a ContextItem that handles flag behavior and exposes methods for overriding flag states
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextItem = require(Framework.ContextServices.ContextItem)
local Provider = require(Framework.ContextServices.Provider)
local Flags = require(Framework.Util).Flags

local function validateIsMap(map, variableName)
	if type(map) ~= "table" then
		error(string.format("Expected %s to be a table", variableName), 2)
	end
	if (type(next(map)) ~= "nil") and (type(next(map)) ~= "string") then
		error(string.format("Expected %s to be map keyed on strings", variableName), 2)
	end
end

local FastFlags = ContextItem:extend("FastFlags")

function FastFlags.new(featuresMap, overrides)
	featuresMap = featuresMap ~= nil and featuresMap or {}
	overrides = overrides ~= nil and overrides or {}
	validateIsMap(featuresMap, "featuresMap")
	validateIsMap(overrides, "overrides")

	local flags = Flags.new(featuresMap)
	for featureName, isOn in pairs(overrides) do
		flags:setLocalOverride(featureName, isOn)
	end

	local self = {
		flags = flags,
	}
	setmetatable(self, FastFlags)
	return self
end

function FastFlags.mock(defaultValue, overrides)
	assert(type(defaultValue) == "boolean", "Expected defaultValue to be a boolean")
	overrides = overrides ~= nil and overrides or {}
	validateIsMap(overrides, "overrides")

	local mockFlags = Flags.mock(false)
	for featureName, isOn in pairs(overrides) do
		mockFlags:setLocalOverride(featureName, isOn)
	end

	local self = {
		flags = mockFlags,
	}
	setmetatable(self, FastFlags)
	return self
end

function FastFlags:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
	}, {root})
end

function FastFlags:get(featureName)
	assert(type(featureName)=="string", "Expected featureName to be a string")
	return self.flags:get(featureName)
end


return FastFlags
