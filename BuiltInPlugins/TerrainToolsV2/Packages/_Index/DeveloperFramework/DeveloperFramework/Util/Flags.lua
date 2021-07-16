--[[
	Fast flag wrapping system.
	Used to define all flags for a plugin at the top level.

	function Flags.new(featuresMap, testingProps): Takes a table mapping feature names to
		flag names, and loads the value for each flag name or creates a
		new flag at that name. Constructs and returns a new Flags instance
		with the feature names mapping to their respective flag values.
		Also allows feature names to map to arrays of flag names, to support dependencies.

	function Flags:get(key): Gets the value for the flag at the current
		feature name, taking into account local overrides for testing.

	function Flags:setLocalOverride(key, value): Sets the local override for the
		flag at the given feature name to the given value.

	function Flags:setAllLocalOverrides(value): Sets the local override for all flags
		to the given value.

	function Flags:clearLocalOverride(key): Clears the local override for the
		flag at the given feature name.

	function Flags:clearAllLocalOverrides(): Clears all local overrides so that 'get'
		will return the actual value for all features.

	Example:
		local FastFlags = Flags.new({
			TextBoxFix = "FixBrokenTextBoxes",
			FocusScrolling = "EnableFocusScrolling",
			BigFeature = {
				"BigFeatureEnabled",
				"BigFeatureBugfix1",
				"BigFeatureOtherBugfix",
			},
		})

		-- test a specific feature
		FastFlags:setLocalOverride("TextBoxFix", true)

		-- test the latest and greatest
		FastFlags:setAllLocalOverrides(true)
]]
local Immutable = require(script.Parent.Immutable)

local function getOrDefineFastFlag(flagName, defaultValue)
	assert(type(defaultValue) == "boolean", "You can only define a fast flag with a boolean value")

	-- TODO DEVTOOLS-4481: This triggers the assert for missing flags in NoOpt/Debug - so the flags need to be defined before this is called in Lua or C++ anyway for now 
	local success, value = pcall(game.GetFastFlag, game, flagName)

	if success and value ~= nil then
		return value
	else
		-- If GetFastFlag fails, the DefineFastFlag may also fail.
		local ok, err = pcall(game.DefineFastFlag, game, flagName, defaultValue)
		if not ok then
			-- This isn't breaking, but we should know about it.
			warn("An error occurred defining the fast flag: " .. flagName)
			warn(err)
		end
		-- Fallback to the defaultValue
		return defaultValue
	end
end

local function assertKeyExists(flagsObj, key)
	if type(key) ~= "string" then
		error("Expected key to be a string.", 2)
	end

	if flagsObj.shouldAssertOnMissingFlag then
		if flagsObj.values[key] == nil then
			error(string.format("`%s` was not defined as a feature name.", key), 2)
		end
	end
end


local Flags = {}
Flags.__index = Flags

-- featuresMap : (map<string, string/table>, optional) a map of featureNames to flagNames.
-- config : (map<string, boolean>, optional) a table for controlling behaviors
-- config.shouldAssertOnMissingFlag : (boolean, optional) throws errors if accessing an undefined flag
-- config.shouldFetchLiveValues : (boolean, optional) when true, will look up and define real flags
-- config.defaultValueIfMissing : (boolean, optional) the value to use when all else fails
function Flags.new(featuresMap, config)
	featuresMap = featuresMap or {}
	config = config or {}
	if config.shouldAssertOnMissingFlag == nil then
		config.shouldAssertOnMissingFlag = true
	end
	if config.shouldFetchLiveValues == nil then
		config.shouldFetchLiveValues = true
	end
	if config.defaultValueIfMissing == nil then
		config.defaultValueIfMissing = false
	end

	assert(type(config.shouldAssertOnMissingFlag) == "boolean", "shouldAssertOnMissingFlag expected to be a boolean")
	assert(type(config.shouldFetchLiveValues) == "boolean", "shouldFetchLiveValues expected to be a boolean")
	assert(type(config.defaultValueIfMissing) == "boolean", "Default values for flags must be a boolean")
	assert(type(featuresMap) == "table", "Flags.new expects a table mapping keys to flag names.")
	local isMap = type((next(featuresMap))) == "nil" or type((next(featuresMap))) == "string"
	assert(isMap, "Flags.new expects a map of string keys.")

	local self = {
		values = {},
		localOverrides = {},

		shouldAssertOnMissingFlag = config.shouldAssertOnMissingFlag,
		shouldFetchLiveValues = config.shouldFetchLiveValues,
		defaultValueIfMissing = config.defaultValueIfMissing,
	}
	setmetatable(self, Flags)

	if self.shouldFetchLiveValues then
		local values = {}
		for key, item in pairs(featuresMap) do
			-- when given a table of flags, aggregate all the flags into a single key.
			-- If all flags exist and are on for this feature, enable this feature.
			if type(item) == "table" then
				local isOn = true
				for _, name in ipairs(item) do
					if not getOrDefineFastFlag(name, self.defaultValueIfMissing) then
						isOn = false
						break
					end
				end
				values[key] = isOn
			else
				values[key] = getOrDefineFastFlag(item, self.defaultValueIfMissing)
			end
		end
		self.values = values

	else
		local values = {}
		for key, _ in pairs(featuresMap) do
			values[key] = self.defaultValueIfMissing
		end
		self.values = values
	end

	return self
end

-- defaultFlagValue : (boolean, optional) the value to use when all else fails
function Flags.mock(defaultFlagValue)
	local self = Flags.new(nil, {
		shouldAssertOnMissingFlag = false,
		shouldFetchLiveValues = false,
		defaultValueIfMissing = defaultFlagValue ~= nil and defaultFlagValue or false,
	})
	return self
end

-- key : (string) the feature name to look up
function Flags:get(key)
	assertKeyExists(self, key)
	if self.localOverrides[key] ~= nil then
		return self.localOverrides[key]
	elseif self.values[key] ~= nil then
		return self.values[key]
	else
		return self.defaultValueIfMissing
	end
end

-- key : (string) the feature name to override
-- value : (boolean) the new value to take precedent
function Flags:setLocalOverride(key, value)
	assertKeyExists(self, key)
	self.localOverrides = Immutable.JoinDictionaries(self.localOverrides, {
		[key] = value,
	})
end

-- value : (boolean) the new value to override all defined flags
function Flags:setAllLocalOverrides(value)
	for key, _ in pairs(self.values) do
		self:setLocalOverride(key, value)
	end
end

-- key : (string) the feature name to clear out a set override
function Flags:clearLocalOverride(key)
	assert(self.localOverrides[key] ~= nil, string.format("'%s' was never set as a local override", key))
	self.localOverrides = Immutable.RemoveFromDictionary(self.localOverrides, key)
end

function Flags:clearAllLocalOverrides()
	self.localOverrides = {}
end

return Flags
