local FFlagGameSettingsDisplayCollaborativeEditingWarning = game:GetFastFlag("GameSettingsDisplayCollaborativeEditingWarning")

local Page = script.Parent
local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)

local FrameworkUI = require(Plugin.Framework.UI)
local Button = FrameworkUI.Button
local HoverArea = FrameworkUI.HoverArea
local ToggleButtonWithTitle = require(Plugin.Src.Components.ToggleButtonWithTitle)

local Dialog = require(Plugin.Src.ContextServices.Dialog)

local ContextServices = require(Plugin.Framework.ContextServices)

local UILibrary = require(Plugin.UILibrary)
local GetTextSize = UILibrary.Util.GetTextSize
local TitledFrame = UILibrary.Component.TitledFrame

local SimpleDialog = require(Plugin.Src.Components.Dialog.SimpleDialog)
local RadioButtonSet = require(Plugin.Src.Components.RadioButtonSet)
local SettingsPage = require(Plugin.Src.Components.SettingsPages.SettingsPage)

local AddChange = require(Plugin.Src.Actions.AddChange)
local ShutdownAllServers = require(Page.Thunks.ShutdownAllServers)

local LayoutOrderIterator = FFlagGameSettingsDisplayCollaborativeEditingWarning and require(Plugin.Framework.Util).LayoutOrderIterator or nil

local FFlagGameSettingsUseKeyProvider = game:GetFastFlag("GameSettingsUseKeyProvider")
local KeyProvider = FFlagGameSettingsUseKeyProvider and require(Plugin.Src.Util.KeyProvider) or nil

local FFlagGameSettingsEnableVoiceChat = game:GetFastFlag("GameSettingsEnableVoiceChat")

local GetVoiceChatEnabledKeyName = FFlagGameSettingsUseKeyProvider and FFlagGameSettingsEnableVoiceChat and KeyProvider.getVoiceChatEnabledKeyName or nil
local voiceChatEnabledKey = FFlagGameSettingsUseKeyProvider and FFlagGameSettingsEnableVoiceChat and GetVoiceChatEnabledKeyName and GetVoiceChatEnabledKeyName() or "VoiceChatEnabled"

local LOCALIZATION_ID = script.Name

local function loadSettings(store, contextItems)
	local state = store:getState()
	local game = state.Metadata.game
	local gameId = state.Metadata.gameId
	local gameOptionsController = contextItems.gameOptionsController

	return {
		function(loadedSettings)
			local enabled = gameOptionsController:getScriptCollaborationEnabled(game)

			loadedSettings["ScriptCollabEnabled"] = enabled
		end,

		function(loadedSettings)
			if FFlagGameSettingsEnableVoiceChat then
				local optIn = gameOptionsController:getVoiceChatEnabled(gameId)

				loadedSettings[voiceChatEnabledKey] = optIn
			end
		end,
	}
end

local function saveSettings(store, contextItems)
	local state = store:getState()
	local game = state.Metadata.game
	local gameId = state.Metadata.gameId
	local gameOptionsController = contextItems.gameOptionsController

	return {
		function()
			local changed = state.Settings.Changed.ScriptCollabEnabled

			if changed ~= nil then
				gameOptionsController:setScriptCollaborationEnabled(game, changed)
			end
		end,
		function()
			if FFlagGameSettingsEnableVoiceChat then
				local changed = state.Settings.Changed.VoiceChatEnabled

				if changed ~= nil then
					gameOptionsController:setVoiceChatEnabled(gameId, changed)
				end
			end
		end,
	}
end

--Loads settings values into props by key
local function loadValuesToProps(getValue, state)
	local loadedProps = {
		ScriptCollabEnabled = getValue("ScriptCollabEnabled"),
		CurrentScriptCollabEnabled = FFlagGameSettingsDisplayCollaborativeEditingWarning and state.Settings.Current.ScriptCollabEnabled or nil,
		VoiceChatEnabled = FFlagGameSettingsEnableVoiceChat and getValue(voiceChatEnabledKey) or nil,
	}
	return loadedProps
end

--Implements dispatch functions for when the user changes values
local function dispatchChanges(setValue, dispatch)
	local dispatchFuncs = {
		ScriptCollabEnabledChanged = setValue("ScriptCollabEnabled"),
		dispatchShutdownAllServers = function()
			dispatch(ShutdownAllServers())
		end,
		VoiceChatEnabledChanged = setValue(voiceChatEnabledKey),
	}

	return dispatchFuncs
end

local Options = Roact.PureComponent:extend(script.Name)

function Options:render()
	local props = self.props
	local dialog = props.Dialog
	local theme = props.Theme:get("Plugin")
	local localization = props.Localization

	local shutdownButtonText = localization:getText("General","ButtonShutdownAllServers")
	local shutdownButtonFrameSize = Vector2.new(math.huge, theme.button.height)
	local shutdownButtonTextExtents = GetTextSize(shutdownButtonText, theme.fontStyle.Header.TextSize,
		theme.fontStyle.Header.Font, shutdownButtonFrameSize)
	local shutdownButtonButtonWidth = math.max(shutdownButtonTextExtents.X, theme.button.width)
	local shutdownButtonPaddingY = theme.button.height - shutdownButtonTextExtents.Y
	local shutDownButtonSize = UDim2.new(0, shutdownButtonButtonWidth,
		0, shutdownButtonTextExtents.Y + shutdownButtonPaddingY)

	local dispatchShutdownAllServers = props.dispatchShutdownAllServers

	local shouldDisplayWarning
	local layoutIndex
	if FFlagGameSettingsDisplayCollaborativeEditingWarning then
		-- Display warning to user if they are switching Collab off when it is currently saved as on
		shouldDisplayWarning = props.CurrentScriptCollabEnabled and (props.ScriptCollabEnabled == false)
		layoutIndex = LayoutOrderIterator.new()
	end

	local function createChildren()
		local props = self.props

		local localization = props.Localization

		return {
			EnableScriptCollab = FFlagGameSettingsDisplayCollaborativeEditingWarning and 
				Roact.createElement(ToggleButtonWithTitle, {
					Title = localization:getText("General", "TitleScriptCollab"),
					Description = shouldDisplayWarning and localization:getText("General", "ScriptCollabWarning") 
						or localization:getText("General", "ScriptCollabDesc"),
					LayoutOrder = layoutIndex:getNextOrder(),
					Disabled = false,
					Selected = props.ScriptCollabEnabled,
					ShowWarning = shouldDisplayWarning,
					OnClick = function()
						props.ScriptCollabEnabledChanged(not props.ScriptCollabEnabled)
					end,
				})
				or Roact.createElement(RadioButtonSet, {
				LayoutOrder = 1,
				Title = localization:getText("General", "TitleScriptCollab"),
				Enabled = props.ScriptCollabEnabled ~= nil,

				Selected = props.ScriptCollabEnabled,
				SelectionChanged = function(button)
					props.ScriptCollabEnabledChanged(button.Id)
				end,

				Buttons = {{
						Id = true,
						Title = localization:getText("General", "SettingOn"),
						Description = localization:getText("General", "ScriptCollabDesc"),
					}, {
						Id = false,
						Title = localization:getText("General", "SettingOff"),
					},
				},
			}),

			ShutdownAllServers = Roact.createElement(TitledFrame, {
				Title = localization:getText("General", "TitleShutdownAllServers"),
				MaxHeight = 60,
				LayoutOrder = FFlagGameSettingsDisplayCollaborativeEditingWarning and layoutIndex:getNextOrder() or 7,
				TextSize = theme.fontStyle.Normal.TextSize,
				}, {
					VerticalLayout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					ShutdownButton = Roact.createElement(Button, {
						Style = "GameSettingsButton",
						Text = shutdownButtonText,
						Size = shutDownButtonSize,
						LayoutOrder = 1,
						OnClick = function()
							local dialogProps = {
								Size = Vector2.new(343, 145),
								Title = localization:getText("General", "ShutdownDialogHeader"),
								Header = localization:getText("General", "ShutdownDialogBody"),
								Buttons = {
									localization:getText("General", "ReplyNo"),
									localization:getText("General", "ReplyYes"),
								},
							}

							local confirmed = dialog.showDialog(SimpleDialog, dialogProps):await()
							if confirmed then
								dispatchShutdownAllServers()
							end
						end,
					}, {
						Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
					}),

					ShutdownButtonDescription = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Subtext, {
						Size = UDim2.new(1, 0, 0, shutdownButtonTextExtents.Y + theme.shutdownButton.PaddingY),
						LayoutOrder = 2,
						BackgroundTransparency = 1,
						Text = localization:getText("General", "StudioShutdownAllServicesDesc"),
						TextYAlignment = Enum.TextYAlignment.Center,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextWrapped = true,
					})),
			}),

			EnableVoiceChat = FFlagGameSettingsEnableVoiceChat and Roact.createElement(ToggleButtonWithTitle, {
				Title = localization:getText("General", "VoiceChatTitle"),
				Description = localization:getText("General", "VoiceChatText"),
				LayoutOrder = FFlagGameSettingsDisplayCollaborativeEditingWarning and layoutIndex:getNextOrder() or 8,
				Disabled = false,
				Selected = props.VoiceChatEnabled,
				OnClick = function()
					props.VoiceChatEnabledChanged(not props.VoiceChatEnabled)
				end,
			}),
		}
	end

	return Roact.createElement(SettingsPage, {
		SettingsLoadJobs = loadSettings,
		SettingsSaveJobs = saveSettings,
		Title = localization:getText("General", "Category"..LOCALIZATION_ID),
		PageId = LOCALIZATION_ID,
		CreateChildren = createChildren,
	})
end

ContextServices.mapToProps(Options, {
	Theme = ContextServices.Theme,
	Localization = ContextServices.Localization,
	Dialog = Dialog,
})

local settingFromState = require(Plugin.Src.Networking.settingFromState)
Options = RoactRodux.connect(
	function(state, props)
		if not state then return end

		local getValue = function(propName)
			return settingFromState(state.Settings, propName)
		end

		return loadValuesToProps(getValue, state)
	end,

	function(dispatch)
		local setValue = function(propName)
			return function(value)
				dispatch(AddChange(propName, value))
			end
		end

		return dispatchChanges(setValue, dispatch)
	end
)(Options)

Options.LocalizationId = LOCALIZATION_ID

return Options
