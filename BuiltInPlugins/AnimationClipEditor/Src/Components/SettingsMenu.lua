--[[
	Handles the settings menu which appears when the user clicks the SettingsButton.

	Props:
		bool ShowMenu = Whether to display the menu.
		function OnMenuOpened = A callback for when the menu is displayed.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)
local RoactRodux = require(Plugin.Packages.RoactRodux)
local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local Constants = require(Plugin.Src.Util.Constants)

local ContextMenu = require(Plugin.Src.Components.ContextMenu)
local SetShowAsSeconds = require(Plugin.Src.Actions.SetShowAsSeconds)
local ToggleSnapToKeys = require(Plugin.Src.Thunks.ToggleSnapToKeys)
local SetFrameRate = require(Plugin.Src.Thunks.SetFrameRate)
local SetShowEvents = require(Plugin.Src.Actions.SetShowEvents)

local GetFFlagRefactorMenus = require(Plugin.LuaFlags.GetFFlagRefactorMenus)

local SettingsMenu = Roact.PureComponent:extend("SettingsMenu")

function SettingsMenu:makeTimelineUnitMenu(localization)
	local props = self.props

	return {
		Name = localization:getText("Settings", "TimelineUnit"),
		Items = {
			{Name = localization:getText("Settings", "Seconds"), Value = Constants.TIMELINE_UNITS.Seconds},
			{Name = localization:getText("Settings", "Frames"), Value = Constants.TIMELINE_UNITS.Frames},
		},
		CurrentItem = not GetFFlagRefactorMenus() and (props.ShowAsSeconds and Constants.TIMELINE_UNITS.Seconds or Constants.TIMELINE_UNITS.Frames) or nil,
		CurrentValue = GetFFlagRefactorMenus() and (props.ShowAsSeconds and Constants.TIMELINE_UNITS.Seconds or Constants.TIMELINE_UNITS.Frames) or nil,
		ItemSelected = function(item)
			props.SetShowAsSeconds(item.Value == Constants.TIMELINE_UNITS.Seconds)
			props.Analytics:report("onTimeUnitChanged", item.Value)
		end,
	}
end

function SettingsMenu:makeFrameRateMenu(localization)
	local props = self.props
	local animationData = props.AnimationData
	if not animationData or not animationData.Metadata then
		return
	end

	local currentFPS = animationData.Metadata.FrameRate

	local isPresetFrameRate = false
	for _, fps in pairs(Constants.FRAMERATES) do
		if fps ~= Constants.FRAMERATES.CUSTOM and fps == currentFPS then
			isPresetFrameRate = true
			break
		end
	end

	return {
		Name = localization:getText("Settings", "FrameRate") ..": " ..currentFPS .." fps",
		Items = {
			{Name = localization:getText("Settings", "24FPS"), Value = Constants.FRAMERATES.FPS_24},
			{Name = localization:getText("Settings", "30FPS"), Value = Constants.FRAMERATES.FPS_30},
			{Name = localization:getText("Settings", "60FPS"), Value = Constants.FRAMERATES.FPS_60},
			{Name = localization:getText("Settings", "120FPS"), Value = Constants.FRAMERATES.FPS_120},
			{Name = localization:getText("Settings", "CustomFPS") .."...", Value = Constants.FRAMERATES.CUSTOM},
		},

		CurrentItem = not GetFFlagRefactorMenus() and (isPresetFrameRate and currentFPS or Constants.FRAMERATES.CUSTOM) or nil,
		CurrentValue = GetFFlagRefactorMenus() and (isPresetFrameRate and currentFPS or Constants.FRAMERATES.CUSTOM) or nil,
		ItemSelected = function(item)
			if item.Value ~= Constants.FRAMERATES.CUSTOM then
				props.SetFrameRate(item.Value)
			else
				if props.OnChangeFPS then
					props.OnChangeFPS()
				end
			end
		end,
	}
end

function SettingsMenu:makeMenuActions(localization)
	local props = self.props
	local actions = {}

	table.insert(actions, self:makeTimelineUnitMenu(localization))
	table.insert(actions, Constants.MENU_SEPARATOR)

	table.insert(actions, self:makeFrameRateMenu(localization))
	table.insert(actions, Constants.MENU_SEPARATOR)

	table.insert(actions, {
		Name = localization:getText("Settings", "ShowEvents"),
		IsEnabled = not GetFFlagRefactorMenus() and props.ShowEvents or nil,
		Checked = GetFFlagRefactorMenus() and props.ShowEvents or nil,
		ItemSelected = function()
			props.SetShowEvents(not props.ShowEvents)
		end,
	})
	table.insert(actions, {
		Name = localization:getText("Settings", "SnapToKeys"),
		IsEnabled = not GetFFlagRefactorMenus() and props.SnapToKeys or nil,
		Checked = GetFFlagRefactorMenus() and props.SnapToKeys or nil,
		ItemSelected = function()
			props.ToggleSnapToKeys()
			props.Analytics:report("onKeyframeSnapChanged", not props.SnapToKeys)
		end,
	})

	return actions
end

function SettingsMenu:render()
	local localization = self.props.Localization
		local props = self.props
		local showMenu = props.ShowMenu

		return showMenu and Roact.createElement(ContextMenu, {
			Actions = self:makeMenuActions(localization),
			OnMenuOpened = props.OnMenuOpened,
		}) or nil
end

local function mapStateToProps(state, props)
	local status = state.Status

	local stateToProps = {
		ShowAsSeconds = status.ShowAsSeconds,
		SnapToKeys = status.SnapToKeys,
		ShowEvents = status.ShowEvents,
		Analytics = state.Analytics,
		AnimationData = state.AnimationData,
	}

	return stateToProps
end

local function mapDispatchToProps(dispatch)
	local dispatchToProps = {
		SetShowAsSeconds = function(showAsSeconds)
			dispatch(SetShowAsSeconds(showAsSeconds))
		end,

		ToggleSnapToKeys = function()
			dispatch(ToggleSnapToKeys())
		end,

		SetFrameRate = function(frameRate)
			dispatch(SetFrameRate(frameRate))
		end,

		SetShowEvents = function(showEvents)
			dispatch(SetShowEvents(showEvents))
		end,
	}

	return dispatchToProps
end

ContextServices.mapToProps(SettingsMenu, {
	Localization = ContextServices.Localization,
	Analytics = ContextServices.Analytics
})

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(SettingsMenu)