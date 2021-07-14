--[[
	A Roact wrapper for the PluginMenu API.

	Required Props:
		table Actions: The set of actions to send to MakePluginMenu.
		callback OnMenuOpened: A callback for when the context menu has successfully opened.
		string Name: name for plugin menu
		Plugin Plugin: A Plugin ContextItem, which is provided via mapToProps.
]]
local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local MakePluginMenu = require(Plugin.Src.Util.MakePluginMenu)
local ContextMenu = Roact.PureComponent:extend("ContextMenu")

local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(ContextMenu, script)

function ContextMenu:showMenu()
	local props = self.props
	local actions = props.Actions
	local plugin = props.Plugin:get()
	props.OnMenuOpened()
	MakePluginMenu(plugin, props.Name, actions)
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

ContextServices.mapToProps(ContextMenu,{
	Plugin = ContextServices.Plugin,
})

return ContextMenu