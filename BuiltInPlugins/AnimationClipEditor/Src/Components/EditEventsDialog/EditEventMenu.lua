--[[
	Handles the context menu which appears when the user clicks on an Event entry.

	Props:
		bool ShowMenu = Whether to display the menu.
		function OnMenuOpened = A callback for when the menu is opened.
		function OnMenuItemClicked(item) = A callback for when the user selects
			a menu item. Can be "Edit" or "Delete".
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local Framework = require(Plugin.Packages.Framework)
local Constants = require(Plugin.Src.Util.Constants)
local ContextServices = Framework.ContextServices
local ContextMenu = require(Plugin.Src.Components.ContextMenu)
local GetFFlagRefactorMenus = require(Plugin.LuaFlags.GetFFlagRefactorMenus)

local EditEventMenu = Roact.PureComponent:extend("EditEventMenu")

function EditEventMenu:makeMenuActions(localization)
	local props = self.props
	local actions = {}

	table.insert(actions, {
		Name = localization:getText("ContextMenu", "EditEventName"),
		Value = GetFFlagRefactorMenus() and Constants.ACTION_KEYS.Edit or nil,
		ItemSelected = GetFFlagRefactorMenus() and props.OnMenuItemClicked or function()
			props.OnMenuItemClicked(Constants.ACTION_KEYS.Edit)
		end,
	})
	table.insert(actions, {
		Name = localization:getText("ContextMenu", "DeleteAllSameEvents"),
		Value = GetFFlagRefactorMenus() and Constants.ACTION_KEYS.Delete or nil,
		ItemSelected = GetFFlagRefactorMenus() and props.OnMenuItemClicked or function()
			props.OnMenuItemClicked(Constants.ACTION_KEYS.Delete)
		end,
	})

	return actions
end

function EditEventMenu:render()
	local localization = self.props.Localization
	local props = self.props
	local showMenu = props.ShowMenu

	return showMenu and Roact.createElement(ContextMenu, {
		Actions = self:makeMenuActions(localization),
		OnMenuOpened = props.OnMenuOpened,
	}) or nil
end

ContextServices.mapToProps(EditEventMenu, {
	Localization = ContextServices.Localization
})

return EditEventMenu
