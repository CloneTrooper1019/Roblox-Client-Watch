--!nocheck
--!nolint GlobalUsedAsLocal

--[[
		Filename: GameSettings.lua
		Written by: jeditkacheff
		Version 1.1
		Description: Takes care of the Game Settings Tab in Settings Menu
--]]
-------------- SERVICES --------------
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpRbxApiService = game:GetService('HttpRbxApiService')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local VRService = game:GetService("VRService")
local SoundService = game:GetService("SoundService")
local AnalyticsService = game:GetService("RbxAnalyticsService")
local Settings = UserSettings()
local GameSettings = Settings.GameSettings

local VoiceChatService = nil

-------------- CONSTANTS --------------
-- DEPRECATED Remove with FixGraphicsQuality
local GRAPHICS_QUALITY_LEVELS = 10

-- DEPRECATED Remove with FixGraphicsQuality
local GRAPHICS_QUALITY_TO_INT = {
	["Enum.SavedQualitySetting.Automatic"] = 0,
	["Enum.SavedQualitySetting.QualityLevel1"] = 1,
	["Enum.SavedQualitySetting.QualityLevel2"] = 2,
	["Enum.SavedQualitySetting.QualityLevel3"] = 3,
	["Enum.SavedQualitySetting.QualityLevel4"] = 4,
	["Enum.SavedQualitySetting.QualityLevel5"] = 5,
	["Enum.SavedQualitySetting.QualityLevel6"] = 6,
	["Enum.SavedQualitySetting.QualityLevel7"] = 7,
	["Enum.SavedQualitySetting.QualityLevel8"] = 8,
	["Enum.SavedQualitySetting.QualityLevel9"] = 9,
	["Enum.SavedQualitySetting.QualityLevel10"] = 10
}
local PC_CHANGED_PROPS = {
	DevComputerMovementMode = true,
	DevComputerCameraMode = true,
	DevEnableMouseLock = true
}
local TOUCH_CHANGED_PROPS = {
	DevTouchMovementMode = true,
	DevTouchCameraMode = true
}
local CAMERA_MODE_DEFAULT_STRING = UserInputService.TouchEnabled and "Default (Follow)" or "Default (Classic)"

local VOICE_CHAT_DEVICE_TYPE = {
	Input = "Input",
	Output = "Output",
}

local FFlagGroupEditDevConsoleButton = settings():GetFFlag("GroupEditDevConsoleButton")
local FFlagMicroProfilerSessionAnalytics = settings():GetFFlag("MicroProfilerSessionAnalytics")
local FFlagCollectAnalyticsForSystemMenu = settings():GetFFlag("CollectAnalyticsForSystemMenu")

local MICROPROFILER_SETTINGS_PRESSED = "MicroprofilerSettingsPressed"

local MOVEMENT_MODE_DEFAULT_STRING = UserInputService.TouchEnabled and "Default (Dynamic Thumbstick)" or "Default (Keyboard)"
local MOVEMENT_MODE_KEYBOARDMOUSE_STRING = "Keyboard + Mouse"
local MOVEMENT_MODE_CLICKTOMOVE_STRING = UserInputService.TouchEnabled and "Tap to Move" or "Click to Move"
local MOVEMENT_MODE_DYNAMICTHUMBSTICK_STRING = "Dynamic Thumbstick"

----------- UTILITIES --------------
local utility = require(RobloxGui.Modules.Settings.Utility)
local Constants
if FFlagCollectAnalyticsForSystemMenu then
	Constants = require(RobloxGui:WaitForChild("Modules"):WaitForChild("InGameMenu"):WaitForChild("Resources"):WaitForChild("Constants"))
end

local CoreUtility = require(RobloxGui.Modules.CoreUtility)
local IsDeveloperConsoleEnabled = require(RobloxGui.Modules.DevConsole.IsDeveloperConsoleEnabled)

------------ Variables -------------------
RobloxGui:WaitForChild("Modules"):WaitForChild("TenFootInterface")
RobloxGui:WaitForChild("Modules"):WaitForChild("Settings"):WaitForChild("SettingsHub")
local isTenFootInterface = require(RobloxGui.Modules.TenFootInterface):IsEnabled()
local PageInstance = nil
local LocalPlayer = Players.LocalPlayer
local platform = UserInputService:GetPlatform()
local PolicyService = require(RobloxGui.Modules.Common.PolicyService)
local VoiceChatServiceManager = require(script.Parent.Parent.Models.VoiceChatServiceManager)
local GetFixGraphicsQuality = require(RobloxGui.Modules.Flags.GetFixGraphicsQuality)
local RenderSettings
local SendNotification
local RobloxTranslator

if GetFixGraphicsQuality() then
	RenderSettings = settings().Rendering
	SendNotification = RobloxGui:WaitForChild("SendNotificationInfo")
	RobloxTranslator = require(RobloxGui:WaitForChild("Modules"):WaitForChild("RobloxTranslator"))
end

local UnlSuccess, UnlResult =
	pcall(
	function()
		return settings():GetFFlag("UseNotificationsLocalization")
	end
)
local FFlagUseNotificationsLocalization = UnlSuccess and UnlResult
game:DefineFastInt("RomarkStartWithGraphicQualityLevel", -1)
local FIntRomarkStartWithGraphicQualityLevel = game:GetFastInt("RomarkStartWithGraphicQualityLevel")

local canUseMicroProfiler = not PolicyService:IsSubjectToChinaPolicies()

local isDesktopClient = (platform == Enum.Platform.Windows) or (platform == Enum.Platform.OSX) or (platform == Enum.Platform.UWP)
local isMobileClient = (platform == Enum.Platform.IOS) or (platform == Enum.Platform.Android)
local UseMicroProfiler = (isMobileClient or isDesktopClient) and canUseMicroProfiler

local GetFFlagEnableVoiceChatOptions = require(RobloxGui.Modules.Flags.GetFFlagEnableVoiceChatOptions)
local GetFFlagEnableVoiceChatOptionsDualServiceOutputs = require(RobloxGui.Modules.Flags.getFFlagEnableVoiceChatOptionsDualServiceOutputs)
local GetFFlagEnableVoiceChatOptionsJoinByGroupIdToken = require(RobloxGui.Modules.Flags.GetFFlagEnableVoiceChatOptionsJoinByGroupIdToken)

local GetDeviceChangedHookEnabled = require(RobloxGui.Modules.Flags.GetFFlagEnableVoiceChatOptionsDeviceChangedHook)

local function reportSettingsForAnalytics()
	if not FFlagCollectAnalyticsForSystemMenu then return end

	local stringTable = {}
	if UserInputService.TouchEnabled then
		stringTable["camera_mode_touch"] = tostring(GameSettings.TouchCameraMovementMode)
	else
		stringTable["camera_mode_desktop"] = tostring(GameSettings.ComputerCameraMovementMode)
	end

	if UserInputService.TouchEnabled then
		stringTable["movement_mode_touch"] = tostring(GameSettings.TouchMovementMode)
	else
		stringTable["movement_mode_desktop"] = tostring(GameSettings.ComputerMovementMode)
	end

	if UserInputService.MouseEnabled then
		stringTable["shift_lock_enabled"] = tostring(GameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch)
	end

	if UserInputService.GamepadEnabled and GameSettings.IsUsingGamepadCameraSensitivity then
		local sensitivity = GameSettings.GamepadCameraSensitivity
		local formattedSensitivity = tonumber(string.format("%.2f", sensitivity))
		stringTable["camera_sensitivity_gamepad"] = tostring(formattedSensitivity)
	end
	if UserInputService.MouseEnabled then
		local sensitivity = GameSettings.MouseSensitivityFirstPerson.X
		local formattedSensitivity = tonumber(string.format("%.2f", sensitivity))
		stringTable["camera_sensitivity_mouse"] = tostring(formattedSensitivity)
	end

	stringTable["camera_y_inverted"] = tostring(GameSettings.CameraYInverted)
	stringTable["show_performance_stats"] = tostring(GameSettings.PerformanceStatsVisible)
	stringTable["volume"] = tostring( math.floor((GameSettings.MasterVolume * 10) + 0.5) )
	stringTable["gfx_quality_level"] = tostring(settings().Rendering.QualityLevel)
	stringTable["fullscreen_enabled"] = tostring(GameSettings:InFullScreen())
	stringTable["microprofiler_enabled"] = tostring(GameSettings.OnScreenProfilerEnabled)
	stringTable["microprofiler_webserver_enabled"] = tostring(GameSettings.MicroProfilerWebServerEnabled)

	stringTable["universeid"] = tostring(game.GameId)
	AnalyticsService:SetRBXEventStream(Constants.AnalyticsTargetName, Constants.AnalyticsInGameMenuName, Constants.AnalyticsSettingsChangeName, stringTable)
end

--------------- FLAGS ----------------

----------- CLASS DECLARATION --------------

local function Initialize()
	local settingsPageFactory = require(RobloxGui.Modules.Settings.SettingsPageFactory)
	local this = settingsPageFactory:CreateNewPage()

	local allSettingsCreated = false
	local settingsDisabledInVR = {}
	local function onVRSettingsReady()
		local vrEnabled = VRService.VREnabled
		for settingFrame, _ in pairs(settingsDisabledInVR) do
			settingFrame.Visible = not vrEnabled
		end
	end

	local function onVREnabled()
		if VRService.VREnabled and allSettingsCreated then
			--Only call this if all settings have been created.
			--If they aren't ready by the time VR is enabled, this
			--will be called later when they are.
			onVRSettingsReady()
		end
	end
	VRService:GetPropertyChangedSignal("VREnabled"):connect(onVREnabled)
	onVREnabled()

	----------- FUNCTIONS ---------------
	local function createGraphicsOptions()
		------------------ Fullscreen Selection GUI Setup ------------------
		local fullScreenInit = 1
		if not GameSettings:InFullScreen() then
			fullScreenInit = 2
		end

		this.FullscreenFrame, this.FullscreenLabel, this.FullscreenEnabler =
			utility:AddNewRow(this, "Fullscreen", "Selector", {"On", "Off"}, fullScreenInit)
		this.FullscreenFrame.LayoutOrder = 8

		settingsDisabledInVR[this.FullscreenFrame] = true

		this.FullscreenEnabler.IndexChanged:connect(
			function(newIndex)
				if newIndex == 1 then
					if not GameSettings:InFullScreen() then
						GuiService:ToggleFullscreen()
						this.FullscreenEnabler:SetSelectionIndex(1)
					end
				elseif newIndex == 2 then
					if GameSettings:InFullScreen() then
						GuiService:ToggleFullscreen()
						this.FullscreenEnabler:SetSelectionIndex(2)
					end
				end
				spawn(function() --fullscreen setting takes a frame to update so need to wait before reporting
					reportSettingsForAnalytics()
				end)
			end
		)

		GameSettings.FullscreenChanged:connect(
			function(isFullScreen)
				if isFullScreen then
					if this.FullscreenEnabler:GetSelectedIndex() ~= 1 then
						this.FullscreenEnabler:SetSelectionIndex(1)
					end
				else
					if this.FullscreenEnabler:GetSelectedIndex() ~= 2 then
						this.FullscreenEnabler:SetSelectionIndex(2)
					end
				end

				AnalyticsService:SetRBXEventStream(Constants.AnalyticsTargetName, Constants.AnalyticsInGameMenuName, Constants.AnalyticsFullscreenModeName, {
					enabled = isFullScreen,
				})
			end
		)

		------------------ Gfx Enabler Selection GUI Setup ------------------
		local graphicsEnablerStart = 1

		if GetFixGraphicsQuality() then
			if GameSettings.GraphicsQualityLevel ~= 0 then
				graphicsEnablerStart = 2
			end
		else
			if GameSettings.SavedQualityLevel ~= Enum.SavedQualitySetting.Automatic then
				graphicsEnablerStart = 2
			end
		end

		this.GraphicsEnablerFrame, this.GraphicsEnablerLabel, this.GraphicsQualityEnabler =
			utility:AddNewRow(this, "Graphics Mode", "Selector", {"Automatic", "Manual"}, graphicsEnablerStart)
		this.GraphicsEnablerFrame.LayoutOrder = 9

		------------------ Gfx Slider GUI Setup  ------------------

		local numGraphicsQualityLevels
		if GetFixGraphicsQuality() then
			numGraphicsQualityLevels = RenderSettings:GetMaxQualityLevel() - 1
			-- Don't be fooled by the word "max". It's not the maximum level, it's a strict upper bound
			-- so if GetMaxQualityLevel() returns 22, that means the biggest the level can be is 21
				

			--[[
				Cache the most recent non-zero graphics level in this member variable.  If the user
				switches to Auto mode, we use it to set the graphics level to whatever the user had set
				the last time they were in manual mode.
			]]
			this.mostRecentGraphicsQualityValue = numGraphicsQualityLevels

			this.GraphicsQualityFrame, this.GraphicsQualityLabel, this.GraphicsQualitySlider =
					utility:AddNewRow(this, "Graphics Quality", "Slider", numGraphicsQualityLevels, 1)
		else
			this.GraphicsQualityFrame, this.GraphicsQualityLabel, this.GraphicsQualitySlider =
				utility:AddNewRow(this, "Graphics Quality", "Slider", GRAPHICS_QUALITY_LEVELS, 1)
		end

		this.GraphicsQualityFrame.LayoutOrder = 10
		this.GraphicsQualitySlider:SetMinStep(1)

		------------------------------------------------------
		------------------------- Connection Setup ----------------------------
		settings().Rendering.EnableFRM = true

		-- DEPRECATED Remove with FixGraphicsQuality
		function SetGraphicsQuality(newValue, automaticSettingAllowed)
			local percentage = newValue / GRAPHICS_QUALITY_LEVELS
			local newQualityLevel = math.floor((settings().Rendering:GetMaxQualityLevel() - 1) * percentage)
			if newQualityLevel == 20 then
				newQualityLevel = 21
			elseif newValue == 1 then
				newQualityLevel = 1
			elseif newValue < 1 and not automaticSettingAllowed then
				newValue = 1
				newQualityLevel = 1
			elseif newQualityLevel > settings().Rendering:GetMaxQualityLevel() then
				newQualityLevel = settings().Rendering:GetMaxQualityLevel() - 1
			end

			GameSettings.SavedQualityLevel = newValue
			settings().Rendering.QualityLevel = newQualityLevel
		end

		-- DEPRECATED Remove with FixGraphicsQuality
		local function setGraphicsToAuto()
			this.GraphicsQualitySlider:SetZIndex(1)
			this.GraphicsQualityLabel.ZIndex = 1
			this.GraphicsQualitySlider:SetInteractable(false)

			SetGraphicsQuality(Enum.QualityLevel.Automatic.Value, true)
		end

		-- DEPRECATED. Remove with FixGraphicsQuality
		local function setGraphicsToManual(level)
			this.GraphicsQualitySlider:SetZIndex(2)
			this.GraphicsQualityLabel.ZIndex = 2
			this.GraphicsQualitySlider:SetInteractable(true)

			-- need to force the quality change if slider is already at this position
			if this.GraphicsQualitySlider:GetValue() == level then
				SetGraphicsQuality(level)
			else
				this.GraphicsQualitySlider:SetValue(level)
			end
		end

		--[[
			Perform a UI change corrseponding to the user setting Auto mode.
		]]
		local function disableGraphicsQualitySliderForAutoMode()
			this.GraphicsQualitySlider:SetZIndex(1)
			this.GraphicsQualityLabel.ZIndex = 1
			this.GraphicsQualitySlider:SetInteractable(false)
		end

		--[[
			Sets the value visible in the slider GUI object to the given number (not an enum)
			If the slider was hidden because we were in Auto mode before, this function also makes
			the slider visible and interactable.

			Also, it doesn't bother setting the value if unchanged.
		]]
		local function setGraphicsQualitySliderLevel(level)
			this.GraphicsQualitySlider:SetZIndex(2)
			this.GraphicsQualityLabel.ZIndex = 2
			this.GraphicsQualitySlider:SetInteractable(true)

			if this.GraphicsQualitySlider:GetValue() ~= level then
				this.GraphicsQualitySlider:SetValue(level)
			end
		end

		--[[
			Perform a settings change corresponding to the user setting Auto mode.
		]]
		local function setGraphicsQualityToAuto()
			GameSettings.GraphicsQualityLevel = 0
			RenderSettings.QualityLevel = 0
			disableGraphicsQualitySliderForAutoMode()
		end

		--[[
			Sets the rendering quality in three places:
			GameSettings, settings() and the GUI.

			GameSettings gets saved to persistent local storage.
			settings() affects the graphics engine.
			To set the GUI, we call setGraphicsQualitySliderLevel, which importantly does nothing if the value is already
			set on the GUI. (Otherwise, we might get into an infinite loop.)

			Returns two values:
				newValue - note that the first thing this function does is clamp to the appropriate range,
					and newValue is the clampped value.
				delta - the difference between the new value and the old value.
		]]
		local function setGraphicsQualityLevel(inputValue)
			local newValue = math.clamp(inputValue, 1, numGraphicsQualityLevels)
			local oldValue = GameSettings.GraphicsQualityLevel

			GameSettings.GraphicsQualityLevel = newValue
			RenderSettings.QualityLevel = newValue
			setGraphicsQualitySliderLevel(newValue)

			this.mostRecentGraphicsQualityValue = newValue

			--[[
				The caller might want to know what effect calling this setter actually had, so we return:
					newValue - the actual new value (after clamping) and
					delta - the difference between the new value and the old one.

				So for instance, if the level was already at the 21, 21 is the maximum, and we
				tried to increment it to 22, this would returna newValue of 21 and a delta of 0
			]]
			return newValue, newValue - oldValue
		end

		--[[
			On startup, set the graphics quality level (according to the engine and also according to UI) to
			the most logical thing. If the fast-int is set that overrides it, set to the overridden value,
			if not, use the value stored in settings: GameSettings.GraphicsQualityLevel
		]]
		local function initGraphicsQualityLevel()
			if FIntRomarkStartWithGraphicQualityLevel >= 0 then
				if FIntRomarkStartWithGraphicQualityLevel == 0 then
					setGraphicsQualityToAuto()
					this.mostRecentGraphicsQualityValue = numGraphicsQualityLevels
				else
					setGraphicsQualityLevel(FIntRomarkStartWithGraphicQualityLevel)
				end
			elseif GameSettings.GraphicsQualityLevel == 0 then
				setGraphicsQualityToAuto()
				this.mostRecentGraphicsQualityValue = numGraphicsQualityLevels
			else
				setGraphicsQualityLevel(GameSettings.GraphicsQualityLevel)
			end
		end

		if GetFixGraphicsQuality() then
			this.GraphicsQualitySlider.ValueChanged:connect(setGraphicsQualityLevel)
				--[[
					Gets called when the user hits the button in settings that switches between Manual and Auto
					we forward that call to the appropriate function above.
				]]
				this.GraphicsQualityEnabler.IndexChanged:connect(
					function(newIndex)
						if newIndex == 1 then
							setGraphicsQualityToAuto()
						elseif newIndex == 2 then
							setGraphicsQualityLevel(this.mostRecentGraphicsQualityValue)
						end
						reportSettingsForAnalytics()
				end
			)

			--[[
				Generates the little popup in the lower right hand corner when the user changes the
				graphics quality level with the F-keys.
			]]
			local function sendNotificationForGraphicsQualityLevelChange(message, level)
				SendNotification:Fire({
					GroupName = "Graphics",
					Title = "Graphics Quality",
					Text = message,
					DetailText = message,
					Image = "",
					Duration = 2
				})
			end

			--[[
				Takes two arguments: newValue, delta. If delta is non-zero, constructs a message for the pop-up
				notification (based on whether delta is positive or negative) to inform the user that the level
				incrememnted / decremented to the new value.
			]]
			local function notifyForLevelChange(newValue, delta)
				if delta > 0 then
					sendNotificationForGraphicsQualityLevelChange(
						RobloxTranslator:FormatByKey("NotificationScrip2.onCurrentGraphicsQualityLevelChanged.Increased", {RBX_NUMBER = tostring(newValue)}),
						newValue)
				elseif delta < 0 then
					sendNotificationForGraphicsQualityLevelChange(
						RobloxTranslator:FormatByKey("NotificationScrip2.onCurrentGraphicsQualityLevelChanged.Decreased", {RBX_NUMBER = tostring(newValue)}),
						newValue)
				end
			end

			--[[
				Gets called when the user hits F10 / Shift-F10 to adjust the graphcs quality level.

				Based on whether the argument indicates an increase (or decrease), calls setGraphicsQualityLevel to increment (or decrement)
				the level. The setter can decide that it doesn't want to increment (if the new value would be out-of-range)
				the setter returns two values newValue and delta indicating what change actually happened.  We then pass thos two values
				to notifyForLevelChange to construct the notification.
			]]
			game.GraphicsQualityChangeRequest:connect(
				function(isIncrease)
					local current = GameSettings.GraphicsQualityLevel
					if current ~= 0 then
						local targetValue = current + (isIncrease and 1 or -1)
						local newValue, delta = setGraphicsQualityLevel(targetValue)
						notifyForLevelChange(newValue, delta)
					end
				end
			)

			initGraphicsQualityLevel()
		else
			-- DEPRECATED Remove with FixGraphicsQuality
			local initializedGfxLvl = false
			this.GraphicsQualitySlider.ValueChanged:connect(
				function(newValue)
					SetGraphicsQuality(newValue)
					if initializedGfxLvl == true then
						reportSettingsForAnalytics()
					end
					initializedGfxLvl = true
				end
			)

			-- DEPRECATED Remove with FixGraphicsQuality
			this.GraphicsQualityEnabler.IndexChanged:connect(
				function(newIndex)
					if newIndex == 1 then
						setGraphicsToAuto()
					elseif newIndex == 2 then
						setGraphicsToManual(this.GraphicsQualitySlider:GetValue())
					end
					reportSettingsForAnalytics()
				end
			)

			-- DEPRECATED Remove with FixGraphicsQuality
			game.GraphicsQualityChangeRequest:connect(
				function(isIncrease)
					--	was using settings().Rendering.Quality level, which was wrongly saying it was automatic.
					if GameSettings.SavedQualityLevel ~= Enum.SavedQualitySetting.Automatic then
						local currentGraphicsSliderValue = this.GraphicsQualitySlider:GetValue()
						if isIncrease then
							currentGraphicsSliderValue = currentGraphicsSliderValue + 1
						else
							currentGraphicsSliderValue = currentGraphicsSliderValue - 1
						end

						this.GraphicsQualitySlider:SetValue(currentGraphicsSliderValue)
					end
				end
			)

			-- DEPRECATED Remove with FixGraphicsQuality
			-- initialize the slider position
			if FIntRomarkStartWithGraphicQualityLevel >= 0 then
				if FIntRomarkStartWithGraphicQualityLevel == 0 then
					this.GraphicsQualityEnabler:SetSelectionIndex(1)
					setGraphicsToAuto()
				else
					this.GraphicsQualityEnabler:SetSelectionIndex(2)
					setGraphicsToManual(FIntRomarkStartWithGraphicQualityLevel)
				end
			elseif GameSettings.SavedQualityLevel == Enum.SavedQualitySetting.Automatic then
				this.GraphicsQualitySlider:SetValue(5)
				setGraphicsToAuto()
			else
				local graphicsLevel = tostring(GameSettings.SavedQualityLevel)
				if GRAPHICS_QUALITY_TO_INT[graphicsLevel] then
					graphicsLevel = GRAPHICS_QUALITY_TO_INT[graphicsLevel]
				else
					graphicsLevel = GRAPHICS_QUALITY_LEVELS
				end
				SetGraphicsQuality(graphicsLevel)
				spawn(
					function()
						this.GraphicsQualitySlider:SetValue(graphicsLevel)
					end
				)
			end
		end
	end -- of createGraphicsOptions

	local function createPerformanceStatsOptions()
		------------------
		------------------ Performance Stats -----------------
		this.PerformanceStatsFrame, this.PerformanceStatsLabel, this.PerformanceStatsMode, this.PerformanceStatsOverrideText =
			nil

		function GetDesiredPerformanceStatsIndex()
			if GameSettings.PerformanceStatsVisible then
				return 1
			else
				return 2
			end
		end

		local startIndex = GetDesiredPerformanceStatsIndex()

		this.PerformanceStatsFrame, this.PerformanceStatsLabel, this.PerformanceStatsMode =
			utility:AddNewRow(this, "Performance Stats", "Selector", {"On", "Off"}, startIndex)
		this.PerformanceStatsFrame.LayoutOrder = 11

		this.PerformanceStatsOverrideText =
			utility:Create "TextLabel" {
			Name = "PerformanceStatsLabel",
			Text = "Set by Developer",
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.SourceSans,
			FontSize = Enum.FontSize.Size24,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 1, 0),
			Position = UDim2.new(1, -350, 0, 0),
			Visible = false,
			ZIndex = 2,
			Parent = this.PerformanceStatsFrame
		}

		this.PerformanceStatsMode.IndexChanged:connect(
			function(newIndex)
				if newIndex == 1 then
					GameSettings.PerformanceStatsVisible = true
				else
					GameSettings.PerformanceStatsVisible = false
				end
				reportSettingsForAnalytics()
			end
		)

		GameSettings.PerformanceStatsVisibleChanged:connect(
			function()
				local desiredIndex = GetDesiredPerformanceStatsIndex()
				if desiredIndex ~= this.PerformanceStatsMode.CurrentIndex then
					this.PerformanceStatsMode:SetSelectionIndex(desiredIndex)
				end
			end
		)
	end -- of createPerformanceStats

	-- Create UI element to show IPs and port a player need to access the
	-- web server for micro profiler
	local function createWebServerInformationRow()
		this.InformationFrame, this.InformationLabel, this.InformationTextBox =
			utility:AddNewRow(this, "MicroProfiler Information", "TextBox", nil, nil, 5)
		this.InformationFrame.LayoutOrder = 99 -- I want this always to be the last shown

		-- Override the default position
		-- todo replace this with TextX and TextYAlignment to centerlise the text
		this.InformationFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

		this.InformationText =
			utility:Create "TextLabel" {
			Name = "InformationLabel",
			Text = "Information Loading",
			Font = Enum.Font.SourceSans,
			FontSize = Enum.FontSize.Size14,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 800, 1, 0),
			Position = UDim2.new(1, -650, 0, 20),
			Visible = true,
			ZIndex = 2,
			Parent = this.InformationFrame
		}
		return this.InformationFrame, this.InformationText
	end

	local function createMicroProfilerOptions()
		------------------
		------------------ Micro Profiler Web Server -----------------
		this.MicroProfilerFrame, this.MicroProfilerLabel, this.MicroProfilerMode, this.MicroProfilerOverrideText = nil

		local function tryContentLabel()
			local port = GameSettings.MicroProfilerWebServerPort
			if port ~= 0 then
				-- Need to create this each time.
				this.InformationFrame, this.InformationText = createWebServerInformationRow()
				this.InformationText.Text = GameSettings.MicroProfilerWebServerIP .. port
				return true
			else
				return false
			end
		end

		local function setMicroProfilerIndex(newIndex)
			local function hideContentLabel()
					GameSettings.MicroProfilerWebServerEnabled = false

					if this.InformationFrame or this.InformationText then
						this.InformationFrame.Visible = false
						this.InformationFrame.Parent = nil
						this.InformationText.Parent = nil
						this.InformationFrame = nil
						this.InformationText = nil
					end
			end

			if isMobileClient then
				if newIndex == 1 then -- Show Web Server Content Label
					GameSettings.MicroProfilerWebServerEnabled = true

					-- Try poll every 0.1 seconds until 3 seconds passed
					local tryPollCount = 30
					while(tryPollCount >= 1) do
						if tryContentLabel() then
							break
						end

						tryPollCount = tryPollCount - 1
						wait(0.1)
					end

					if tryPollCount <= 0 then
						-- if the web server has not been started, we will just set the switch and try to stop the
						-- web server
						this.MicroProfilerMode:SetSelectionIndex(2)
						hideContentLabel()
					end
				else -- Hide Web Server Content Label
						hideContentLabel()
				end
			elseif isDesktopClient then
				GameSettings.OnScreenProfilerEnabled = (newIndex == 1)
			end

			if FFlagMicroProfilerSessionAnalytics then
				AnalyticsService:ReportCounter(MICROPROFILER_SETTINGS_PRESSED)
			end
			reportSettingsForAnalytics()
		end

		-- This should be off default.
		local function GetDesiredWebServerIndex()
			if isMobileClient then
				if GameSettings.MicroProfilerWebServerEnabled then
					return 1
				else
					return 2
				end
			elseif isDesktopClient then
				if GameSettings.OnScreenProfilerEnabled then
					return 1
				else
					return 2
				end
			else
				return 2
			end
		end

		local webServerIndex = GetDesiredWebServerIndex()

		this.MicroProfilerFrame, this.MicroProfilerLabel, this.MicroProfilerMode =
			utility:AddNewRow(this, "Micro Profiler", "Selector", {"On", "Off"}, webServerIndex) -- This can be set to override defualt micro profiler state
		this.MicroProfilerFrame.LayoutOrder = 12

		tryContentLabel()


		local indexChangedExternally = false

		GameSettings:GetPropertyChangedSignal("OnScreenProfilerEnabled"):Connect(function()
			indexChangedExternally = true

			if GameSettings.OnScreenProfilerEnabled then
				this.MicroProfilerMode:SetSelectionIndex(1)
			else
				this.MicroProfilerMode:SetSelectionIndex(2)
			end
		end)

		local function onIndexChanged(...)
			if indexChangedExternally then
				indexChangedExternally = false
			else
				setMicroProfilerIndex(...)
			end
		end

		this.MicroProfilerMode.IndexChanged:connect(onIndexChanged)

	end -- of create Micro Profiler Web Server

	local function createCameraModeOptions(movementModeEnabled)
		------------------------------------------------------
		------------------
		------------------ Shift Lock Switch -----------------
		if UserInputService.MouseEnabled and not isTenFootInterface then
			this.ShiftLockFrame, this.ShiftLockLabel, this.ShiftLockMode, this.ShiftLockOverrideText = nil

			if UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then
				local startIndex = 2
				if GameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch then
					startIndex = 1
				end

				this.ShiftLockFrame, this.ShiftLockLabel, this.ShiftLockMode =
					utility:AddNewRow(this, "Shift Lock Switch", "Selector", {"On", "Off"}, startIndex)
				this.ShiftLockFrame.LayoutOrder = 1

				settingsDisabledInVR[this.ShiftLockFrame] = true

				this.ShiftLockOverrideText =
					utility:Create "TextLabel" {
					Name = "ShiftLockOverrideLabel",
					Text = "Set by Developer",
					TextColor3 = Color3.new(1, 1, 1),
					Font = Enum.Font.SourceSans,
					FontSize = Enum.FontSize.Size24,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 200, 1, 0),
					Position = UDim2.new(1, -350, 0, 0),
					Visible = false,
					ZIndex = 2,
					Parent = this.ShiftLockFrame
				}

				this.ShiftLockMode.IndexChanged:connect(
					function(newIndex)
						if newIndex == 1 then
							GameSettings.ControlMode = Enum.ControlMode.MouseLockSwitch
						else
							GameSettings.ControlMode = Enum.ControlMode.Classic
						end
						reportSettingsForAnalytics()
					end
				)
			end
		end

		-----------------------------------------------------------
		----------------------- Camera Mode -----------------------

		function setCameraModeVisible(visible)
			if this.CameraMode then
				this.CameraMode.SelectorFrame.Visible = visible
				this.CameraMode:SetInteractable(visible)
				this.CameraModeOverrideText.Visible = not visible
			end
		end

		do
			local PlayerScripts = CoreUtility.waitForChildOfClass(LocalPlayer, "PlayerScripts")

			local cameraEnumNames = {}
			local cameraEnumNameToItem = {}

			local function updateCurrentCameraMovementIndex(index)
				local newEnumSetting = nil
				local success =
					pcall(
					function()
						newEnumSetting = cameraEnumNameToItem[cameraEnumNames[index]]
					end
				)
				if not success or newEnumSetting == nil then
					return false
				end

				local actuallyUpdated

				if UserInputService.TouchEnabled then
					actuallyUpdated = GameSettings.TouchCameraMovementMode.Value ~= newEnumSetting
					GameSettings.TouchCameraMovementMode = newEnumSetting
				else
					actuallyUpdated = GameSettings.ComputerCameraMovementMode.Value ~= newEnumSetting
					GameSettings.ComputerCameraMovementMode = newEnumSetting
				end

				return actuallyUpdated
			end

			local function updateCameraMovementModes()
				local enumsToAdd = nil

				if UserInputService.TouchEnabled then
					enumsToAdd = PlayerScripts:GetRegisteredTouchCameraMovementModes()
				else
					enumsToAdd = PlayerScripts:GetRegisteredComputerCameraMovementModes()
				end

				cameraEnumNames = {}
				cameraEnumNameToItem = {}

				if #enumsToAdd <= 0 then
					setCameraModeVisible(false)
					return
				end

				setCameraModeVisible(true)

				for i = 1, #enumsToAdd do
					local newCameraMode = enumsToAdd[i]
					local displayName = newCameraMode.Name
					if displayName == "Default" then
						displayName = CAMERA_MODE_DEFAULT_STRING
					end

					cameraEnumNames[#cameraEnumNames + 1] = displayName
					cameraEnumNameToItem[displayName] = newCameraMode.Value
				end

				if this.CameraMode then
					this.CameraMode:UpdateOptions(cameraEnumNames)
				end

				local currentSavedMode = -1

				if UserInputService.TouchEnabled then
					currentSavedMode = GameSettings.TouchCameraMovementMode.Value
				else
					currentSavedMode = GameSettings.ComputerCameraMovementMode.Value
				end

				if currentSavedMode > -1 then
					currentSavedMode = currentSavedMode + 1
					local savedEnum = nil
					local exists = pcall(function() savedEnum = enumsToAdd[currentSavedMode] end)
					if exists and savedEnum then
						updateCurrentCameraMovementIndex(savedEnum.Value + 1)
						this.CameraMode:SetSelectionIndex(savedEnum.Value + 1)
					end
				end
			end

			this.CameraModeFrame, this.CameraModeLabel, this.CameraMode = utility:AddNewRow(this, "Camera Mode", "Selector", cameraEnumNames, 1)
			this.CameraModeFrame.LayoutOrder = 2

			settingsDisabledInVR[this.CameraMode] = true

			this.CameraModeOverrideText =
				utility:Create "TextLabel" {
				Name = "CameraDevOverrideLabel",
				Text = "Set by Developer",
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.SourceSans,
				FontSize = Enum.FontSize.Size24,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.6, 0, 1, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Visible = false,
				ZIndex = 2,
				Parent = this.CameraModeFrame
			}

			PlayerScripts.TouchCameraMovementModeRegistered:connect(
				function(registeredMode)
					if UserInputService.TouchEnabled then
						updateCameraMovementModes()
					end
				end
			)

			PlayerScripts.ComputerCameraMovementModeRegistered:connect(
				function(registeredMode)
					if UserInputService.MouseEnabled then
						updateCameraMovementModes()
					end
				end
			)

			local hasInitialized = false
			this.CameraMode.IndexChanged:connect(
				function(newIndex)
					if updateCurrentCameraMovementIndex(newIndex) then
						if hasInitialized then
							reportSettingsForAnalytics()
						end
						hasInitialized = true
					end
				end
			)

			updateCameraMovementModes()
		end

		------------------------------------------------------
		------------------
		------------------ VR Mode -----------------------
		local createdVROption = false
		local function createVROption()
			if not createdVROption then
				createdVROption = true

				local optionNames
				if GameSettings.VREnabled then
					optionNames = {"On", "Off (restart pending)"}
				else
					optionNames = {"On (restart pending)", "Off"}
				end

				this.VREnabledFrame, this.VREnabledLabel, this.VREnabledSelector =
					utility:AddNewRow(this, "VR", "Selector", optionNames, GameSettings.VREnabled and 1 or 2)
				this.VREnabledFrame.LayoutOrder = 14

				this.VREnabledSelector.IndexChanged:connect(
					function(newIndex)
						local vrEnabledSetting = (newIndex == 1)
						if GameSettings.VREnabled ~= vrEnabledSetting then
							GameSettings.VREnabled = vrEnabledSetting
						end
					end
				)
			end
		end

		local function onVREnabledChanged()
			if VRService.VREnabled then
				GameSettings.HasEverUsedVR = true
				createVROption()
			else
				if GameSettings.HasEverUsedVR then
					createVROption()
				end
			end
		end
		onVREnabledChanged()
		VRService:GetPropertyChangedSignal("VREnabled"):connect(onVREnabledChanged)

		------------------------------------------------------
		------------------
		------------------ Movement Mode ---------------------
		local movementModes = {}

		function setMovementModeVisible(visible)
			if this.MovementMode then
				local shouldBeVisible = visible and (#movementModes > 0)
				this.MovementMode.SelectorFrame.Visible = shouldBeVisible
				this.MovementMode:SetInteractable(shouldBeVisible)
				this.MovementModeOverrideText.Visible = not shouldBeVisible
			end
		end

		if movementModeEnabled then
			local movementEnumNames = {}
			local movementEnumNameToItem = {}

			local PlayerScripts = CoreUtility.waitForChildOfClass(LocalPlayer, "PlayerScripts")

			local function getDisplayName(name)
				local displayName = name
				if name == "Default" then
					displayName = MOVEMENT_MODE_DEFAULT_STRING
				elseif name == "KeyboardMouse" then
					displayName = MOVEMENT_MODE_KEYBOARDMOUSE_STRING
				elseif name == "ClickToMove" then
					displayName = MOVEMENT_MODE_CLICKTOMOVE_STRING
				elseif name == "DynamicThumbstick" then
					displayName = MOVEMENT_MODE_DYNAMICTHUMBSTICK_STRING
				end

				return displayName
			end

			this.MovementModeFrame, this.MovementModeLabel, this.MovementMode = utility:AddNewRow(this, "Movement Mode", "Selector", movementEnumNames, 1)
			this.MovementModeFrame.LayoutOrder = 3

			settingsDisabledInVR[this.MovementMode] = true

			this.MovementModeOverrideText =
				utility:Create "TextLabel" {
				Name = "MovementDevOverrideLabel",
				Text = "Set by Developer",
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.SourceSans,
				FontSize = Enum.FontSize.Size24,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.6, 0, 1, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Visible = false,
				ZIndex = 2,
				Parent = this.MovementModeFrame
			}

			local function setMovementModeToIndex(index)
				local newEnumSetting = nil
				local success =
					pcall(
					function()
						newEnumSetting = movementEnumNameToItem[movementEnumNames[index]]
					end
				)
				if not success or newEnumSetting == nil then
					return
				end

				if UserInputService.TouchEnabled then
					GameSettings.TouchMovementMode = newEnumSetting
				else
					GameSettings.ComputerMovementMode = newEnumSetting
				end
			end

			local function updateMovementModes()
				if UserInputService.TouchEnabled then
					movementModes = PlayerScripts:GetRegisteredTouchMovementModes()
				else
					movementModes = PlayerScripts:GetRegisteredComputerMovementModes()
				end

				movementEnumNames = {}
				movementEnumNameToItem = {}

				if #movementModes <= 0 then
					setMovementModeVisible(false)
					return
				end

				setMovementModeVisible(true)

				for i = 1, #movementModes do
					local movementMode = movementModes[i]

					local displayName = getDisplayName(movementMode.Name)

					movementEnumNames[#movementEnumNames + 1] = displayName
					movementEnumNameToItem[displayName] = movementMode
				end

				if this.MovementMode then
					this.MovementMode:UpdateOptions(movementEnumNames)
				end

				local currentSavedMode = -1

				if UserInputService.TouchEnabled then
					currentSavedMode = GameSettings.TouchMovementMode.Value
				else
					currentSavedMode = GameSettings.ComputerMovementMode.Value
				end

				if currentSavedMode > -1 then
					currentSavedMode = currentSavedMode + 1
					local savedEnum = nil
					local exists = pcall(function() savedEnum = movementEnumNameToItem[movementEnumNames[currentSavedMode]] end)
					if exists and savedEnum then
						setMovementModeToIndex(savedEnum.Value + 1)
						this.MovementMode:SetSelectionIndex(savedEnum.Value + 1)
					end
				end
			end

			updateMovementModes()

			PlayerScripts.TouchMovementModeRegistered:connect(
				function(registeredMode)
					if UserInputService.TouchEnabled then
						updateMovementModes()
					end
				end
			)

			PlayerScripts.ComputerMovementModeRegistered:connect(
				function(registeredMode)
					if UserInputService.MouseEnabled then
						updateMovementModes()
					end
				end
			)

			this.MovementMode.IndexChanged:connect(
				function(newIndex)
					setMovementModeToIndex(newIndex)
					reportSettingsForAnalytics()
				end
			)
		end

		------------------------------------------------------
		------------------
		------------------------- Connection Setup -----------
		function setShiftLockVisible(visible)
			if this.ShiftLockMode then
				this.ShiftLockMode.SelectorFrame.Visible = visible
				this.ShiftLockMode:SetInteractable(visible)
			end
		end

		do -- initial set of dev vs user choice for guis
			local isUserChoiceCamera = false
			if UserInputService.TouchEnabled then
				isUserChoiceCamera = LocalPlayer.DevTouchCameraMode == Enum.DevTouchCameraMovementMode.UserChoice
			else
				isUserChoiceCamera = LocalPlayer.DevComputerCameraMode == Enum.DevComputerCameraMovementMode.UserChoice
			end

			if not isUserChoiceCamera then
				this.CameraModeOverrideText.Visible = true
				setCameraModeVisible(false)
			else
				this.CameraModeOverrideText.Visible = false
				setCameraModeVisible(true)
			end

			local isUserChoiceMovement = false
			if UserInputService.TouchEnabled then
				isUserChoiceMovement = LocalPlayer.DevTouchMovementMode == Enum.DevTouchMovementMode.UserChoice
			else
				isUserChoiceMovement = LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.UserChoice
			end

			if this.MovementModeOverrideText then
				if not isUserChoiceMovement then
					this.MovementModeOverrideText.Visible = true
					setMovementModeVisible(false)
				else
					this.MovementModeOverrideText.Visible = false
					setMovementModeVisible(true)
				end
			end

			if this.ShiftLockOverrideText then
				this.ShiftLockOverrideText.Visible = not LocalPlayer.DevEnableMouseLock
				setShiftLockVisible(LocalPlayer.DevEnableMouseLock)
			end
		end

		local function updateUserSettingsMenu(property)
			if this.ShiftLockOverrideText and property == "DevEnableMouseLock" then
				this.ShiftLockOverrideText.Visible = not LocalPlayer.DevEnableMouseLock
				setShiftLockVisible(LocalPlayer.DevEnableMouseLock)
			elseif property == "DevComputerCameraMode" then
				local isUserChoice = LocalPlayer.DevComputerCameraMode == Enum.DevComputerCameraMovementMode.UserChoice
				setCameraModeVisible(isUserChoice)
				this.CameraModeOverrideText.Visible = not isUserChoice
			elseif property == "DevComputerMovementMode" then
				-- TOUCH
				local isUserChoice = LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.UserChoice
				setMovementModeVisible(isUserChoice)
				if this.MovementModeOverrideText then
					this.MovementModeOverrideText.Visible = not isUserChoice
				end
			elseif property == "DevTouchMovementMode" then
				local isUserChoice = LocalPlayer.DevTouchMovementMode == Enum.DevTouchMovementMode.UserChoice
				setMovementModeVisible(isUserChoice)
				if this.MovementModeOverrideText then
					this.MovementModeOverrideText.Visible = not isUserChoice
				end
			elseif property == "DevTouchCameraMode" then
				local isUserChoice = LocalPlayer.DevTouchCameraMode == Enum.DevTouchCameraMovementMode.UserChoice
				setCameraModeVisible(isUserChoice)
				this.CameraModeOverrideText.Visible = not isUserChoice
			end
		end

		LocalPlayer.Changed:connect(
			function(property)
				if UserInputService.TouchEnabled then
					if TOUCH_CHANGED_PROPS[property] then
						updateUserSettingsMenu(property)
					end
				end
				if UserInputService.KeyboardEnabled then
					if PC_CHANGED_PROPS[property] then
						updateUserSettingsMenu(property)
					end
				end
			end
		)
	end

	local function createVolumeOptions()
		local startVolumeLevel = math.floor(GameSettings.MasterVolume * 10)
		this.VolumeFrame, this.VolumeLabel, this.VolumeSlider =
			utility:AddNewRow(this, "Volume", "Slider", 10, startVolumeLevel)
		this.VolumeFrame.LayoutOrder = 5

		local volumeSound = Instance.new("Sound", game:GetService("CoreGui").RobloxGui.Sounds)
		volumeSound.Name = "VolumeChangeSound"
		volumeSound.SoundId = "rbxasset://sounds/uuhhh.mp3"

		this.VolumeSlider.ValueChanged:connect(
			function(newValue)
				local soundPercent = newValue / 10
				volumeSound.Volume = soundPercent
				volumeSound:Play()
				GameSettings.MasterVolume = soundPercent
				reportSettingsForAnalytics()
			end
		)
	end

	local function createCameraInvertedOptions()
		local initialIndex = 1
		local success =
			pcall(
			function()
				if GameSettings.CameraYInverted == true then
					initialIndex = 2
				end
			end
		)

		if success == false then
			return
		end

		this.CameraInvertedFrame, _, this.CameraInvertedSelector =
			utility:AddNewRow(this, "Camera Inverted", "Selector", {"Off", "On"}, initialIndex)
		this.CameraInvertedFrame.LayoutOrder = 13
		settingsDisabledInVR[this.CameraInvertedFrame] = true

		this.CameraInvertedSelector.IndexChanged:connect(
			function(newIndex)
				if newIndex == 2 then
					GameSettings.CameraYInverted = true
				else
					GameSettings.CameraYInverted = false
				end
				reportSettingsForAnalytics()
			end
		)
	end

	local function setCameraSensitivity(newValue)
		if UserInputService.GamepadEnabled and GameSettings.IsUsingGamepadCameraSensitivity then
			GameSettings.GamepadCameraSensitivity = newValue
		end
		if UserInputService.MouseEnabled then
			local newVectorValue = Vector2.new(newValue, newValue)
			GameSettings.MouseSensitivityFirstPerson = newVectorValue
			GameSettings.MouseSensitivityThirdPerson = newVectorValue
		end
		reportSettingsForAnalytics()
	end

	local function createMouseOptions()
		local MinMouseSensitivity = 0.2

		-- equations below map a function to include points (0, 0.2) (5, 1) (10, 4)
		-- where x is the slider position, y is the mouse sensitivity
		local function translateEngineMouseSensitivityToGui(engineSensitivity)
			-- 0 <= y <= 1: x = (y - 0.2) / 0.16
			-- 1 <= y <= 4: x = (y + 2) / 0.6
			local guiSensitivity =
				(engineSensitivity <= 1) and math.floor((engineSensitivity - 0.2) / 0.16 + 0.5) or
				math.floor((engineSensitivity + 2) / 0.6 + 0.5)
			return (engineSensitivity <= MinMouseSensitivity) and 0 or guiSensitivity
		end

		local function translateGuiMouseSensitivityToEngine(guiSensitivity)
			-- 0 <= x <= 5:  y = 0.16 * x + 0.2
			-- 5 <= x <= 10: y = 0.6 * x - 2
			local engineSensitivity = (guiSensitivity <= 5) and (0.16 * guiSensitivity + 0.2) or (0.6 * guiSensitivity - 2)
			return (engineSensitivity <= MinMouseSensitivity) and MinMouseSensitivity or engineSensitivity
		end

		local startMouseLevel = translateEngineMouseSensitivityToGui(GameSettings.MouseSensitivity)

		
		------------------ 3D Sensitivity ------------------
		-- affects both first and third person.
		local AdvancedMouseSteps = 10
		local textBoxWidth = 60
		local canSetSensitivity = true
		local _MouseAdvancedStart = tostring(GameSettings.MouseSensitivityFirstPerson.X)

		this.MouseAdvancedFrame, this.MouseAdvancedLabel, this.MouseAdvancedEntry =
			utility:AddNewRow(this, "Camera Sensitivity", "Slider", AdvancedMouseSteps, startMouseLevel)
		this.MouseAdvancedFrame.LayoutOrder = 4
		settingsDisabledInVR[this.MouseAdvancedFrame] = true

		this.MouseAdvancedEntry.SliderFrame.Size =
			UDim2.new(
			this.MouseAdvancedEntry.SliderFrame.Size.X.Scale,
			this.MouseAdvancedEntry.SliderFrame.Size.X.Offset - textBoxWidth,
			this.MouseAdvancedEntry.SliderFrame.Size.Y.Scale,
			this.MouseAdvancedEntry.SliderFrame.Size.Y.Offset - 6
		)
		this.MouseAdvancedEntry.SliderFrame.Position =
			UDim2.new(
			this.MouseAdvancedEntry.SliderFrame.Position.X.Scale,
			this.MouseAdvancedEntry.SliderFrame.Position.X.Offset - textBoxWidth,
			this.MouseAdvancedEntry.SliderFrame.Position.Y.Scale,
			this.MouseAdvancedEntry.SliderFrame.Position.Y.Offset
		)
		this.MouseAdvancedLabel.ZIndex = 2
		this.MouseAdvancedEntry:SetInteractable(true)

		local textBox =
			utility:Create "TextBox" {
			Name = "CameraSensitivityTextBox",
			TextColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0.8, 0.8, 0.8),
			BackgroundColor3 = Color3.new(0.2, 0.2, 0.2),
			Font = Enum.Font.SourceSans,
			TextSize = 18,
			Size = UDim2.new(0, textBoxWidth, 0.8, 0),
			Position = UDim2.new(1, -2, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			ZIndex = 3,
			Selectable = false,
			Parent = this.MouseAdvancedEntry.SliderFrame
		}

		local maxTextBoxStringLength = 7
		local function setTextboxText(newText)
			if string.len(newText) > maxTextBoxStringLength then
				newText = string.sub(newText, 1, maxTextBoxStringLength)
			end
			textBox.Text = newText
		end

		setTextboxText(tostring(GameSettings.MouseSensitivityFirstPerson.X))
		this.MouseAdvancedEntry:SetValue(translateEngineMouseSensitivityToGui(GameSettings.MouseSensitivityFirstPerson.X))

		function clampMouseSensitivity(value)
			if value < 0.0 then
				value = -value
			end

			-- * assume a minimum that allows a 16000 dpi mouse a full 800mm travel for 360deg
			--   ~0.0029: min of 0.001 seems ok.
			-- * assume a max that allows a 400 dpi mouse a 360deg travel in 10mm
			--   ~9.2: max of 10 seems ok, but users will want to have a bit of fun with crazy settings.
			if value > 100.0 then
				value = 100.0
			elseif value < 0.001 then
				value = 0.001
			end

			return value
		end

		function setMouseSensitivity(newValue, widgetOrigin)
			if not canSetSensitivity then
				return
			end

			setCameraSensitivity(newValue)

			canSetSensitivity = false
			do
				if widgetOrigin ~= this.MouseAdvancedEntry then
					this.MouseAdvancedEntry:SetValue(translateEngineMouseSensitivityToGui(newValue))
				end

				setTextboxText(tostring(newValue))
			end
			canSetSensitivity = true
		end

		textBox.FocusLost:connect(
			function()
				this.MouseAdvancedEntry:SetInteractable(true)

				local num = tonumber(string.match(textBox.Text, "([%d%.]+)"))

				if num then
					setMouseSensitivity(clampMouseSensitivity(num), textBox)
				else
					setMouseSensitivity(GameSettings.MouseSensitivityFirstPerson.X, textBox)
				end
			end
		)

		textBox.Focused:connect(
			function()
				this.MouseAdvancedEntry:SetInteractable(false)
			end
		)

		this.MouseAdvancedEntry.ValueChanged:connect(
			function(newValue)
				newValue = clampMouseSensitivity(newValue)
				newValue = translateGuiMouseSensitivityToEngine(newValue)
				setMouseSensitivity(newValue, this.MouseAdvancedEntry)
			end
		)
	end

	local function createGamepadOptions()
		local GamepadSteps = 10
		local MinGamepadCameraSensitivity = 0.2
		-- equations below map a function to include points (0, 0.2) (5, 1) (10, 4)
		-- where x is the slider position, y is the mouse sensitivity
		local function translateEngineGamepadSensitivityToGui(engineSensitivity)
			-- 0 <= y <= 1: x = (y - 0.2) / 0.16
			-- 1 <= y <= 4: x = (y + 2) / 0.6
			local guiSensitivity =
				(engineSensitivity <= 1) and math.floor((engineSensitivity - 0.2) / 0.16 + 0.5) or
				math.floor((engineSensitivity + 2) / 0.6 + 0.5)
			return (engineSensitivity <= MinGamepadCameraSensitivity) and 0 or guiSensitivity
		end
		local function translateGuiGamepadSensitivityToEngine(guiSensitivity)
			-- 0 <= x <= 5:  y = 0.16 * x + 0.2
			-- 5 <= x <= 10: y = 0.6 * x - 2
			local engineSensitivity = (guiSensitivity <= 5) and (0.16 * guiSensitivity + 0.2) or (0.6 * guiSensitivity - 2)
			return (engineSensitivity <= MinGamepadCameraSensitivity) and MinGamepadCameraSensitivity or engineSensitivity
		end
		local startGamepadLevel = translateEngineGamepadSensitivityToGui(GameSettings.GamepadCameraSensitivity)
		------------------ Basic Gamepad Sensitivity Slider ------------------
		-- basic quantized sensitivity with a weird number of settings.
		local SliderLabel = "Camera Sensitivity"
		this.GamepadSensitivityFrame, this.GamepadSensitivityLabel, this.GamepadSensitivitySlider =
			utility:AddNewRow(this, SliderLabel, "Slider", GamepadSteps, startGamepadLevel)
		this.GamepadSensitivityFrame.LayoutOrder = 4
		this.GamepadSensitivitySlider.ValueChanged:connect(
			function(newValue)
				setCameraSensitivity(translateGuiGamepadSensitivityToEngine(newValue))
			end
		)
	end

	local function createOverscanOption()
		local showOverscanScreen = function()
			local MenuModule = require(RobloxGui.Modules.Settings.SettingsHub)
			local overscan = require(RobloxGui.Modules.Shell.Components.Overscan.Overscan)
			local roact = require(RobloxGui.Modules.Common.Roact)
			local overscanComponent = nil

			local props = {}
			props.onUnmount = function()
				if overscanComponent then
					roact.teardown(overscanComponent)
					-- show settings menu and give back movement
					ContextActionService:UnbindCoreAction("RbxStopOverscanMovement")
					MenuModule:SetVisibility(true, true)
				end
			end
			props.ImageVisible = false
			props.BackgroundTransparency = 0.2

			-- hide settings menu
			MenuModule:SetVisibility(false, true)

			-- override all bindings for movement
			local noOpFunc = function()
			end
			ContextActionService:BindCoreAction(
				"RbxStopOverscanMovement",
				noOpFunc,
				false,
				Enum.UserInputType.Gamepad1,
				Enum.UserInputType.Gamepad2,
				Enum.UserInputType.Gamepad3,
				Enum.UserInputType.Gamepad4
			)

			local overscanElement = roact.createElement(overscan, props)
			overscanComponent = roact.reify(overscanElement, RobloxGui, tostring(overscan))
		end

		local adjustButton, adjustText, setButtonRowRef =
			utility:MakeStyledButton("AdjustButton", "Adjust", UDim2.new(0, 300, 1, -20), showOverscanScreen, this)
		adjustText.Font = Enum.Font.SourceSans
		adjustButton.Position = UDim2.new(1, -400, 0, 12)

		if RunService:IsStudio() then
			adjustButton.Selectable = false
			adjustButton.Active = false
			adjustButton.Enabled.Value = false
			adjustText.TextColor3 = Color3.fromRGB(100, 100, 100)
		end

		local row = utility:AddNewRowObject(this, "Safe Zone", adjustButton)
		setButtonRowRef(row)
	end

	local function createDeveloperConsoleOption()
		-- makes button in settings menu to open dev console
		local function makeDevConsoleOption()
			local function onOpenDevConsole()
				local devConsoleMaster = require(script.Parent.Parent.Parent.DevConsoleMaster)
				if devConsoleMaster then
					devConsoleMaster:SetVisibility(true)
					local MenuModule = require(script.Parent.Parent.SettingsHub)
					if MenuModule then
						MenuModule:SetVisibility(false)
					end
				end
			end

			local devConsoleButton, devConsoleText, setButtonRowRef =
				utility:MakeStyledButton("DevConsoleButton", "Open", UDim2.new(0, 300, 1, -20), onOpenDevConsole, this)
			devConsoleText.Font = Enum.Font.SourceSans
			devConsoleButton.Position = UDim2.new(1, -400, 0, 12)
			local row = utility:AddNewRowObject(this, "Developer Console", devConsoleButton)
			row.LayoutOrder = 15
			setButtonRowRef(row)
		end

	if FFlagGroupEditDevConsoleButton then
		if RunService:IsStudio() then
			makeDevConsoleOption()
		else
			spawn(function()
				--only show option if player has edit access
				local canManageSuccess, canManageResult = pcall(function()
				local url = string.format("/users/%d/canmanage/%d", game:GetService("Players").LocalPlayer.UserId, game.PlaceId)
					return HttpRbxApiService:GetAsync(url, Enum.ThrottlingPriority.Default, Enum.HttpRequestType.Default, true)
				end)
				if canManageSuccess and type(canManageResult) == "string" then
					-- API returns: {"Success":BOOLEAN,"CanManage":BOOLEAN}
					-- Convert from JSON to a table
					-- pcall in case of invalid JSON
					local success, result = pcall(function()
						return HttpService:JSONDecode(canManageResult)
					end)

					if success and result.CanManage == true then
						makeDevConsoleOption()
					end
				end
			end)
		end
		else
			-- Only show option if we are place/group owner
			if game.CreatorType == Enum.CreatorType.Group then
				spawn(
					function()
						-- spawn since GetRankInGroup is async
						local success, result =
							pcall(
							function()
								return LocalPlayer:GetRankInGroup(game.CreatorId) == 255
							end
						)
						if success then
							if result == true then
								makeDevConsoleOption()
							end
						else
							print("DeveloperConsole: GetRankInGroup failed because", result)
						end
					end
				)
			elseif LocalPlayer.UserId == game.CreatorId and game.CreatorType == Enum.CreatorType.User then
				makeDevConsoleOption()
			end
		end
	end

	local function leaveAndRejoinVoiceChatChannel()
		pcall(function()
			local groupId = VoiceChatService:GetGroupId()
			if groupId and groupId ~= "" then
				local muted = VoiceChatService:IsPublishPaused()
				VoiceChatService:Leave()
				if GetFFlagEnableVoiceChatOptionsJoinByGroupIdToken() then
					VoiceChatService:JoinByGroupIdToken(groupId, muted)
				else
					VoiceChatService:JoinByGroupId(groupId, muted)
				end
			end
		end)
	end

	local function isValidDeviceList(deviceNames, deviceGuids, index)
		return deviceNames and deviceGuids and index and #deviceNames > 0 and index > 0
			and index <= #deviceNames and #deviceNames == #deviceGuids
	end

	local function setVCSOutput(soundServiceOutputName)
		local VCSSuccess, VCSDeviceNames, VCSDeviceGuids, VCSIndex = pcall(function ()
			return VoiceChatService:GetSpeakerDevices()
		end)

		if VCSSuccess
			and isValidDeviceList(VCSDeviceNames, VCSDeviceGuids, VCSIndex) then

			-- Find the matching VCS Device
			local VCSDeviceIndex = 0
			for deviceIndex, deviceName in ipairs(VCSDeviceNames) do
				if deviceName == soundServiceOutputName then
					VCSDeviceIndex = deviceIndex
				end
			end

			if VCSDeviceIndex > 0 then
				print(
					"[OutputDeviceSelection] Setting VCS Speaker Device To ",
					VCSDeviceNames[VCSDeviceIndex],
					VCSDeviceGuids[VCSDeviceIndex]
				)
				VoiceChatService:SetSpeakerDevice(
					VCSDeviceNames[VCSDeviceIndex],
					VCSDeviceGuids[VCSDeviceIndex]
				)
			else
				warn("Could not find equivalent VoiceChatService Device")
			end
		else
			warn("Could not connect to Voice Chat Service to change Output Device")
		end
	end

	-- TODO: Remove this when voice chat is unified with sound service.
	local function syncSoundOutputs()
		local success, deviceNames, deviceGuids, selectedIndex = pcall(function()
			return SoundService:GetOutputDevices()
		end)
		if success and isValidDeviceList(deviceNames, deviceGuids, selectedIndex) then
			setVCSOutput(deviceNames[selectedIndex])
		else
			warn("Could not connect to Voice Chat Service to change Output Device")
		end
	end

	local function createDeviceOptions(deviceType)
		local selectedIndex = this[deviceType.."DeviceIndex"] or 0
		local options = this[deviceType.."DeviceNames"] or {}
		local guids = this[deviceType.."DeviceGuids"] or {}

		this[deviceType.."DeviceFrame"], _, this[deviceType.."DeviceSelector"] =
			utility:AddNewRow(this, deviceType.." Device", "Selector", options, selectedIndex)
		this[deviceType.."DeviceFrame"].LayoutOrder = (deviceType == VOICE_CHAT_DEVICE_TYPE.Input) and 6 or 7

		this[deviceType.."DeviceInfo"] = {
			Name = selectedIndex > 0 and options[selectedIndex] or nil,
			Guid = selectedIndex > 0 and guids[selectedIndex] or nil,
		}

		this[deviceType.."DeviceSelector"].IndexChanged:connect(
			function(newIndex)
				if this[deviceType.."DeviceInfo"].Name == this[deviceType.."DeviceNames"][newIndex] and
					this[deviceType.."DeviceInfo"].Guid == this[deviceType.."DeviceGuids"][newIndex] then
					return
				end

				this[deviceType.."DeviceInfo"] = {
					Name = this[deviceType.."DeviceNames"][newIndex],
					Guid = this[deviceType.."DeviceGuids"][newIndex],
				}

				local deviceName = this[deviceType.."DeviceInfo"].Name
				local deviceGuid = this[deviceType.."DeviceInfo"].Guid

				if deviceType == VOICE_CHAT_DEVICE_TYPE.Input then
					VoiceChatService:SetMicDevice(deviceName, deviceGuid)
					-- TODO: This will be removed when set device API refactoring is done
					print(
						"[OutputDeviceSelection] Setting VCS Mic Device To ",
						deviceName,
						deviceGuid
					)
					print("[OutputDeviceSelection] Rejoining Voice Chat")
					leaveAndRejoinVoiceChatChannel()
				else
					SoundService:SetOutputDevice(deviceName, deviceGuid)
					print(
						"[OutputDeviceSelection] Setting SS Speaker Device To ",
						deviceName,
						deviceGuid
					)
					if GetFFlagEnableVoiceChatOptionsDualServiceOutputs() then
						setVCSOutput(deviceName)
					end
				end
			end
		)
	end

	local function updateVoiceChatDevices(deviceType)
		if deviceType ~= VOICE_CHAT_DEVICE_TYPE.Input and deviceType ~= VOICE_CHAT_DEVICE_TYPE.Output then
			warn(deviceType, "is not supported in VoiceChat devices")
		end

		local success, deviceNames, deviceGuids, selectedIndex = pcall(function()
			if deviceType == VOICE_CHAT_DEVICE_TYPE.Input then
				return VoiceChatService:GetMicDevices()
			else
				return SoundService:GetOutputDevices()
			end
		end)

		local VCSSuccess, VCSDeviceNames, VCSDeviceGuids, VCSIndex = pcall(function ()
			if GetFFlagEnableVoiceChatOptionsDualServiceOutputs() then
				return VoiceChatService:GetSpeakerDevices()
			else
				-- We're returning these, but because the flag is off they will never be used outside of the below check
				return deviceNames, deviceGuids, selectedIndex
			end
		end)

		if success and VCSSuccess and isValidDeviceList(deviceNames, deviceGuids, selectedIndex)
			and isValidDeviceList(VCSDeviceNames, VCSDeviceGuids, VCSIndex) then
			this[deviceType.."DeviceNames"] = deviceNames
			this[deviceType.."VCSDeviceNames"] = VCSDeviceNames
			this[deviceType.."VCSDeviceGuids"] = VCSDeviceGuids
			this[deviceType.."DeviceGuids"] = deviceGuids
			this[deviceType.."DeviceIndex"] = selectedIndex
		else
			warn("Errors in get "..deviceType.." device info")
			this[deviceType.."DeviceNames"] = {}
			this[deviceType.."DeviceGuids"] = {}
			this[deviceType.."VCSDeviceNames"] = {}
			this[deviceType.."VCSDeviceGuids"] = {}
			this[deviceType.."DeviceIndex"] = 0
		end

		if not this[deviceType.."DeviceSelector"] then
			createDeviceOptions(deviceType)
		else
			this[deviceType.."DeviceSelector"]:UpdateOptions(deviceNames)
			this[deviceType.."DeviceSelector"]:SetSelectionIndex(selectedIndex)
		end
	end

	local deviceChangedConnection = nil

	local function updateVoiceChatOptions()
		updateVoiceChatDevices(VOICE_CHAT_DEVICE_TYPE.Input)
		updateVoiceChatDevices(VOICE_CHAT_DEVICE_TYPE.Output)
	end

	local function setupDeviceChangedListener()
		if SoundService.DeviceListChanged then
			deviceChangedConnection = SoundService.DeviceListChanged:Connect(function()
				if this.PageOpen then
					updateVoiceChatOptions()
				end
			end)
		end
	end

	local function teardownDeviceChangedListener()
		if SoundService.DeviceListChanged and deviceChangedConnection then
			deviceChangedConnection:Disconnect()
		end
	end

	-- Check if voice chat is enabled
	local function checkVoiceChatOptions()
		if VoiceChatServiceManager:VoiceChatAvailable() then
			this.VoiceChatOptionsEnabled = true
			if GetFFlagEnableVoiceChatOptionsDualServiceOutputs() then
				syncSoundOutputs()
			end
			if this.PageOpen then
				updateVoiceChatOptions()
			end
		end
	end

	this.VoiceChatOptionsEnabled = false
	if GetFFlagEnableVoiceChatOptions() and game:GetEngineFeature("VoiceChatSupported") then
		VoiceChatServiceManager:init()
		-- TODO: Encapsulate device selection logic inside voiceChatManager
		VoiceChatService = VoiceChatServiceManager:getService()
		spawn(function()
			checkVoiceChatOptions()
		end)
	end

	createCameraModeOptions(
		not isTenFootInterface and
			(UserInputService.TouchEnabled or UserInputService.MouseEnabled or UserInputService.KeyboardEnabled)
	)

	local checkGamepadOptions = function()
		if GameSettings.IsUsingGamepadCameraSensitivity then
			createGamepadOptions()
		else
			local camerasettingsConn = nil
			camerasettingsConn =
				GameSettings:GetPropertyChangedSignal("IsUsingGamepadCameraSensitivity"):connect(
				function()
					if GameSettings.IsUsingGamepadCameraSensitivity then
						if camerasettingsConn then
							camerasettingsConn:disconnect()
						end
						createGamepadOptions()
					end
				end
			)
		end
	end

	if UserInputService.MouseEnabled then
		createMouseOptions()
	else
		if UserInputService.GamepadEnabled then
			checkGamepadOptions()
		else
			local gamepadConnectedConn = nil
			gamepadConnectedConn =
				UserInputService.GamepadConnected:connect(
				function()
					if gamepadConnectedConn then
						gamepadConnectedConn:disconnect()
					end
					checkGamepadOptions()
				end
			)
		end
	end

	if GameSettings.IsUsingCameraYInverted then
		createCameraInvertedOptions()
	else
		local gamesettingsConn = nil
		gamesettingsConn =
			GameSettings.Changed:connect(
			function(prop)
				if prop == "IsUsingCameraYInverted" then
					if GameSettings.IsUsingCameraYInverted then
						gamesettingsConn:disconnect()
						createCameraInvertedOptions()
					end
				end
			end
		)
	end

	createVolumeOptions()

	-- we disable quality slider on Xbox since it has FRM disabled and forced to max quality level so the slider is useless
	if platform ~= Enum.Platform.XBoxOne then
		createGraphicsOptions()
	end

	local canShowPerfStats =  not PolicyService:IsSubjectToChinaPolicies()

	if canShowPerfStats then
		createPerformanceStatsOptions()
	end

	-- create micro profiler option in the end, so the ip and port can be shown next to the row
	if UseMicroProfiler then
		createMicroProfilerOptions()
	end

	if isTenFootInterface then
		createOverscanOption()
	end

	local canShowDevConsole = IsDeveloperConsoleEnabled()

	if canShowDevConsole then
		-- dev console option only shows for place/group place owners
		createDeveloperConsoleOption()
	end

	allSettingsCreated = true
	if VRService.VREnabled then
		onVRSettingsReady()
	end

	------ TAB CUSTOMIZATION -------
	this.TabHeader.Name = "GameSettingsTab"
	this.TabHeader.Icon.Image =
		isTenFootInterface and "rbxasset://textures/ui/Settings/MenuBarIcons/GameSettingsTab@2x.png" or
		"rbxasset://textures/ui/Settings/MenuBarIcons/GameSettingsTab.png"

	if FFlagUseNotificationsLocalization then
		this.TabHeader.Title.Text = "Settings"
	else
		this.TabHeader.Icon.Title.Text = "Settings"
	end

	------ PAGE CUSTOMIZATION -------
	this.Page.ZIndex = 5

	if this.PageListLayout then
		this.PageListLayout.Padding = UDim.new(0, 0)
	end

	this.PageOpen = false

	this.OpenSettingsPage = function()
		if GetFFlagEnableVoiceChatOptions() then
			this.PageOpen = true
			if this.VoiceChatOptionsEnabled then
				-- Update device info each time user opens the menu
				-- TODO: This should be simplified by new API
				updateVoiceChatOptions()
				if GetDeviceChangedHookEnabled() then
					setupDeviceChangedListener()
				end
			end
		end
	end

	this.CloseSettingsPage = function()
		if GetFFlagEnableVoiceChatOptions() then
			this.PageOpen = false
			if GetDeviceChangedHookEnabled() then
				teardownDeviceChangedListener()
			end
		end
	end

	return this
end

----------- Page Instantiation --------------

PageInstance = Initialize()

return PageInstance
