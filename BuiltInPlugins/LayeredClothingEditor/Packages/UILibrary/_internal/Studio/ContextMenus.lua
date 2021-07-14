--[[
	A Roact wrapper for the PluginMenu API.

	Props:
		table Actions = The set of actions to send to MakePluginMenu.
		function OnMenuOpened() = A callback for when the context menu has successfully opened.
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local PluginContext = require(Library.Plugin)
local getPlugin = PluginContext.getPlugin
local PluginMenus = require(Library.Studio.PluginMenus)

local ContextMenu = Roact.PureComponent:extend("ContextMenu")

function ContextMenu:showMenu()
	local props = self.props
	local actions = props.Actions
	local plugin = getPlugin(self)

	props.OnMenuOpened()
	PluginMenus.makePluginMenu(plugin, actions)
end

function ContextMenu:didMount()
	self:showMenu()
end

function ContextMenu:didUpdate()
	self:showMenu()
end

function ContextMenu:render()
	return nil
end

return {
	ContextMenu = ContextMenu,
	Separator = PluginMenus.Separator,
}