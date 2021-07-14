--[[
	Handles the menu which appear when the user clicks next to the animation
	name at the top left corner of the window.

	Props:
		bool ShowMenu = Whether to display the menu.
		string CurrentAnimation = The currently loaded animation.

		function OnMenuOpened() = A callback for when the menu is displayed.
		function OnOverwriteRequested(name) = A callback for when the user initiated
			overwriting the animation at the given name with the current animation.
		function OnSaveAsRequested(name) = A callback for when the user wants to
			save the current animation at the given name.
		function OnCreateNewRequested() = A callback for when the user wants to
			create a new animation.
		function OnLoadRequested() = A callback for when the user wants to load a
			new animation.
		function OnImportRequested() = A callback for when the user wants to
			import a new animation from Roblox.
		function OnImportFbxRequested() = A callback for when the user wants to
			import a new animation from FBX.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local Framework = require(Plugin.Packages.Framework)
local RigUtils = require(Plugin.Src.Util.RigUtils)
local Constants = require(Plugin.Src.Util.Constants)

local ContextServices = Framework.ContextServices

local GetFFlagUseAnimationClipEditorConstantsSeparator = require(Plugin.LuaFlags.GetFFlagUseAnimationClipEditorConstantsSeparator)

local ContextMenu = require(Plugin.Src.Components.ContextMenu)

local Separator = GetFFlagUseAnimationClipEditorConstantsSeparator() and Constants.MENU_SEPARATOR or ContextMenu.Separator

local SaveKeyframeSequence = require(Plugin.Src.Thunks.Exporting.SaveKeyframeSequence)
local ExportKeyframeSequence = require(Plugin.Src.Thunks.Exporting.ExportKeyframeSequence)
local AddWaypoint = require(Plugin.Src.Thunks.History.AddWaypoint)
local UpdateMetadata = require(Plugin.Src.Thunks.UpdateMetadata)
local GetFFlagRefactorMenus = require(Plugin.LuaFlags.GetFFlagRefactorMenus)

local AnimationClipMenu = Roact.PureComponent:extend("AnimationClipMenu")

function AnimationClipMenu:makeLoadMenu(localization, current)
	local props = self.props
	local onLoadRequested = props.OnLoadRequested
	local saves = RigUtils.getAnimSaves(props.RootInstance)
	local items = {
	}

	if #saves > 0 then
		for _, save in ipairs(saves) do
			table.insert(items, {
				Name = save.Name,
				Value = not GetFFlagRefactorMenus() and save.Name or nil,
				Key = not GetFFlagRefactorMenus() and save.Name or nil,
				ItemSelected = GetFFlagRefactorMenus() and onLoadRequested or function()
					onLoadRequested(save.Name)
				end,
			})
		end
		return {
			Name = localization:getText("Menu", "Load"),
			Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "Load") or nil,
			CurrentKey = not GetFFlagRefactorMenus() and current or nil,
			Items = items,
			IsAvailable = not GetFFlagRefactorMenus() and true or nil,
		}
	end

	return {
		Name = localization:getText("Menu", "Load"),
		Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "Load") or nil,
		CurrentKey = not GetFFlagRefactorMenus() and current or nil,
		IsAvailable = false,  -- Remove when retiring GetFFlagRefactorMenus
		Enabled = false
	}
end

function AnimationClipMenu:makeSaveAsMenu(localization, current)
	local props = self.props
	local onOverwriteRequested = props.OnOverwriteRequested
	local onSaveAsRequested = props.OnSaveAsRequested
	local saves = RigUtils.getAnimSaves(props.RootInstance)
	local items = {
		{
			Name = localization:getText("Menu", "New"),
			Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "New") or nil,
			ItemSelected = onSaveAsRequested,
		},
	}

	if #saves > 0 then
		table.insert(items, Separator)
	end

	for _, save in ipairs(saves) do
		table.insert(items, {
			Name = save.Name,
			Value = not GetFFlagRefactorMenus() and save.Name or nil,
			Key = not GetFFlagRefactorMenus() and save.Name or nil,
			ItemSelected = GetFFlagRefactorMenus() and onOverwriteRequested or function()
				onOverwriteRequested(save.Name)
			end,
		})
	end

	return {
		Name = localization:getText("Menu", "SaveAs"),
		Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "SaveAs") or nil,
		CurrentKey = not GetFFlagRefactorMenus() and current or nil,
		CurrentValue = GetFFlagRefactorMenus() and current or nil,
		Items = items,
	}
end

-- Creates a submenu for selecting an enum item.
function AnimationClipMenu:makePrioritySubMenu(localization, current)
	local props = self.props
	local priority = Enum.AnimationPriority
	local setPriority = props.SetPriority

	return {
		Name = localization:getText("Menu", "SetPriority"),
		Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "SetPriority") or nil,
		CurrentItem = not GetFFlagRefactorMenus() and current or nil,
		CurrentValue = GetFFlagRefactorMenus() and current or nil,
		Items = {
			{Name = localization:getText("Menu", priority.Core.Name), Key = not GetFFlagRefactorMenus() and priority.Core or nil, Value = priority.Core, ItemSelected = setPriority},
			{Name = localization:getText("Menu", priority.Idle.Name), Key = not GetFFlagRefactorMenus() and priority.Idle or nil, Value = priority.Idle, ItemSelected = setPriority},
			{Name = localization:getText("Menu", priority.Movement.Name), Key = not GetFFlagRefactorMenus() and priority.Movement or nil, Value = priority.Movement, ItemSelected = setPriority},
			{Name = localization:getText("Menu", priority.Action.Name), Key = not GetFFlagRefactorMenus() and priority.Action or nil, Value = priority.Action, ItemSelected = setPriority},
		}
	}
end

function AnimationClipMenu:makeMenuActions(localization)
	local props = self.props
	local onCreateNewRequested = props.OnCreateNewRequested
	local current = props.CurrentAnimation or ""
	local animationData = props.AnimationData
	local plugin = props.Plugin

	local currentPriority = animationData and animationData.Metadata
		and animationData.Metadata.Priority

	local actions = {}
	table.insert(actions, self:makeLoadMenu(localization, current))
	table.insert(actions, {
		Name = localization:getText("Menu", "Save"),
		Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "Save") or nil,
		ItemSelected = function()
			props.SaveKeyframeSequence(current, props.Analytics)
		end,
	})
	table.insert(actions, self:makeSaveAsMenu(localization, current))
	table.insert(actions, Separator)
	table.insert(actions, {
		Name = localization:getText("Menu", "Import"),
		Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "Import") or nil,
		Items = {
			{
				Name = localization:getText("Menu", "FromRoblox"),
				Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "FromRoblox") or nil,
				ItemSelected = props.OnImportRequested,
			},
			{
				Name = localization:getText("Menu", "FromFBX"),
				Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "FromFBX") or nil,
				ItemSelected = props.OnImportFbxRequested,
			},
		}
	})
	table.insert(actions, {
		Name = localization:getText("Menu", "Export"),
		Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "Export") or nil,
		ItemSelected = function()
			props.ExportKeyframeSequence(plugin, props.Analytics)
		end,
	})
	table.insert(actions, Separator)
	table.insert(actions, {
		Name = localization:getText("Menu", "CreateNew"),
		Value = not GetFFlagRefactorMenus() and localization:getText("Menu", "CreateNew") or nil,
		ItemSelected = GetFFlagRefactorMenus() and onCreateNewRequested or function()
			onCreateNewRequested()
		end,
	})
	table.insert(actions, Separator)
	table.insert(actions, self:makePrioritySubMenu(localization, currentPriority))

	return actions
end

function AnimationClipMenu:render()
	local localization = self.props.Localization
	local props = self.props
	local showMenu = props.ShowMenu

	return showMenu and Roact.createElement(ContextMenu, {
		Actions = self:makeMenuActions(localization),
		OnMenuOpened = props.OnMenuOpened,
	}) or nil
end

ContextServices.mapToProps(AnimationClipMenu, {
	Localization = ContextServices.Localization,
	Plugin = ContextServices.Plugin,
	Analytics = ContextServices.Analytics
})

local function mapStateToProps(state, props)
	local status = state.Status
	return {
		RootInstance = status.RootInstance,
		AnimationData = state.AnimationData,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		SaveKeyframeSequence = function(name, analytics)
			dispatch(SaveKeyframeSequence(name, analytics))
		end,

		ExportKeyframeSequence = function(plugin, analytics)
			dispatch(ExportKeyframeSequence(plugin, analytics))
		end,

		SetPriority = function(priority)
			dispatch(AddWaypoint())
			dispatch(UpdateMetadata({
				Priority = priority,
			}))
		end,
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(AnimationClipMenu)
