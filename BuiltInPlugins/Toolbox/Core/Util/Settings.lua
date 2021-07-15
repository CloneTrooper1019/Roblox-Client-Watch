local Plugin = script.Parent.Parent.Parent

local DebugFlags = require(Plugin.Core.Util.DebugFlags)


local Category = require(Plugin.Core.Types.Category)
local Sort = require(Plugin.Core.Types.Sort)

local Settings = {}
Settings.__index = Settings

local disableMarketplaceAndRecents = require(Plugin.Core.Util.ToolboxUtilities).disableMarketplaceAndRecents
local showRobloxCreatedAssets = require(Plugin.Core.Util.ToolboxUtilities).showRobloxCreatedAssets

local FFlagToolboxDisableMarketplaceAndRecentsForLuobu = game:GetFastFlag("ToolboxDisableMarketplaceAndRecentsForLuobu")
local FFlagToolboxShowRobloxCreatedAssetsForLuobu = game:GetFastFlag("ToolboxShowRobloxCreatedAssetsForLuobu")

-- Built in plugins share the same namespace for settings, so mark this as from the toolbox
local SETTING_PREFIX = "Toolbox_"
local SELECTED_CATEGORY_NAME_KEY = SETTING_PREFIX .. "SelectedCategoryName"
local SELECTED_SEARCH_TERM_KEY = SETTING_PREFIX .. "SelectedSearchTerm"
local SELECTED_SORT_INDEX_KEY = SETTING_PREFIX .. "SelectedSortIndex"

function Settings.new(plugin)
	local self = {
		_plugin = plugin,
	}

	setmetatable(self, Settings)

	return self
end

function Settings:_getSetting(setting, default)
	if not self._plugin then
		return default
	end

	local value = self._plugin:GetSetting(setting)

	if DebugFlags.shouldLogSettings() then
		print(("Settings:_getSetting(setting=\"%s\", default=%s) got value = %s"):format(
			tostring(setting),
			type(default) == "string" and '"' .. tostring(default) .. '"' or tostring(default),
			type(value) == "string" and '"' .. tostring(value) .. '"' or tostring(value)))
	end

	if not value then
		value = default
	end
	return value
end

function Settings:_setSetting(setting, value)
	if not self._plugin then
		return
	end

	if DebugFlags.shouldLogSettings() then
		print(("Settings:_setSetting(setting=\"%s\", value=%s)"):format(
			tostring(setting),
			type(value) == "string" and '"' .. tostring(value) .. '"' or tostring(value)))
	end

	self._plugin:SetSetting(setting, value)
end

function Settings:getSelectedCategoryName()
	return self:_getSetting(SELECTED_CATEGORY_NAME_KEY, Category.DEFAULT.name)
end

function Settings:setSelectedCategoryName(categoryName)
	return self:_setSetting(SELECTED_CATEGORY_NAME_KEY, categoryName)
end

function Settings:getSelectedSearchTerm()
	return self:_getSetting(SELECTED_SEARCH_TERM_KEY, "")
end

function Settings:setSelectedSearchTerm(searchTerm)
	return self:_setSetting(SELECTED_SEARCH_TERM_KEY, searchTerm)
end

function Settings:getSelectedSortIndex()
	return self:_getSetting(SELECTED_SORT_INDEX_KEY, 1)
end

function Settings:setSelectedSortIndex(index)
	return self:_setSetting(SELECTED_SORT_INDEX_KEY, index)
end

function Settings:updateFromPageInfo(pageInfo)
	if DebugFlags.shouldLogSettings() then
		print("Settings:updateFromPageInfo()")
	end

	self:setSelectedCategoryName(pageInfo.categoryName)
	self:setSelectedSearchTerm(pageInfo.searchTerm)
	self:setSelectedSortIndex(pageInfo.sortIndex)
end

function Settings:loadInitialSettings()
	if DebugFlags.shouldLogSettings() then
		print("Settings:loadInitialSettings()")
	end

	local initSettings = {}
	if FFlagToolboxDisableMarketplaceAndRecentsForLuobu and disableMarketplaceAndRecents() then
		-- We don't allow Marketplace or Recents for Luobu. We can't risk the loaded setting defaulting to Marketplace.
		initSettings.categoryName = Category.DEFAULT.name
	else
		initSettings.categoryName = self:getSelectedCategoryName()
	end

	if FFlagToolboxShowRobloxCreatedAssetsForLuobu and showRobloxCreatedAssets() then
		-- Override default settings to only show Roblox created assets for Luobu
		initSettings.tab = Category.MARKETPLACE_KEY
		initSettings.categoryName = Category.DEFAULT.name
		initSettings.creator = Category.CREATOR_ROBLOX
	end

	initSettings.searchTerm = self:getSelectedSearchTerm()
	initSettings.sortIndex = self:getSelectedSortIndex()

	if game:FindFirstChild("DefaultToolboxSearch") then
		initSettings.searchTerm = game.DefaultToolboxSearch.Value
		-- Also set the initial category to free models and relevant sort
		initSettings.categoryName = Category.DEFAULT.name
		initSettings.sortIndex = Sort.getDefaultSortForCategory(initSettings.categoryName)
	end

	if not Sort.canSort(initSettings.searchTerm, initSettings.categoryName) then
		initSettings.sortIndex = Sort.getDefaultSortForCategory(initSettings.categoryName)
	end

	return initSettings
end

return Settings
