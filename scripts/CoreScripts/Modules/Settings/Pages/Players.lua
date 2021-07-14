--[[
		Filename: Players.lua
		Written by: Stickmasterluke
		Version 1.0
		Description: Player list inside escape menu, with friend adding functionality.
--]]
-------------- SERVICES --------------
local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local GuiService = game:GetService("GuiService")
local PlayersService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local AnalyticsService = game:GetService("RbxAnalyticsService")
local RunService = game:GetService("RunService")

local VoiceChatServiceManager = require(script.Parent.Parent.Models.VoiceChatServiceManager)

----------- UTILITIES --------------
local CoreGuiModules = RobloxGui:WaitForChild("Modules")
CoreGuiModules:WaitForChild("TenFootInterface")
local ShareGameDirectory = CoreGui.RobloxGui.Modules.Settings.Pages.ShareGame

local utility = require(RobloxGui.Modules.Settings.Utility)

local reportAbuseMenu = require(RobloxGui.Modules.Settings.Pages.ReportAbuseMenu)
local SocialUtil = require(RobloxGui.Modules:WaitForChild("SocialUtil"))
local Diag = require(CorePackages.AppTempCommon.AnalyticsReporters.Diag)
local EventStream = require(CorePackages.AppTempCommon.Temp.EventStream)
local ShareGameIcons = require(ShareGameDirectory.Spritesheets.ShareGameIcons)
local isTenFootInterface = require(RobloxGui.Modules.TenFootInterface):IsEnabled()
local RobloxTranslator = require(RobloxGui.Modules.RobloxTranslator)
local InviteToGameAnalytics = require(ShareGameDirectory.Analytics.InviteToGameAnalytics)
local PolicyService = require(RobloxGui.Modules.Common.PolicyService)

------------ Constants -------------------
local FRAME_DEFAULT_TRANSPARENCY = .85
local FRAME_SELECTED_TRANSPARENCY = .65
local REPORT_PLAYER_IMAGE = isTenFootInterface and "rbxasset://textures/ui/Settings/Players/ReportFlagIcon@2x.png" or "rbxasset://textures/ui/Settings/Players/ReportFlagIcon.png"
local ADD_FRIEND_IMAGE = isTenFootInterface and "rbxasset://textures/ui/Settings/Players/AddFriendIcon@2x.png" or "rbxasset://textures/ui/Settings/Players/AddFriendIcon.png"
local FRIEND_IMAGE = isTenFootInterface and "rbxasset://textures/ui/Settings/Players/FriendIcon@2x.png" or "rbxasset://textures/ui/Settings/Players/FriendIcon.png"
local INSPECT_IMAGE = "rbxasset://textures/ui/InspectMenu/ico_inspect.png"
local INSPECT_KEY = "InGame.InspectMenu.Action.View"

local MuteStatusIcons = {
	MicOn = "rbxasset://textures/ui/Settings/Players/Unmute@2x.png",
	MicOff = "rbxasset://textures/ui/Settings/Players/Muted@2x.png",
	MicDisabled = "rbxasset://textures/ui/Settings/Players/Blocked@2x.png",
	Loading = "rbxasset://textures/ui/Settings/Players/Unmuted-White@2x.png",
}

local PLAYER_ROW_HEIGHT = 62
local PLAYER_ROW_SPACING = 80
local PLAYER_NAME_RIGHT_PADDING = 20
------------ Variables -------------------
local platform = UserInputService:GetPlatform()
local PageInstance = nil
local localPlayer = PlayersService.LocalPlayer
while not localPlayer do
	PlayersService.ChildAdded:wait()
	localPlayer = PlayersService.LocalPlayer
end

------------ FAST FLAGS -------------------
local success, result = pcall(function() return settings():GetFFlag('UseNotificationsLocalization') end)
local FFlagUseNotificationsLocalization = success and result
local FFlagUpdateSettingsHubGameText = require(RobloxGui.Modules.Flags.FFlagUpdateSettingsHubGameText)

local FFlagShowInGameReportingLuobu = require(RobloxGui.Modules.Flags.FFlagShowInGameReportingLuobu)
local getFFlagEnableVoiceChatPlayersList = require(RobloxGui.Modules.Flags.GetFFlagEnableVoiceChatPlayersList)
local FFlagInspectMenuSubjectToPolicy = require(RobloxGui.Modules.Flags.FFlagInspectMenuSubjectToPolicy)

local isEngineTruncationEnabledForIngameSettings = require(RobloxGui.Modules.Flags.isEngineTruncationEnabledForIngameSettings)

local GetFFlagUseThumbnailUrl = require(RobloxGui.Modules.Common.Flags.GetFFlagUseThumbnailUrl)

----------- CLASS DECLARATION --------------
local function Initialize()
	local settingsPageFactory = require(RobloxGui.Modules.Settings.SettingsPageFactory)
	local this = settingsPageFactory:CreateNewPage()

	this.PageListLayout.Padding = UDim.new(0, PLAYER_ROW_SPACING - PLAYER_ROW_HEIGHT)

	------ TAB CUSTOMIZATION -------
	this.TabHeader.Name = "PlayersTab"
	this.TabHeader.Icon.Image = isTenFootInterface and "rbxasset://textures/ui/Settings/MenuBarIcons/PlayersTabIcon@2x.png" or "rbxasset://textures/ui/Settings/MenuBarIcons/PlayersTabIcon.png"

	if FFlagUseNotificationsLocalization then
		this.TabHeader.Title.Text = "People"
	else
		this.TabHeader.Icon.Title.Text = "People"
	end

	----- FRIENDSHIP FUNCTIONS ------
	local function getFriendStatus(selectedPlayer)
		local success, result = pcall(function()
			-- NOTE: Core script only
			return localPlayer:GetFriendStatus(selectedPlayer)
		end)
		if success then
			return result
		else
			return Enum.FriendStatus.NotFriend
		end
	end

	------ PAGE CUSTOMIZATION -------
	this.Page.Name = "Players"

	local function showRightSideButtons(player)
		return player and player ~= localPlayer and player.UserId > 0 and localPlayer.UserId > 0
	end

	local function createFriendStatusTextLabel(status, player)
		if status == nil then
			return nil
		end

		local fakeSelection = Instance.new("Frame")
		fakeSelection.BackgroundTransparency = 1

		local friendLabel = nil
		local friendLabelText = nil
		if status == Enum.FriendStatus.Friend or status == Enum.FriendStatus.FriendRequestSent then
			friendLabel = Instance.new("TextButton")
			friendLabel.BackgroundTransparency = 1
			friendLabel.FontSize = Enum.FontSize.Size24
			friendLabel.Font = Enum.Font.SourceSans
			friendLabel.TextColor3 = Color3.new(1,1,1)
			friendLabel.SelectionImageObject = fakeSelection
			if status == Enum.FriendStatus.Friend then
				friendLabel.Text = "Friend"
			else
				friendLabel.Text = "Request Sent"
			end
		elseif status == Enum.FriendStatus.Unknown or status == Enum.FriendStatus.NotFriend or status == Enum.FriendStatus.FriendRequestReceived then
			local addFriendFunc = function()
				if friendLabel and friendLabelText and friendLabelText.Text ~= "" then
					friendLabel.ImageTransparency = 1
					friendLabelText.Text = ""
					if localPlayer and player then
                        AnalyticsService:ReportCounter("PlayersMenu-RequestFriendship")
                        AnalyticsService:TrackEvent("Game", "RequestFriendship", "PlayersMenu")

						localPlayer:RequestFriendship(player)
					end
				end
			end

			if platform ~= Enum.Platform.XBoxOne then
				friendLabel, friendLabelText = utility:MakeStyledButton("FriendStatus", "Add Friend", UDim2.new(0, 182, 0, 46), addFriendFunc)
				friendLabelText.ZIndex = 3
				friendLabelText.Position = friendLabelText.Position + UDim2.new(0,0,0,1)
			end
		end

		if friendLabel then
			friendLabel.Name = "FriendStatus"
			friendLabel.Size = UDim2.new(0,182,0,46)
			friendLabel.Position = UDim2.new(1,-198,0,7)
			friendLabel.ZIndex = 3
		end
		return friendLabel
	end

	local function createFriendStatusImageLabel(status, player)
		if status == Enum.FriendStatus.Friend or status == Enum.FriendStatus.FriendRequestSent then
			local friendLabel = Instance.new("ImageButton")
			friendLabel.Name = "FriendStatus"
			friendLabel.Size = UDim2.new(0, 46, 0, 46)
			friendLabel.Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png"
			friendLabel.ScaleType = Enum.ScaleType.Slice
			friendLabel.SliceCenter = Rect.new(8,6,46,44)
			friendLabel.AutoButtonColor = false
			friendLabel.BackgroundTransparency = 1
			friendLabel.ZIndex = 2
			local friendImage = Instance.new("ImageLabel")
			friendImage.BackgroundTransparency = 1
			friendImage.Position = UDim2.new(0.5, 0, 0.5, 0)
			friendImage.Size = UDim2.new(0, 28, 0, 28)
			friendImage.AnchorPoint = Vector2.new(0.5, 0.5)
			friendImage.ZIndex = 3
			friendImage.Image = FRIEND_IMAGE
			if status == Enum.FriendStatus.Friend then
				friendImage.ImageTransparency = 0
			else
				friendImage.Image = ADD_FRIEND_IMAGE
				friendImage.ImageTransparency = 0.5
			end
			friendImage.Parent = friendLabel
			return friendLabel
		elseif status == Enum.FriendStatus.Unknown or status == Enum.FriendStatus.NotFriend or status == Enum.FriendStatus.FriendRequestReceived then
			local addFriendButton, addFriendImage = nil
			local addFriendFunc = function()
				if addFriendButton and addFriendImage and addFriendButton.ImageTransparency ~= 1 then
					addFriendButton.ImageTransparency = 1
					addFriendImage.ImageTransparency = 1
					if localPlayer and player then
						AnalyticsService:ReportCounter("PlayersMenu-RequestFriendship")
						AnalyticsService:TrackEvent("Game", "RequestFriendship", "PlayersMenu")

						localPlayer:RequestFriendship(player)
					end
				end
			end
			addFriendButton, addFriendImage = utility:MakeStyledImageButton("FriendStatus", ADD_FRIEND_IMAGE,
					UDim2.new(0, 46, 0, 46), UDim2.new(0, 28, 0, 28), addFriendFunc)
			addFriendButton.Name = "FriendStatus"
			addFriendButton.Selectable = true
			return addFriendButton
		end
		return nil
	end

	local shareGameButton

	local function friendStatusCreate(playerLabel, player)
		local friendLabelParent = nil
		if playerLabel then
			friendLabelParent = playerLabel:FindFirstChild("RightSideButtons")
		end

		if friendLabelParent then
			-- remove any previous friend status labels
			for _, item in pairs(friendLabelParent:GetChildren()) do
				if item and item.Name == "FriendStatus" then
					if GuiService.SelectedCoreObject == item then
						GuiService.SelectedCoreObject = shareGameButton
					end
					item:Destroy()
				end
			end
		end
	end

	local function resizeFriendButton(parent, player, isPortrait, wasIsPortrait)
		local friendLabel = parent:FindFirstChild("FriendStatus")
		if friendLabel and isPortrait == wasIsPortrait then
			return
		end

		if friendLabel then
			friendLabel:Destroy()
			friendLabel = nil
		end

		local status
		if showRightSideButtons(player) then
			status = getFriendStatus(player)
		end

		if isPortrait then
			friendLabel = createFriendStatusImageLabel(status, player)
		else
			friendLabel = createFriendStatusTextLabel(status, player)
		end

		if friendLabel then
			friendLabel.Name = "FriendStatus"
			friendLabel.LayoutOrder = 3
			friendLabel.Selectable = true
			friendLabel.Parent = parent
		end
	end

	localPlayer.FriendStatusChanged:connect(function(player, friendStatus)
		if player then
			local playerLabel = this.Page:FindFirstChild("PlayerLabel"..player.Name)
			if playerLabel then
				friendStatusCreate(playerLabel, player)
			end
		end
	end)

	local function muteButtonUpdate(playerLabel, playerStatus)
		local buttonParent = nil
		if playerLabel then
			buttonParent = playerLabel:FindFirstChild("RightSideButtons")
		end

		if buttonParent then
			-- Get rid of the old button
			local oldButton = buttonParent:FindFirstChild("MuteStatusButton")
			if oldButton then
				oldButton:Destroy()
			end

			-- We don't exit until this point because we still need to destroy any old buttons
			if playerStatus == nil then
				return
			end

			local image = playerStatus.isMuted
				and MuteStatusIcons.MicOff
				or MuteStatusIcons.MicOn
			if playerStatus.isMutedLocally then
				image = MuteStatusIcons.MicDisabled
			elseif not playerStatus.subscriptionCompleted then
				image = MuteStatusIcons.Loading
			end

			local muteLabel, muteLabelText = utility:MakeStyledImageButton(
				"MuteStatus",
				image,
				UDim2.new(0, 46, 0, 46),
				UDim2.new(0, 20, 0, 26),
				function ()
					VoiceChatServiceManager:ToggleMutePlayer(
						playerStatus.userId
					)
				end
			)
			muteLabelText.ZIndex = 3
			muteLabelText.Position = muteLabelText.Position + UDim2.new(0,0,0,1)
			muteLabel.Parent = buttonParent
		end
	end

	local buttonsContainer = utility:Create("Frame") {
		Name = "ButtonsContainer",
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundTransparency = 1,
		Parent = this.Page,

		Visible = false
	}

	local leaveGameFunc = function()
		this.HubRef:SwitchToPage(this.HubRef.LeaveGamePage, false, 1)
	end

	local leaveGameText = "Leave"
	if FFlagUpdateSettingsHubGameText then
		leaveGameText = RobloxTranslator:FormatByKey("InGame.HelpMenu.Leave")
	end

	local leaveButton, leaveLabel = utility:MakeStyledButton("LeaveButton", leaveGameText, UDim2.new(1 / 3, -5, 1, 0), leaveGameFunc)
	leaveButton.AnchorPoint = Vector2.new(0, 0)
	leaveButton.Position = UDim2.new(0, 0, 0, 0)
	leaveLabel.Size = UDim2.new(1, 0, 1, -6)
	leaveButton.Parent = buttonsContainer

	local resetFunc = function()
		this.HubRef:SwitchToPage(this.HubRef.ResetCharacterPage, false, 1)
	end
	local resetButton, resetLabel = utility:MakeStyledButton("ResetButton", "Reset Character", UDim2.new(1 / 3, -5, 1, 0), resetFunc)
	resetButton.AnchorPoint = Vector2.new(0.5, 0)
	resetButton.Position = UDim2.new(0.5, 0, 0, 0)
	resetLabel.Size = UDim2.new(1, 0, 1, -6)
	resetButton.Parent = buttonsContainer

	local resumeGameFunc = function()
		this.HubRef:SetVisibility(false)
	end

	local resumeGameText = "Resume"
	if FFlagUpdateSettingsHubGameText then
		resumeGameText = RobloxTranslator:FormatByKey("InGame.HelpMenu.Resume")
	end

	local resumeButton, resumeLabel = utility:MakeStyledButton("ResumeButton", resumeGameText, UDim2.new(1 / 3, -5, 1, 0), resumeGameFunc)
	resumeButton.AnchorPoint = Vector2.new(1, 0)
	resumeButton.Position = UDim2.new(1, 0, 0, 0)
	resumeLabel.Size = UDim2.new(1, 0, 1, -6)
	resumeButton.Parent = buttonsContainer

	utility:OnResized(buttonsContainer, function(newSize, isPortrait)
		if isPortrait or utility:IsSmallTouchScreen() then
			local buttonsFontSize = isPortrait and 18 or 24
			buttonsContainer.Visible = true
			buttonsContainer.Size = UDim2.new(1, 0, 0, isPortrait and 50 or 62)
			resetLabel.TextSize = buttonsFontSize
			leaveLabel.TextSize = buttonsFontSize
			resumeLabel.TextSize = buttonsFontSize
		else
			buttonsContainer.Visible = false
			buttonsContainer.Size = UDim2.new(1, 0, 0, 0)
		end
	end)

	if FFlagUseNotificationsLocalization then
		local function ApplyLocalizeTextSettingsToLabel(label)
			label.AnchorPoint = Vector2.new(0.5,0.5)
			label.Position = UDim2.new(0.5, 0, 0.5, -3)
			label.Size = UDim2.new(0.75, 0, 0.5, 0)
		end
		ApplyLocalizeTextSettingsToLabel(leaveLabel)
		ApplyLocalizeTextSettingsToLabel(resetLabel)
		ApplyLocalizeTextSettingsToLabel(resetLabel)
	end

	local function reportAbuseButtonCreate(playerLabel, player)
		local rightSideButtons = playerLabel:FindFirstChild("RightSideButtons")
		if rightSideButtons then
			local oldReportButton = rightSideButtons:FindFirstChild("ReportPlayer")
			if oldReportButton then
				oldReportButton:Destroy()
			end

			if showRightSideButtons(player) then
				local reportPlayerFunction = function()
					reportAbuseMenu:ReportPlayer(player)
				end

				local reportButton = utility:MakeStyledImageButton("ReportPlayer", REPORT_PLAYER_IMAGE,
						UDim2.new(0, 46, 0, 46), UDim2.new(0, 28, 0, 28), reportPlayerFunction)
				reportButton.Name = "ReportPlayer"
				reportButton.Position = UDim2.new(1, -260, 0, 7)
				reportButton.LayoutOrder = 1
				reportButton.Selectable = true
				reportButton.Parent = rightSideButtons
			end
		end
	end

	local createShareGameButton = nil
	local createPlayerRow = nil

	local function createRow(frameClassName, hasSecondRow)
		local frame = Instance.new(frameClassName)
		frame.Image = "rbxasset://textures/ui/dialog_white.png"
		frame.ScaleType = "Slice"
		frame.SliceCenter = Rect.new(10, 10, 10, 10)
		frame.Size = UDim2.new(1, 0, 0, PLAYER_ROW_HEIGHT)
		frame.Position = UDim2.new(0, 0, 0, 0)
		frame.BackgroundTransparency = 1
		frame.ZIndex = 2
		frame.ImageTransparency = FRAME_DEFAULT_TRANSPARENCY

		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.new(0, 36, 0, 36)
		icon.Position = UDim2.new(0, 12, 0, 12)
		icon.ZIndex = 3
		icon.Parent = frame

		local textLabel = Instance.new("TextLabel")
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Font = Enum.Font.SourceSans
		textLabel.FontSize = hasSecondRow and Enum.FontSize.Size36 or Enum.FontSize.Size24
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.Position = hasSecondRow and UDim2.new(0, 60, 0.5, -10) or UDim2.new(0, 60, .5, 0)
		textLabel.Size = UDim2.new(0, 0, 0, 0)
		textLabel.ZIndex = 3
		textLabel.Parent = frame

		if hasSecondRow then
			local secondRow = Instance.new("TextLabel")
			secondRow.Name = "SecondRow"
			secondRow.TextXAlignment = Enum.TextXAlignment.Left
			secondRow.Font = Enum.Font.SourceSans
			secondRow.FontSize = Enum.FontSize.Size24
			secondRow.TextColor3 = Color3.fromRGB(162, 162, 162)
			secondRow.BackgroundTransparency = 1
			secondRow.Position = UDim2.new(0, 60, .5, 12)
			secondRow.Size = UDim2.new(0, 0, 0, 0)
			secondRow.ZIndex = 3
			secondRow.Parent = frame
		end

		return frame
	end

	createShareGameButton = function()
		local frame = createRow("ImageButton")
		local textLabel = frame.TextLabel
		local icon = frame.Icon

		textLabel.Font = Enum.Font.SourceSansSemibold
		textLabel.AutoLocalize = false
		textLabel.Text = RobloxTranslator:FormatByKey("Feature.SettingsHub.Action.InviteFriendsToPlay")

		icon.Size = UDim2.new(0, 24, 0, 24)
		icon.Position = UDim2.new(0, 18, 0, 18)
		ShareGameIcons:ApplyImage(icon, "invite")

		local function setIsHighlighted(isHighlighted)
			if isHighlighted then
				frame.ImageTransparency = FRAME_SELECTED_TRANSPARENCY
			else
				frame.ImageTransparency = FRAME_DEFAULT_TRANSPARENCY
			end
		end

		frame.InputBegan:Connect(function() setIsHighlighted(true) end)
		frame.InputEnded:Connect(function() setIsHighlighted(false) end)
		frame.Activated:Connect(function() setIsHighlighted(false) end)
		frame.TouchPan:Connect(function(_, totalTranslation)
			local TAP_ACCURACY_THREASHOLD = 20
			if math.abs(totalTranslation.Y) > TAP_ACCURACY_THREASHOLD then
				setIsHighlighted(false)
			end
		end)

		frame.SelectionGained:connect(function() setIsHighlighted(true) end)
		frame.SelectionLost:connect(function() setIsHighlighted(false) end)
		frame.SelectionImageObject = frame:Clone()

		return frame
	end

	local function createInspectButtonImage(activateInspectAndBuyMenu)
		local inspectButton = utility:MakeStyledImageButton("InspectButton", INSPECT_IMAGE,
				UDim2.new(0, 46, 0, 46), UDim2.new(0, 28, 0, 28), activateInspectAndBuyMenu)
		return inspectButton
	end

	local function createInspectButtonText(activateInspectAndBuyMenu)
		local inspectButton = utility:MakeStyledButton(
			"InspectButton", RobloxTranslator:FormatByKey(INSPECT_KEY), UDim2.new(0, 130, 0, 46), activateInspectAndBuyMenu)
		inspectButton.AutoLocalize = false
		return inspectButton
	end

	local function resizeInspectButton(parent, player, isPortrait, wasPortrait)
		local inspectButton = parent:FindFirstChild("Inspect")
		if inspectButton and isPortrait == wasPortrait then
			return
		end

		if inspectButton then
			inspectButton:Destroy()
		end

		local activateInspectAndBuyMenu = function()
			GuiService:InspectPlayerFromUserIdWithCtx(player.UserId, "escapeMenu")
			this.HubRef:SetVisibility(false)
		end

		if isPortrait then
			inspectButton = createInspectButtonImage(activateInspectAndBuyMenu)
		else
			inspectButton = createInspectButtonText(activateInspectAndBuyMenu)
		end

		inspectButton.Name = "Inspect"
		inspectButton.LayoutOrder = 2
		inspectButton.Selectable = true
		inspectButton.Parent = parent
	end

	createPlayerRow = function()
		local showDisplayName = true
		local frame = createRow("ImageLabel", showDisplayName)
		frame.TextLabel.Name = "DisplayNameLabel"
		frame.SecondRow.Name = "NameLabel"

		local rightSideButtons = Instance.new("Frame")
		rightSideButtons.Name = "RightSideButtons"
		rightSideButtons.BackgroundTransparency = 1
		rightSideButtons.ZIndex = 2
		rightSideButtons.Position = UDim2.new(0, 0, 0, 0)
		rightSideButtons.Size = UDim2.new(1, -10, 1, 0)
		rightSideButtons.Parent = frame

		-- Selection Highlighting logic:
		local updateHighlight = function(lostSelectionObject)
			if frame then
				if GuiService.SelectedCoreObject and GuiService.SelectedCoreObject ~= lostSelectionObject and GuiService.SelectedCoreObject.Parent == rightSideButtons then
					frame.ImageTransparency = FRAME_SELECTED_TRANSPARENCY
				else
					frame.ImageTransparency = FRAME_DEFAULT_TRANSPARENCY
				end
			end
		end

		local fakeSelectionObject = nil
		rightSideButtons.ChildAdded:connect(function(child)
			if child:IsA("GuiObject") then
				if fakeSelectionObject and child ~= fakeSelectionObject then
					fakeSelectionObject:Destroy()
					fakeSelectionObject = nil
				end
				child.SelectionGained:connect(function() updateHighlight(nil) end)
				child.SelectionLost:connect(function() updateHighlight(child) end)
			end
		end)

		fakeSelectionObject = Instance.new("Frame")
		fakeSelectionObject.Selectable = true
		fakeSelectionObject.Size = UDim2.new(1, 0, 1, 0)
		fakeSelectionObject.BackgroundTransparency = 1
		fakeSelectionObject.SelectionImageObject = fakeSelectionObject:Clone()
		fakeSelectionObject.Parent = rightSideButtons

		local rightSideListLayout = Instance.new("UIListLayout")
		rightSideListLayout.Name = "RightSideListLayout"
		rightSideListLayout.FillDirection = Enum.FillDirection.Horizontal
		rightSideListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		rightSideListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		rightSideListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rightSideListLayout.Padding = UDim.new(0, 20)
		rightSideListLayout.Parent = rightSideButtons

		pcall(function()
			frame.NameLabel.Localize = false
			if showDisplayName then
				frame.DisplayNameLabel.Localize = false
			end
		end)

		return frame
	end

	--Clean up with EngineTruncationEnabledForIngameSettingsV2
	-- Manage cutting off a players name if it is too long when switching into portrait mode.
	local function managePlayerNameCutoff(frame, player)
		local wasIsPortrait = nil
		local reportFlagAddedConnection = nil
		local function reportFlagChanged(reportFlag, prop)
			if prop == "AbsolutePosition" and wasIsPortrait then
				local maxPlayerNameSize = reportFlag.AbsolutePosition.X - 20 - frame.NameLabel.AbsolutePosition.X
				frame.NameLabel.Text = "@" .. player.Name
				frame.DisplayNameLabel.Text = player.DisplayName

				local newDisplayNameLength = utf8.len(player.DisplayName)
				while frame.NameLabel.TextBounds.X > maxPlayerNameSize and newDisplayNameLength > 0 do
					local offset = utf8.offset(player.DisplayName, newDisplayNameLength)
					frame.NameLabel.Text = string.sub(player.DisplayName, 1, offset) .. "..."
					newDisplayNameLength = newDisplayNameLength - 1
				end

				local playerNameText = "@" .. player.Name
				local newNameLength = string.len(playerNameText)
				while frame.NameLabel.TextBounds.X > maxPlayerNameSize and newNameLength > 0 do
					frame.NameLabel.Text = string.sub(playerNameText, 1, newNameLength) .. "..."
					newNameLength = newNameLength - 1
				end
			end
		end

		if not isEngineTruncationEnabledForIngameSettings() then
			utility:OnResized(frame.NameLabel, function(newSize, isPortrait)
				if wasIsPortrait ~= nil and wasIsPortrait == isPortrait then
					return
				end
				wasIsPortrait = isPortrait
				if isPortrait then
					if reportFlagAddedConnection == nil then
						reportFlagAddedConnection = frame.RightSideButtons.ChildAdded:connect(function(child)
							if child.Name == "ReportPlayer" then
								child.Changed:connect(function(prop) reportFlagChanged(child, prop) end)
								reportFlagChanged(child, "AbsolutePosition")
							end
						end)
					end
					local reportFlag = frame.RightSideButtons:FindFirstChild("ReportPlayer")
					if reportFlag then
						reportFlag.Changed:connect(function(prop) reportFlagChanged(reportFlag, prop) end)
						reportFlagChanged(reportFlag, "AbsolutePosition")
					end
				else
					frame.NameLabel.Text = "@" .. player.Name
					frame.DisplayNameLabel.Text = player.DisplayName
				end
			end)
		end

		local function getNearestRightSideButtonXPosition()
			local furthestLeftPos = nil

			for _, button in pairs(frame.RightSideButtons:GetChildren()) do
				if button:IsA("ImageButton") and (not furthestLeftPos or button.AbsolutePosition.X < furthestLeftPos) then
					furthestLeftPos = button.AbsolutePosition.X
				end
			end

			return furthestLeftPos
		end

		local lastRightSideButtonXPosition = nil
		local function rightSideButtonsChanged()
			local rightSideButtonXPosition = getNearestRightSideButtonXPosition()

			--We should only update if the absolute X position of the nearest "right-side-button" changes
			if rightSideButtonXPosition == lastRightSideButtonXPosition then
				return
			end

			lastRightSideButtonXPosition = rightSideButtonXPosition

			local nameLabelSize

			if rightSideButtonXPosition then
				nameLabelSize = UDim2.new(0, rightSideButtonXPosition - frame.NameLabel.AbsolutePosition.X - PLAYER_NAME_RIGHT_PADDING, 0, 0)
			else
				nameLabelSize = UDim2.new(1, - PLAYER_NAME_RIGHT_PADDING, 0, 0)
			end

			frame.NameLabel.Size = nameLabelSize
			frame.DisplayNameLabel.Size = nameLabelSize
			frame.NameLabel.Text = "@" .. player.Name
			frame.DisplayNameLabel.Text = player.DisplayName
		end

		if isEngineTruncationEnabledForIngameSettings() then
			reportFlagAddedConnection = frame.RightSideButtons.ChildAdded:connect(function(child)
				rightSideButtonsChanged()
				child:GetPropertyChangedSignal("AbsolutePosition"):Connect(rightSideButtonsChanged)
			end)

			rightSideButtonsChanged()
		end
	end

	local function canShareCurrentGame()
		return localPlayer.UserId > 0
	end

	local sortedPlayers
	local existingPlayerLabels = {}
	local livePlayers = {}

	local voiceChatServiceConnected = false
	if getFFlagEnableVoiceChatPlayersList()
		and game:GetEngineFeature("VoiceChatSupported")
		and not voiceChatServiceConnected
	then
		voiceChatServiceConnected = true
		VoiceChatServiceManager:init()
		VoiceChatServiceManager:SetupParticipantListeners()
		-- TODO: call GetParticipants so that we start off with a consistent list
	end

	local rebuildPlayerList = function(switchedFromGamepadInput)
		sortedPlayers = PlayersService:GetPlayers()
		table.sort(sortedPlayers, function(item1,item2)
			return item1.Name:lower() < item2.Name:lower()
		end)

		local extraOffset = 20
		if utility:IsSmallTouchScreen() or utility:IsPortrait() then
			extraOffset = 85
		end

		-- Create "invite friends" button if it doesn't exist yet
		-- We shouldn't create this button if we're not in a live game
		local isStudio = (not RunService:IsStudio())
		if canShareCurrentGame() and not shareGameButton and isStudio then
			local inviteToGameAnalytics = InviteToGameAnalytics.new()
				:withEventStream(EventStream.new())
				:withDiag(Diag.new(AnalyticsService))
				:withButtonName(InviteToGameAnalytics.ButtonName.SettingsHub)

			shareGameButton = createShareGameButton()
			shareGameButton.Activated:connect(function()
				inviteToGameAnalytics:inputShareGameEntryPoint()

				this.HubRef:InviteToGame()
			end)

			-- Ensure the button is always at the top of the list
			shareGameButton.LayoutOrder = 1
			shareGameButton.Parent = this.Page
		end

		local inspectMenuEnabled = GuiService:GetInspectMenuEnabled()
		if FFlagInspectMenuSubjectToPolicy then
			inspectMenuEnabled = inspectMenuEnabled and not PolicyService:IsSubjectToChinaPolicies()
		end

		-- iterate through players to reuse or create labels for players
		for index=1, #sortedPlayers do
			local player = sortedPlayers[index]
			local frame
			frame = existingPlayerLabels[player.Name]

			if player then
				livePlayers[player.Name] = true
				-- create label (frame) for this player index if one does not exist
				if not frame or not frame.Parent then
					frame = createPlayerRow((index - 1)*PLAYER_ROW_SPACING + extraOffset)
					frame.Parent = this.Page
					existingPlayerLabels[player.Name] = frame
				end
				frame.Name = "PlayerLabel" ..player.Name

				if voiceChatServiceConnected then
					local status = VoiceChatServiceManager.participants[tostring(player.UserId)]
					muteButtonUpdate(frame, status)
				end

				if GetFFlagUseThumbnailUrl() then
					local imageUrl = SocialUtil.GetPlayerImage(
						math.max(1, player.UserId), Enum.ThumbnailSize.Size100x100, Enum.ThumbnailType.AvatarThumbnail)
					frame.Icon.Image = imageUrl
				else
					-- Immediately assign the image to an image that isn't guaranteed to be generated
					frame.Icon.Image = SocialUtil.GetFallbackPlayerImageUrl(math.max(1, player.UserId), Enum.ThumbnailSize.Size100x100, Enum.ThumbnailType.AvatarThumbnail)
					-- Spawn a function to get the generated image
					spawn(function()
						local imageUrl = SocialUtil.GetPlayerImage(math.max(1, player.UserId), Enum.ThumbnailSize.Size100x100, Enum.ThumbnailType.AvatarThumbnail)
						if frame and frame.Parent and frame.Parent == this.Page then
							frame.Icon.Image = imageUrl
						end
					end)
				end

				frame.DisplayNameLabel.Text = player.DisplayName
				frame.NameLabel.Text = "@" .. player.Name

				frame.ImageTransparency = FRAME_DEFAULT_TRANSPARENCY
				-- extra index room for shareGameButton
				frame.LayoutOrder = index + 1

				if isEngineTruncationEnabledForIngameSettings() then
					frame.NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
					frame.DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
				end

				managePlayerNameCutoff(frame, player)

				friendStatusCreate(frame, player)

				local wasIsPortrait = nil
				utility:OnResized(frame, function(newSize, isPortrait)
					local parent = frame:FindFirstChild("RightSideButtons")
					if parent then
						resizeFriendButton(parent, player, isPortrait, wasIsPortrait)
						if inspectMenuEnabled then
							resizeInspectButton(parent, player, isPortrait, wasIsPortrait)
						end
						wasIsPortrait = isPortrait
					end
				end)

				local showReportAbuse = not PolicyService:IsSubjectToChinaPolicies() or FFlagShowInGameReportingLuobu

				if showReportAbuse then
					reportAbuseButtonCreate(frame, player)
				end
			end
		end

		for playerName, frame in pairs(existingPlayerLabels) do
			if not livePlayers[playerName] then
				frame:Destroy()
				existingPlayerLabels[playerName] = nil
			end
		end

		if UserInputService.GamepadEnabled then
			GuiService.SelectedCoreObject = shareGameButton
		end

		utility:OnResized("MenuPlayerListExtraPageSize", function(newSize, isPortrait)
			local extraOffset = 20
			if utility:IsSmallTouchScreen() or utility:IsPortrait() then
				extraOffset = 85
			end

			local inviteToGameRow = 1
			local playerListRowsCount = #sortedPlayers + inviteToGameRow

			this.Page.Size = UDim2.new(1,0,0, extraOffset + PLAYER_ROW_SPACING * playerListRowsCount - 5)
		end)
	end

	this.Displayed.Event:connect(rebuildPlayerList)

	if voiceChatServiceConnected then
		-- Rerender when the participants state changes
		VoiceChatServiceManager.participantsUpdate.Event:Connect(function()
			rebuildPlayerList()
		end)
		VoiceChatServiceManager.participantJoined.Event:Connect(function()
			rebuildPlayerList()
		end)
	end

	PlayersService.PlayerRemoving:Connect(function (player)
		livePlayers[player.Name] = nil

		local playerLabel = existingPlayerLabels[player.Name]

		if not playerLabel then
			return
		end

		local buttons = playerLabel:FindFirstChild("RightSideButtons")
		if not buttons then
			return
		end

		local friendStatus = buttons:FindFirstChild("FriendStatus")
		if friendStatus then
			if GuiService.SelectedCoreObject == friendStatus then
				if UserInputService.GamepadEnabled then
					GuiService.SelectedCoreObject = shareGameButton
				else
					GuiService.SelectedCoreObject = nil
				end
			end
			friendStatus:Destroy()
		end

		local reportPlayer = buttons:FindFirstChild("ReportPlayer")
		if reportPlayer then
			if GuiService.SelectedCoreObject == reportPlayer then
				if UserInputService.GamepadEnabled then
					GuiService.SelectedCoreObject = shareGameButton
				else
					GuiService.SelectedCoreObject = nil
				end
			end
			reportPlayer:Destroy()
		end

		local inspectButton = buttons:FindFirstChild("Inspect")
		if inspectButton then
			if GuiService.SelectedCoreObject == inspectButton then
				GuiService.SelectedCoreObject = nil
			end
			inspectButton:Destroy()
		end
	end)

	local function removeInspectButtons()
		for _, frame in pairs(existingPlayerLabels) do
			local buttons = frame:FindFirstChild("RightSideButtons")

			if buttons then
				local inspectButton = buttons:FindFirstChild("Inspect")
				if inspectButton then
					if GuiService.SelectedCoreObject == inspectButton then
						GuiService.SelectedCoreObject = nil
					end
					inspectButton:Destroy()
				end
			end
		end
	end

	-- If the developer disables the Inspect Menu, remove the button from the escape menu.
	GuiService.InspectMenuEnabledChangedSignal:Connect(function(enabled)
		if not enabled then
			removeInspectButtons()
		end
	end)

	if FFlagInspectMenuSubjectToPolicy then
		spawn(function()
			-- Re-check whether InspectMenu is enabled after PolicyService is finished initializing
			PolicyService:InitAsync()
			local enabled = GuiService:GetInspectMenuEnabled() and not PolicyService:IsSubjectToChinaPolicies()
			if not enabled then
				removeInspectButtons()
			end
		end)
	end

	return this
end

----------- Public Facing API Additions --------------
PageInstance = Initialize()

return PageInstance
