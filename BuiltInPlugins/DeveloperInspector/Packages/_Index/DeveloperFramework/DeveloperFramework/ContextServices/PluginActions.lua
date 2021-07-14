--[[
	Provides a global PluginActions object to context.
	All actions are disabled by default.

	Functions:
		get():
			Returns the plugin actions which were passed in PluginActions.new.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextItem = require(Framework.ContextServices.ContextItem)
local Provider = require(Framework.ContextServices.Provider)
local t = require(Framework.Util.Typecheck.t)

local PluginActions = ContextItem:extend("PluginActions")

function PluginActions.new(plugin, actionDefinitions)
	assert(plugin, "plugin must be provided")
	assert(t.values(t.strictInterface({
		id = t.string,
		text = t.string,
		statusTip = t.optional(t.string),
		iconName = t.optional(t.string),
        allowBinding = t.optional(t.boolean),
        defaultShortcut = t.optional(t.string)
    }))(actionDefinitions))

	local self = {
		plugin = plugin
	}

	setmetatable(self, PluginActions)

	self.actions = self:__mapActionDefinitions(actionDefinitions)
	return self
end

function PluginActions:__mapActionDefinitions(actionDefinitions)
    local actionNamespace = self.plugin.Name
    assert(t.string(actionNamespace), "plugin.Name must be a string")

    local actions = {}

	for _, definition in pairs(actionDefinitions) do

		local id = definition.id
		assert(actions[id] == nil, "Duplicate action, ID: " .. id)

		local text = definition.text
		local statusTip = definition.statusTip or ""
		local iconName = definition.iconName or ""
		local allowBinding = true
		if definition.allowBinding ~= nil then
			allowBinding = definition.allowBinding
		end

		local action = self.plugin:CreatePluginAction(
			actionNamespace .. "_" .. id,
			text,
			statusTip,
			iconName,
			allowBinding
		)
		action.Enabled = false
		if definition.defaultShortcut then
			action.DefaultShortcut = definition.defaultShortcut
		end

		actions[id] = action
	end

	return actions
end

function PluginActions:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
	}, {root})
end

function PluginActions:get(id)
	assert(t.string(id), "id must be a string")
	return self.actions[id]
end

return PluginActions