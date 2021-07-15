--[[
	Provides a global Plugin object to context.
	The Plugin constructor expects a plugin instance, usually
	accessed from the 'plugin' global in the plugin's main script.

	Functions:
		get():
			Returns the plugin instance which was passed in Plugin.new.
]]
local Framework = script.Parent.Parent
local Util = require(Framework.Util)
local FlagsList = Util.Flags.new({
	FFlagRefactorDevFrameworkContextItems = {"RefactorDevFrameworkContextItems"},
})

if FlagsList:get("FFlagRefactorDevFrameworkContextItems") then
	local ContextItem = require(Framework.ContextServices.ContextItem)
	return ContextItem:createSimple("Plugin")
else
	local Roact = require(Framework.Parent.Roact)
	local ContextItem = require(Framework.ContextServices.ContextItem)
	local Provider = require(Framework.ContextServices.Provider)

	local Plugin = ContextItem:extend("Plugin")

	function Plugin.new(plugin)
		local self = {
			plugin = plugin,
		}

		setmetatable(self, Plugin)
		return self
	end

	function Plugin:createProvider(root)
		return Roact.createElement(Provider, {
			ContextItem = self,
		}, {root})
	end

	function Plugin:get()
		return self.plugin
	end

	return Plugin
end