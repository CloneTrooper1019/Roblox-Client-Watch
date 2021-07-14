--[[
	A centralized place for providers, and an entry point for the Roact trees of plugins
]]
local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Packages.Roact)
local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

-- props.localization : (UILibary.Localization) an object for fetching translated strings
-- props.plugin : plugin wrapper created from ContextServices
-- props.store : (Rodux Store) the data store for the plugin
-- props.theme : (Resources.PluginTheme) a table for styling elements in the plugin and UILibrary
local ServiceWrapper = Roact.PureComponent:extend("ServiceWrapper")

function ServiceWrapper:init()
	assert(self.props.analytics ~= nil, "Expected a Analytics object")
	assert(self.props[Roact.Children] ~= nil, "Expected child elements to wrap")
	assert(self.props.localization ~= nil, "Expected a Localization object")
	assert(self.props.plugin ~= nil, "Expected a plugin object")
	assert(self.props.store ~= nil, "Expected a Rodux Store object")
	assert(self.props.theme ~= nil, "Expected a PluginTheme object")
	assert(self.props.mouse ~= nil, "Expected a PluginMouse object")
	assert(self.props.pluginActions ~= nil, "Expect a PluginActions object")
	assert(self.props.signals ~= nil, "Expect a Signals object")
	assert(self.props.editingItemContext ~= nil, "Expect a EditingItemContext")
end


function ServiceWrapper:render()
	local analytics = self.props.analytics
	local children = self.props[Roact.Children]
	local localization = self.props.localization
	local mouse = self.props.mouse
	local store = self.props.store
	local theme = self.props.theme
	local pluginActions = self.props.pluginActions
	local signals = self.props.signals
	local editingItemContext = self.props.editingItemContext

	-- the order of these providers should be read as bottom up,
	-- things most likely to change or trigger updates should be near the top of the list
	return ContextServices.provide({
		analytics,
		localization,
		theme,
		ContextServices.Store.new(store),
		ContextServices.API.new(),
		pluginActions,
		signals,
		ContextServices.Mouse.new(mouse),
		editingItemContext,
	}, children)
end

return ServiceWrapper