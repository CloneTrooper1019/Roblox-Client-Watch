--[[
	Reads data out of the localization table, provides a simple interface for fetching strings

	Props :
		stringResourceTable : (CSV localization file) the file with the English strings, used for development
		translationResourceTable : (CSV localization file) the file with all of the translated strings
		pluginName : (string) the "plugin_name" field used in the localization file's keys

	Optional Props :
		namespace : (string) the namespace of all keys in the localization, defaults to "Studio"
		overrideGetLocale : (function<string>(void)) a function that returns a localeId
		overrideLocaleId : (string) a locale used to ignore the current locale set by Roblox
		overrideLocaleChangedSignal : (Signal) a signal that the user has changed to a different language
		overrideTranslator : (function<>())

	- NOTE -
	To make the localization resource files backend friendly, the keys should be structured like this:
		<namespace>.<plugin_name>.<scope>.<key>

	For formatted strings, follow this guide online : https://developer.roblox.com/articles/localization-format-strings

	For example, your DevelopmentReferenceTable.csv should look something like this :
		Key,Context,Example,Source,en
		Studio.MoneyManager.Currency.Robux,the name displayed for Robux,,,R$
		Studio.MoneyManager.Currency.USD,the name displayed for US dollars,,,USD
		Studio.MoneyManager.Sell.LimitedsTitle,the page title for selling limited items,,,Sell your limiteds
		Studio.MoneyManager.Sell.LimitedValue,shows how much an item is worth,,
			{item}{value:int}{currency},
			{item} is worth {value:int} {currency}

	And your TranslationReferenceTable.csv should look something like this : (line breaks added for readability)
		Key,Context,Example,Source,de,es,es-es,ja,ko
		Studio.MoneyManager.Sell.LimitedValue,
			{item}{value:int}{currency},				-- Source
			{item} ist fünf {value:int} {currency},		-- de
			{item} vale {value:int} {currency},			-- es
			{item} vale {value:int} {currency},			-- es-es
			{item}は{value:int}{currency}の価値がある,		-- ja
			{item}은{value:int}{currency}가치가있다.		-- ko

		(it is okay for keys to be missing in this file. This file can be empty and that's fine)

	Localization Usage :
		local rsTable = script.Parent.DevelopmentReferenceTable
		local trsTable = script.Parent.TranslationReferenceTable
		local pluginLocalization = Localization.new({
			stringResourceTable = rsTable,
			translationResourceTable = trsTable,
			pluginName = "MoneyManager"
		})
		local example = pluginLocalization:getText("Sell", "LimitedsValue", {
			item = "Valkyrie Helm",
			value = 71850,
			currency = "R$"
		})
]]

-- services
local StudioService = game:GetService("StudioService")

-- libraries
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextItem = require(Framework.ContextServices.ContextItem)
local Provider = require(Framework.ContextServices.Provider)
local Util = require(Framework.Util)
local Signal = Util.Signal
local Cryo = Util.Cryo

-- constants
local MOCK_PLUGIN_NAME = "Test"
local FALLBACK_LOCALE = "en-us"

local Localization = ContextItem:extend("Localization")

function Localization.new(props)
	assert(type(props) == "table", "Localization props is expected to be a table.")
	assert(props.stringResourceTable ~= nil, "Localization must have a .csv string resource table for English strings")
	assert(props.translationResourceTable ~= nil, "Localization must have a .csv string resource table of translations")
	assert(type(props.pluginName) == "string", "Please specify the plugin's name")

	if props.libraries ~= nil then
		assert(type(props.libraries) == "table", "Localization libraries prop must be a table or nil")
		for key, value in pairs(props.libraries) do
			assert(type(key) == "string", "Localization libraries key must be a string")
			assert(type(value) == "table", "Localization libraries value must be a table")
			assert(value.stringResourceTable ~= nil, string.format("Localization table %s must have a .csv string resource table for English strings", key))
			assert(value.translationResourceTable ~= nil, string.format("Localization table %s must have a .csv string resource table of translations", key))
		end
	end

	local stringResourceTable = props.stringResourceTable
	local translationResourceTable = props.translationResourceTable
	local overrideGetLocale = props.getLocale
	local overrideLocaleId = props.overrideLocaleId
	local overrideLocaleChangedSignal = props.overrideLocaleChangedSignal
	local keyNamespace = props.namespace
	local keyPluginName = props.pluginName

	if keyNamespace == nil then
		keyNamespace = "Studio"
	end

	local externalLocaleChanged
	if overrideLocaleChangedSignal then
		externalLocaleChanged = overrideLocaleChangedSignal
	else
		externalLocaleChanged = StudioService:GetPropertyChangedSignal("StudioLocaleId")
	end

	-- a function that gets called when the locale changes, returns the new locale
	local function getLocale()
		if overrideGetLocale then
			return overrideGetLocale()
		end

		if overrideLocaleId ~= nil then
			return overrideLocaleId
		else
			return StudioService["StudioLocaleId"]
		end
	end

	local self = {
		-- localeChanged : (Signal<string>)
		--  a public facing signal for Localization consumers to observe updates
		localeChanged = Signal.new(),

		-- externalLocaleChanged : (Signal)
		--  the system signal fired when a user changes their language settings
		externalLocaleChanged = externalLocaleChanged,

		-- externalLocaleChangedConnection : (connection token)
		--  a subscription token for cleaning up the connection
		externalLocaleChangedConnection = nil,

		-- locale : (string)
		--  an id for knowing which translation to read from. ex) "en-us"
		locale = FALLBACK_LOCALE,

		-- keyNamespace : (string)
		-- the first field used to construct a key
		keyNamespace = keyNamespace,

		-- keyPluginName : (string)
		-- the second field used to construct a key
		keyPluginName = keyPluginName,

		-- getLocale : (function<string>())
		--  gets the current locale string
		getLocale = getLocale,
	}

	self.projects = Cryo.Dictionary.join(props.libraries or {}, {
		[self.keyPluginName] = {
			stringResourceTable = stringResourceTable,
			translationResourceTable = translationResourceTable,
		},
	})
	self.translators = {}
	self.fallbackTranslators = {}

	setmetatable(self, Localization)

	-- listen to changes to the locale to alert all listeners of the change
	self.localeChangedConnection = self.externalLocaleChanged:Connect(function()
		self:updateLocaleAndTranslator()
		self.localeChanged:Fire(self)
	end)

	-- create the translators for the first time
	self:updateLocaleAndTranslator()

	return self
end

function Localization:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
		UpdateSignal = self.localeChanged,
	}, {root})
end

-- scope : (string) the general group of data that the key belongs to
-- key : (string) the id of the string in the resource table
-- args : (optional, map<string,variant>) values used to format a string
function Localization:getText(scope, key, args)
	return self:getProjectText(self.keyPluginName, scope, key, args)
end

-- project : (string) the 2nd level group that the key belongs to (plugin name or library name)
-- scope : (string) the general group of data that the key belongs to
-- key : (string) the id of the string in the resource table
-- args : (optional, map<string,variant>) values used to format a string
function Localization:getProjectText(project, scope, key, args)
	assert(type(project) == "string", "Cannot fetch the string without a project")
	assert(type(scope) == "string", "Cannot fetch the string without a scope")
	assert(type(key) == "string", "Cannot fetch a string without the key")
	assert(self.projects[project] ~= nil, string.format("Project %s is not available", project))

	local stringKey = string.format("%s.%s.%s.%s", self.keyNamespace, project, scope, key)

	local function getTranslation(translator)
		if not translator then
			return false, nil
		end

		local success, result = pcall(function()
			return translator:FormatByKey(stringKey, args)
		end)
		return success, result
	end

	local translator = self.translators[project]
	local fallbackTranslator = self.fallbackTranslators[project]

	-- optimize for one lookup when the locale is English
	local success
	local translated
	if self.locale == FALLBACK_LOCALE then
		-- English strings are only written into the development string table,
		--  so don't bother looking up the key in the localization table.
		success, translated = getTranslation(fallbackTranslator)
		if success then
			return translated
		end

	else
		-- try to find a translation in our translation file
		success, translated = getTranslation(translator)
		if success then
			return translated
		end

		-- If no translation exists for this locale id, fall back to default (English)
		success, translated = getTranslation(fallbackTranslator)
		if success then
			return translated
		end
	end
	
	if self.keyPluginName ~= MOCK_PLUGIN_NAME and not success and not string.find(translated, "LocalizationTable or parent tables do not contain a translation") then
		-- TODO DEVTOOLS-4532: Use logger contextItem for this
		warn(translated, debug.traceback())
	end

	-- Fall back to the given key if there is no translation for this value
	-- Useful for finding misspelled or missing keys
	return stringKey
end

function Localization:destroy()
	if self.localeChangedConnection then
		self.localeChangedConnection:Disconnect()
	end
end

function Localization:updateLocaleAndTranslator()
	-- the locale has changed, update the translators
	self.locale = self.getLocale()
	for key, project in pairs(self.projects) do
		self.translators[key] = project.translationResourceTable:GetTranslator(self.locale)
		self.fallbackTranslators[key] = project.stringResourceTable:GetTranslator(FALLBACK_LOCALE)
	end
end

function Localization.mock(props)
	local mockResourceTable = {
		GetTranslator = function()
			local translator = {
				FormatByKey = function(_, key, args)
					local argString = ""

					if args then
						if type(args) ~= "table" then
							error("Args must be a table")
						else
							for key, value in pairs(args) do
								argString = string.format("%s,%s:%s", argString, key, value)
							end
							argString = string.sub(argString, 2)
						end
					end

					-- return a string like Studio.Test.myScope.myKey:[argKey:argValue]
					return string.format("%s:[%s]", key, argString)
				end,
			}

			return translator
		end
	}

	local currentLocaleIndex = 0
	local localeIDs = {"en-us", "es-es", "ko-kr", "ja-jp"}
	local function getLocale()
		currentLocaleIndex = math.max((currentLocaleIndex + 1) % #localeIDs, 1)
		local nextLocale = localeIDs[currentLocaleIndex]
		return nextLocale
	end

	-- create a mock localization object for tests
	return Localization.new(Cryo.Dictionary.join({
		-- create a mock resource file that mimics the real thing
		stringResourceTable = mockResourceTable,
		translationResourceTable = mockResourceTable,

		pluginName = MOCK_PLUGIN_NAME,

		-- for tests, don't connect to any system signals to ensure stuff doesn't change mid test
		overrideLocaleChangedSignal = Signal.new(),
		getLocale = getLocale,
	}, props or {}))
end


return Localization
