return {
	InviteStatus = {
		Success = "Success",
		Moderated = "Moderated",
		Failed = "Failed",
		Pending = "Pending",
	},

	InputType = {
		MouseAndKeyBoard = "MouseAndKeyboard",
		Touch = "Touch",
		Gamepad = "Gamepad",
	},

	FallbackLocaleId = "UNKNOWN_FALLBACK",

	defaultPageKey = "InitalPage",
	advancedSettingsPageKey = "AdvancedGameSettings",
	LeaveToAppPromptPageKey = "LeaveToAppPrompt",
	LeaveGamePromptPageKey = "LeaveGamePrompt",
	MainPagePageKey = "MainPage",
	InitalPageKey = "InitalPage",
	ReportDialogKey = "ReportDialog",

	AnalyticsTargetName = "client",
	AnalyticsInGameMenuName = "ingame_menu",
	AnalyticsRespawnCharacterName = "respawn_character",
	AnalyticsSettingsChangeName = "change_ingame_settings",
	AnalyticsFullscreenModeName = "FullscreenMode",
	AnalyticsMenuActionName = "ingame_menu_action",
	AnalyticsMenuOpenName = "menu_open",
	AnalyticsMenuOpenTypes = {
		Keyboard = "KeyboardShortcut",
		TopbarButton = "TopbarButton",
		ReportAbuseTriggered = "ReportAbuse",
		PlayersTriggered = "Players",
		SettingsTriggered = "Settings",
		EducationalMenuTriggered = "EducationalMenu",

		-- Legacy menu open types. These occur when the old system menu is
		-- opened; the new menu won't trigger it.
		GamepadLeaveGame = "GamepadLeaveGame",
		GamepadResetCharacter = "GamepadResetCharacter",
	},
	AnalyticsMenuCloseName = "menu_close",
	AnalyticsLeaveGameName = "leave_game",
	AnalyticsLeaveToHomeName = "leave_to_home",
	AnalyticsConfirmedName = "confirmed",
	AnalyticsCancelledName = "cancelled",
	AnalyticsReportSubmittedName = "ingame_menu_report_submitted",
	AnalyticsRequestFriendName = "RequestFriendship",
	AnalyticsExamineAvatarName = "examine_avatar",

	DisplayOrder = {
		-- Fullscreen Title Bar should be on top of Topbar (DisplayOrder = 6)
		FullscreenTitleBar = 7,
		ConfirmationDialog = 8,
		EducationalPopup = 9,
	}
}
