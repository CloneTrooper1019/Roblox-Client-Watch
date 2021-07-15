--!nocheck

--[[
		Filename: NotificationScript2.lua
		Version 1.1
		Written by: jmargh
		Description: Handles notification gui for the following in game ROBLOX events
			Badge Awarded
			Player Points Awarded
			Friend Request Recieved/New Friend
			Graphics Quality Changed
			Teleports
			CreatePlaceInPlayerInventoryAsync
--]]

local BadgeService = game:GetService('BadgeService')
local GuiService = game:GetService('GuiService')
local Players = game:GetService('Players')
local PointsService = game:GetService('PointsService')
local MarketplaceService = game:GetService('MarketplaceService')
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local AnalyticsService = game:GetService("RbxAnalyticsService")
local VRService = game:GetService("VRService")
local GroupService = game:GetService("GroupService")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local Settings = UserSettings()
local GameSettings = Settings.GameSettings

local success, result = pcall(function() return settings():GetFFlag('UseNotificationsLocalization') end)
local FFlagUseNotificationsLocalization = success and result

local FFlagNewAwardBadgeEndpoint = settings():GetFFlag('NewAwardBadgeEndpoint2')
local FFlagFixNotificationScriptError = game:DefineFastFlag("FixNotificationScriptError", false)

local GetFixGraphicsQuality = require(RobloxGui.Modules.Flags.GetFixGraphicsQuality)
local isNewGamepadMenuEnabled = require(RobloxGui.Modules.Flags.isNewGamepadMenuEnabled)

local shouldSaveScreenshotToAlbum = require(RobloxGui.Modules.shouldSaveScreenshotToAlbum)

local RobloxTranslator = require(RobloxGui:WaitForChild("Modules"):WaitForChild("RobloxTranslator"))

local function LocalizedGetString(key, rtv)
	pcall(function()
		rtv = RobloxTranslator:FormatByKey(key)
	end)
	return rtv
end

local LocalPlayer
while not Players.LocalPlayer do
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end
LocalPlayer = Players.LocalPlayer
local RbxGui = script.Parent
local NotificationQueue = {}
local OverflowQueue = {}
local FriendRequestBlacklist = {}
local BadgeBlacklist = {}
local CurrentGraphicsQualityLevel = GameSettings.SavedQualityLevel.Value
local BindableEvent_SendNotificationInfo = Instance.new('BindableEvent')
BindableEvent_SendNotificationInfo.Name = "SendNotificationInfo"
BindableEvent_SendNotificationInfo.Parent = RobloxGui
local isPaused = false
RobloxGui:WaitForChild("Modules"):WaitForChild("TenFootInterface")
local isTenFootInterface = require(RobloxGui.Modules.TenFootInterface):IsEnabled()

local pointsNotificationsActive = true
local badgesNotificationsActive = true

local SocialUtil = require(RobloxGui.Modules:WaitForChild("SocialUtil"))
local GameTranslator = require(RobloxGui.Modules.GameTranslator)
local PolicyService = require(RobloxGui.Modules.Common.PolicyService)

local BG_TRANSPARENCY = 0.7
local MAX_NOTIFICATIONS = 3

local NOTIFICATION_Y_OFFSET = isTenFootInterface and 145 or 64
local NOTIFICATION_TITLE_Y_OFFSET = isTenFootInterface and 40 or 12
local NOTIFICATION_TEXT_Y_OFFSET = isTenFootInterface and -16 or 1
local NOTIFICATION_FRAME_WIDTH = isTenFootInterface and 450 or 200
local NOTIFICATION_TEXT_HEIGHT = isTenFootInterface and 85 or 28
local NOTIFICATION_TEXT_HEIGHT_MAX = isTenFootInterface and 170 or 56
local NOTIFICATION_TITLE_FONT_SIZE = isTenFootInterface and Enum.FontSize.Size42 or Enum.FontSize.Size18
local NOTIFICATION_TEXT_FONT_SIZE = isTenFootInterface and Enum.FontSize.Size36 or Enum.FontSize.Size14

local IMAGE_SIZE = isTenFootInterface and 72 or 48

local EASE_DIR = Enum.EasingDirection.InOut
local EASE_STYLE = Enum.EasingStyle.Sine
local TWEEN_TIME = 0.35
local DEFAULT_NOTIFICATION_DURATION = 5
local MAX_GET_FRIEND_IMAGE_YIELD_TIME = 5
local FRIEND_REQUEST_NOTIFICATION_THROTTLE = 5

local friendRequestNotificationFIntSuccess, friendRequestNotificationFIntValue = pcall(function() return tonumber(settings():GetFVariable("FriendRequestNotificationThrottle")) end)
if friendRequestNotificationFIntSuccess and friendRequestNotificationFIntValue ~= nil then
	FRIEND_REQUEST_NOTIFICATION_THROTTLE = friendRequestNotificationFIntValue
end

StarterGui:RegisterSetCore(
	"PointsNotificationsActive",
	function(value) if type(value) == "boolean" then pointsNotificationsActive = value end end
)
StarterGui:RegisterSetCore(
	"BadgesNotificationsActive",
	function(value) if type(value) == "boolean" then badgesNotificationsActive = value end end
)

StarterGui:RegisterGetCore("PointsNotificationsActive", function() return pointsNotificationsActive end)
StarterGui:RegisterGetCore("BadgesNotificationsActive", function() return badgesNotificationsActive end)

local FFlagLocalizeVideoRecordAndScreenshotText = game:DefineFastFlag("LocalizeVideoRecordAndScreenshotText", false)

local PLAYER_POINTS_IMG = 'https://www.roblox.com/asset?id=206410433'
local BADGE_IMG = 'https://www.roblox.com/asset?id=206410289'

local function createFrame(name, size, position, bgt)
	local frame = Instance.new('Frame')
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundTransparency = bgt

	return frame
end

local function createTextButton(name, position)
	local button = Instance.new('TextButton')
	button.Name = name
	button.Size = UDim2.new(0.5, -2, 0.5, 0)
	button.Position = position
	button.BackgroundTransparency = BG_TRANSPARENCY
	button.BackgroundColor3 = Color3.new(0, 0, 0)
	button.Font = Enum.Font.SourceSansBold
	button.FontSize = Enum.FontSize.Size18
	button.TextColor3 = Color3.new(1, 1, 1)

	return button
end

local NotificationFrame = createFrame("NotificationFrame", UDim2.new(0, NOTIFICATION_FRAME_WIDTH, 0.42, 0), UDim2.new(1, -NOTIFICATION_FRAME_WIDTH-4, 0.50, 0), 1.0)
NotificationFrame.Parent = RbxGui

local DefaultNotification = createFrame("Notification", UDim2.new(1, 0, 0, NOTIFICATION_Y_OFFSET), UDim2.new(0, 0, 0, 0), BG_TRANSPARENCY)
DefaultNotification.BackgroundColor3 = Color3.new(0, 0, 0)
DefaultNotification.BorderSizePixel = 0

local NotificationTitle = Instance.new('TextLabel')
NotificationTitle.Name = "NotificationTitle"
NotificationTitle.Size = UDim2.new(0, 0, 0, 0)
NotificationTitle.Position = UDim2.new(0.5, 0, 0.5, -12)
NotificationTitle.BackgroundTransparency = 1
NotificationTitle.Font = Enum.Font.SourceSansBold
NotificationTitle.FontSize = NOTIFICATION_TITLE_FONT_SIZE
NotificationTitle.TextColor3 = Color3.new(0.97, 0.97, 0.97)

local NotificationText = Instance.new('TextLabel')
NotificationText.Name = "NotificationText"
NotificationText.Size = UDim2.new(1, -20, 0, 28)
NotificationText.Position = UDim2.new(0, 10, 0.5, 1)
NotificationText.BackgroundTransparency = 1
NotificationText.Font = Enum.Font.SourceSans
NotificationText.FontSize = NOTIFICATION_TEXT_FONT_SIZE
NotificationText.TextColor3 = Color3.new(0.92, 0.92, 0.92)
NotificationText.TextWrap = true
NotificationText.TextYAlignment = Enum.TextYAlignment.Top

local NotificationImage = Instance.new('ImageLabel')
NotificationImage.Name = "NotificationImage"
NotificationImage.Size = UDim2.new(0, IMAGE_SIZE, 0, IMAGE_SIZE)
NotificationImage.Position = UDim2.new(0, (1.0/6.0) * IMAGE_SIZE, 0, 0.5 * (NOTIFICATION_Y_OFFSET - IMAGE_SIZE))
NotificationImage.BackgroundTransparency = 1
NotificationImage.Image = ""

-- Would really like to get rid of this but some events still require this
local PopupFrame = createFrame("PopupFrame", UDim2.new(0, 360, 0, 160), UDim2.new(0.5, -180, 0.5, -50), 0)
PopupFrame.Style = Enum.FrameStyle.DropShadow
PopupFrame.ZIndex = 4
PopupFrame.Visible = false
PopupFrame.Parent = RbxGui

local PopupAcceptButton = Instance.new('TextButton')
PopupAcceptButton.Name = "PopupAcceptButton"
PopupAcceptButton.Size = UDim2.new(0, 100, 0, 50)
PopupAcceptButton.Position = UDim2.new(0.5, -102, 1, -58)
PopupAcceptButton.Style = Enum.ButtonStyle.RobloxRoundButton
PopupAcceptButton.Font = Enum.Font.SourceSansBold
PopupAcceptButton.FontSize = Enum.FontSize.Size24
PopupAcceptButton.TextColor3 = Color3.new(1, 1, 1)
PopupAcceptButton.Text = "Accept"
PopupAcceptButton.ZIndex = 5
PopupAcceptButton.Parent = PopupFrame

local PopupDeclineButton = PopupAcceptButton:Clone()
PopupDeclineButton.Name = "PopupDeclineButton"
PopupDeclineButton.Position = UDim2.new(0.5, 2, 1, -58)
PopupDeclineButton.Text = "Decline"
PopupDeclineButton.Parent = PopupFrame

local PopupOKButton = PopupAcceptButton:Clone()
PopupOKButton.Name = "PopupOKButton"
PopupOKButton.Position = UDim2.new(0.5, -50, 1, -58)
PopupOKButton.Text = "OK"
PopupOKButton.Visible = false
PopupOKButton.Parent = PopupFrame

local PopupText = Instance.new('TextLabel')
PopupText.Name = "PopupText"
PopupText.Size = UDim2.new(1, -16, 0.8, 0)
PopupText.Position = UDim2.new(0, 8, 0, 8)
PopupText.BackgroundTransparency = 1
PopupText.Font = Enum.Font.SourceSansBold
PopupText.FontSize = Enum.FontSize.Size36
PopupText.TextColor3 = Color3.new(0.97, 0.97, 0.97)
PopupText.TextWrap = true
PopupText.ZIndex = 5
PopupText.TextYAlignment = Enum.TextYAlignment.Top
PopupText.Text = "This is a popup"
PopupText.Parent = PopupFrame

local insertNotification
local removeNotification

local function getFriendImage(playerId)
    -- SocialUtil.GetPlayerImage can yield for up to  MAX_GET_FRIEND_IMAGE_YIELD_TIME seconds while waiting for thumbnail to be final.
    -- It will just return an invalid thumbnail if a valid one can not be generated in time.
    return SocialUtil.GetPlayerImage(playerId, Enum.ThumbnailSize.Size48x48, Enum.ThumbnailType.HeadShot, --[[timeOut = ]] MAX_GET_FRIEND_IMAGE_YIELD_TIME)
end

local function createNotification(title, text, image)
	local notificationFrame = DefaultNotification:Clone()
	notificationFrame.Position = UDim2.new(1, 4, 1, -NOTIFICATION_Y_OFFSET - 4)

	local notificationTitle = NotificationTitle:Clone()
	notificationTitle.Text = title
	notificationTitle.Parent = notificationFrame

	local notificationText = NotificationText:Clone()
	notificationText.Text = text
	notificationText.Parent = notificationFrame
	if (image == nil or image == "") then
		notificationFrame.Parent = NotificationFrame
		if not notificationText.TextFits then
			local textSize = TextService:GetTextSize(notificationText.Text, notificationText.TextSize, notificationText.Font, Vector2.new(notificationText.AbsoluteSize.X, 1000))
			local addHeight = math.min(textSize.Y - notificationText.Size.Y.Offset, NOTIFICATION_TEXT_HEIGHT_MAX - notificationText.Size.Y.Offset)
			notificationTitle.Position = notificationTitle.Position - UDim2.new(0, 0, 0, addHeight/2)
			notificationText.Position = notificationText.Position - UDim2.new(0, 0, 0, addHeight/2)
			notificationFrame.Size = notificationFrame.Size + UDim2.new(0, 0, 0, addHeight)
			notificationText.Size = notificationText.Size + UDim2.new(0, 0, 0, addHeight)
		end
		notificationFrame.Parent = nil
	end

	if image and image ~= "" then
		local notificationImage = NotificationImage:Clone()
		notificationImage.Image = image
		notificationImage.Parent = notificationFrame

		notificationTitle.Position = UDim2.new(0, (4.0/3.0) * IMAGE_SIZE, 0.5, -NOTIFICATION_TITLE_Y_OFFSET)
		notificationTitle.TextXAlignment = Enum.TextXAlignment.Left

		notificationFrame.Parent = NotificationFrame
		notificationText.Size = UDim2.new(1, -IMAGE_SIZE - 16, 0, NOTIFICATION_TEXT_HEIGHT)
		notificationText.Position = UDim2.new(0, (4.0/3.0) * IMAGE_SIZE, 0.5, NOTIFICATION_TEXT_Y_OFFSET)
		notificationText.TextXAlignment = Enum.TextXAlignment.Left
		if not notificationText.TextFits then
			local extraText = nil
			local text = notificationText.Text
			for i = string.len(text) - 1, 2, -1 do
				if string.sub(text, i, i) == " " then
					notificationText.Text = string.sub(text, 1, i - 1)
					if notificationText.TextFits then
						extraText = string.sub(text, i + 1)
						break
					end
				end
			end
			if extraText then
				local notificationText2 = NotificationText:Clone()
				notificationText2.TextXAlignment = Enum.TextXAlignment.Left
				notificationText2.Text = extraText
				notificationText2.Name = "ExtraText"
				notificationText2.Parent = notificationFrame

				local textSize = TextService:GetTextSize(extraText, notificationText2.TextSize, notificationText2.Font, Vector2.new(notificationText2.AbsoluteSize.X, 1000))
				local addHeight = math.min(textSize.Y, NOTIFICATION_TEXT_HEIGHT_MAX - notificationText.Size.Y.Offset)
				notificationTitle.Position = notificationTitle.Position - UDim2.new(0, 0, 0, addHeight/2)
				notificationText.Position = notificationText.Position - UDim2.new(0, 0, 0, addHeight/2)
				notificationFrame.Size = notificationFrame.Size + UDim2.new(0, 0, 0, addHeight)

				notificationText2.Size = UDim2.new(notificationText2.Size.X.Scale, notificationText2.Size.X.Offset, 0, addHeight)
				notificationText2.AnchorPoint = Vector2.new(0.5, 0)
				notificationText2.Position = UDim2.new(0.5, 0, notificationText.Position.Y.Scale, notificationText.Position.Y.Offset + notificationText.AbsoluteSize.Y)
			else
				notificationText.Text = text
			end
		end
		notificationFrame.Parent = nil
	end

	GuiService:AddSelectionParent(HttpService:GenerateGUID(false), notificationFrame)

	return notificationFrame
end


local function findNotification(notification)
	local index = nil
	for i = 1, #NotificationQueue do
		if NotificationQueue[i] == notification then
			return i
		end
	end
end

local function updateNotifications()
	local pos = 1
	local yOffset = 0
	for i = #NotificationQueue, 1, -1 do
		local currentNotification = NotificationQueue[i]
		if currentNotification then
			local frame = currentNotification.Frame
			if frame and frame.Parent then
				local thisOffset = currentNotification.IsFriend and (NOTIFICATION_Y_OFFSET + 2) * 1.5 or NOTIFICATION_Y_OFFSET
				thisOffset = currentNotification.IsFriend and frame.Size.Y.Offset + ((NOTIFICATION_Y_OFFSET + 2) * 0.5) or frame.Size.Y.Offset
				yOffset = yOffset + thisOffset
				frame:TweenPosition(UDim2.new(0, 0, 1, -yOffset - (pos * 4)), EASE_DIR, EASE_STYLE, TWEEN_TIME, true,
					function()
						if currentNotification.TweenOutCallback then
							currentNotification.TweenOutCallback()
						end
					end)
				pos = pos + 1
			end
		end
	end
end

local lastTimeInserted = 0
insertNotification = function(notification)
	spawn(function()
		while isPaused do wait() end
		notification.IsActive = true
		local size = #NotificationQueue
		if size == MAX_NOTIFICATIONS then
			NotificationQueue[1].Duration = 0
			OverflowQueue[#OverflowQueue + 1] = notification
			return
		end

		NotificationQueue[size + 1] = notification
		notification.Frame.Parent = NotificationFrame

		spawn(function()
			wait(TWEEN_TIME * 2)
			-- Wait for it to tween in, and then wait that same amount of time before calculating lifetime.
			-- This is to have it not zoom out while half tweened in when the OverflowQueue forcibly
			-- makes room for itself.

			while(notification.Duration > 0) do
				wait(0.2)
				notification.Duration = notification.Duration - 0.2
			end

			removeNotification(notification)
		end)

		while tick() - lastTimeInserted < TWEEN_TIME do
			wait()
		end
		lastTimeInserted = tick()

		updateNotifications()
	end)
end

removeNotification = function(notification)
	if not notification then return end
	--
	local index = findNotification(notification)
	table.remove(NotificationQueue, index)
	local frame = notification.Frame
	if frame and frame.Parent then
		notification.IsActive = false
		spawn(function()
			while isPaused do wait() end

			-- Tween out now, or set up to tween out immediately after current tween is finished, but don't interrupt.
			local function doTweenOut()
				if (not FFlagFixNotificationScriptError) or frame:IsDescendantOf(game) then
					return frame:TweenPosition(
						UDim2.new(1, 0, 1, frame.Position.Y.Offset), EASE_DIR, EASE_STYLE, TWEEN_TIME, false,
						function()
							frame:Destroy()
							notification = nil
						end
					)
				else
					return false
				end
			end

			if (not doTweenOut()) then
				notification.TweenOutCallback = doTweenOut
			end

		end)
	end
	if #OverflowQueue > 0 then
		local nextNotification = OverflowQueue[1]
		table.remove(OverflowQueue, 1)

		insertNotification(nextNotification)

		if (#OverflowQueue > 0 and NotificationQueue[1]) then
			NotificationQueue[1].Duration = 0
		end
	else
		updateNotifications()
	end
end

local function sendNotificationInfo(notificationInfo)
	notificationInfo.Duration = notificationInfo.Duration or DEFAULT_NOTIFICATION_DURATION
	BindableEvent_SendNotificationInfo:Fire(notificationInfo)
end

local function onSendNotificationInfo(notificationInfo)
	if VRService.VREnabled then
		--If VR is enabled, notifications will be handled by Modules.VR.NotificationHub
		return
	end
	local callback = notificationInfo.Callback

	local button1Text = notificationInfo.Button1Text
	local button2Text = notificationInfo.Button2Text

	local notification = {}
	local notificationFrame

	if notificationInfo.AutoLocalize then
		-- AutoLocalize should only be used for Developer notifcations.
		notificationFrame = createNotification(
			GameTranslator:TranslateGameText(CoreGui, notificationInfo.Title),
			GameTranslator:TranslateGameText(CoreGui, notificationInfo.Text),
			notificationInfo.Image)
	else
		notificationFrame = createNotification(notificationInfo.Title, notificationInfo.Text, notificationInfo.Image)
	end

	local button1
	if button1Text and button1Text ~= "" then
		notification.IsFriend = true -- Prevents other notifications overlapping the buttons
		button1 = createTextButton("Button1", UDim2.new(0, 0, 1, 2))
		if notificationInfo.AutoLocalize then
			GameTranslator:TranslateAndRegister(button1, CoreGui, button1Text)
		else
			button1.Text = button1Text
		end

		button1.Parent = notificationFrame
		local button1ClickedConnection = nil
		button1ClickedConnection = button1.MouseButton1Click:connect(function()
			if button1ClickedConnection then
				button1ClickedConnection:disconnect()
				button1ClickedConnection = nil
				removeNotification(notification)
				if callback and type(callback) ~= "function" then -- callback should be a bindable
					pcall(function() callback:Invoke(button1Text) end)
				elseif type(callback) == "function" then
					callback(button1Text)
				end
			end
		end)
	end

	local button2
	if button2Text and button2Text ~= "" then
		notification.IsFriend = true

		button2 = createTextButton("Button2", UDim2.new(0.5, 2, 1, 2))

		if notificationInfo.AutoLocalize then
			GameTranslator:TranslateAndRegister(button2, CoreGui, button2Text)
		else
			button2.Text = button2Text
		end

		button2.Parent = notificationFrame
		local button2ClickedConnection = nil
		button2ClickedConnection = button2.MouseButton1Click:connect(function()
			if button2ClickedConnection then
				button2ClickedConnection:disconnect()
				button2ClickedConnection = nil
				removeNotification(notification)
				if callback and type(callback) ~= "function" then -- callback should be a bindable
					pcall(function() callback:Invoke(button2Text) end)
				elseif type(callback) == "function" then
					callback(notificationInfo.Button2Text)
				end
			end
		end)
	else
		-- Resize button1 to take up all the space under the notification if button2 doesn't exist
		if button1 then
			button1.Size = UDim2.new(1, -2, .5, 0)
		end
	end

	notification.Frame = notificationFrame
	notification.Duration = notificationInfo.Duration
	insertNotification(notification)
end
BindableEvent_SendNotificationInfo.Event:connect(onSendNotificationInfo)

local function createDeveloperNotification(notificationTable)
	if type(notificationTable) == "table" then
		if type(notificationTable.Title) == "string" and type(notificationTable.Text) == "string" then
			local iconImage = (type(notificationTable.Icon) == "string" and notificationTable.Icon or "")
			local duration = (type(notificationTable.Duration) == "number" and notificationTable.Duration or DEFAULT_NOTIFICATION_DURATION)
			local bindable = (typeof(notificationTable.Callback) == "Instance" and notificationTable.Callback:IsA("BindableFunction") and notificationTable.Callback or nil)
			local button1Text = (type(notificationTable.Button1) == "string" and notificationTable.Button1 or "")
			local button2Text = (type(notificationTable.Button2) == "string" and notificationTable.Button2 or "")

			-- AutoLocalize allows developers to disable automatic localization if they have pre-localized it. Defaults true.
			local autoLocalize = notificationTable.AutoLocalize == nil or notificationTable.AutoLocalize == true
			local title = notificationTable.Title
			local text = notificationTable.Text

			sendNotificationInfo {
				GroupName = "Developer",
				Title = title,
				Text = text,
				Image = iconImage,
				Duration = duration,
				Callback = bindable,
				Button1Text = button1Text,
				Button2Text = button2Text,
				AutoLocalize = autoLocalize,
			}
		end
	end
end

StarterGui:RegisterSetCore("SendNotification", createDeveloperNotification)

local checkFriendRequestIsThrottled; do
	local friendRequestThrottlingMap = {}

	checkFriendRequestIsThrottled = function(fromPlayer)
		local throttleFinishedTime = friendRequestThrottlingMap[fromPlayer]

		if throttleFinishedTime then
			if tick() < throttleFinishedTime then
				return true
			end
		end

		friendRequestThrottlingMap[fromPlayer] = tick() + FRIEND_REQUEST_NOTIFICATION_THROTTLE
		return false
	end
end

local function sendFriendNotification(fromPlayer)
	if checkFriendRequestIsThrottled(fromPlayer) then
		return
	end

	local acceptText = "Accept"
	local declineText = "Decline"
	sendNotificationInfo {
		GroupName = "Friends",
		Title = fromPlayer.Name,
		Text = "Sent you a friend request!",
		DetailText = fromPlayer.Name,
		Image = getFriendImage(fromPlayer.UserId),
		Duration = 8,
		Callback = function(buttonChosen)
			if buttonChosen == acceptText then
                AnalyticsService:ReportCounter("NotificationScript-RequestFriendship")
                AnalyticsService:TrackEvent("Game", "RequestFriendship", "NotificationScript")

				LocalPlayer:RequestFriendship(fromPlayer)
			else
                AnalyticsService:ReportCounter("NotificationScript-RevokeFriendship")
                AnalyticsService:TrackEvent("Game", "RevokeFriendship", "NotificationScript")

				LocalPlayer:RevokeFriendship(fromPlayer)
				FriendRequestBlacklist[fromPlayer] = true
			end
		end,
		Button1Text = acceptText,
		Button2Text = declineText
	}
end

local function onFriendRequestEvent(fromPlayer, toPlayer, event)
	if fromPlayer ~= LocalPlayer and toPlayer ~= LocalPlayer then return end
	--
	if fromPlayer == LocalPlayer then
		if event == Enum.FriendRequestEvent.Accept then
			local detailText = RobloxTranslator:FormatByKey(
				"NotificationScript2.FriendRequestEvent.Accept",
				{RBX_NAME = toPlayer.Name})

			sendNotificationInfo {
				GroupName = "Friends",
				Title = "New Friend",
				Text = toPlayer.Name,
				DetailText = detailText,

				Image = getFriendImage(toPlayer.UserId),
				Duration = DEFAULT_NOTIFICATION_DURATION
			}

		end
	elseif toPlayer == LocalPlayer then
		if event == Enum.FriendRequestEvent.Issue then
			if FriendRequestBlacklist[fromPlayer] then return end
			sendFriendNotification(fromPlayer)
		elseif event == Enum.FriendRequestEvent.Accept then
			local detailText = RobloxTranslator:FormatByKey("NotificationScript2.FriendRequestEvent.Accept", {RBX_NAME = fromPlayer.Name})

			sendNotificationInfo {
				GroupName = "Friends",
				Title = "New Friend",
				Text = fromPlayer.Name,
				DetailText = detailText,

				Image = getFriendImage(fromPlayer.UserId),
				Duration = DEFAULT_NOTIFICATION_DURATION
			}
		end
	end
end

local function onPointsAwarded(userId, pointsAwarded, userBalanceInGame, userTotalBalance)
	if pointsNotificationsActive and userId == LocalPlayer.UserId then
		local title, text, detailText
		if pointsAwarded == 1 then
			title = "Point Awarded"
			text = RobloxTranslator:FormatByKey("NotificationScript2.onPointsAwarded.single", {RBX_NUMBER = tostring(pointsAwarded)})
		elseif pointsAwarded > 0 then
			title = "Points Awarded"
			text = RobloxTranslator:FormatByKey("NotificationScript2.onPointsAwarded.multiple", {RBX_NUMBER = tostring(pointsAwarded)})
		elseif pointsAwarded < 0 then
			title = "Points Lost"
			text = RobloxTranslator:FormatByKey("NotificationScript2.onPointsAwarded.negative", {RBX_NUMBER = tostring(pointsAwarded)})
		else
			--don't notify for 0 points, shouldn't even happen
			return
		end
		detailText = text

		sendNotificationInfo {
			GroupName = "PlayerPoints",
			Title = title,
			Text = text,
			DetailText = detailText,
			Image = PLAYER_POINTS_IMG,
			Duration = DEFAULT_NOTIFICATION_DURATION
		}
	end
end


--todo: rename to onBadgeAwarded when removing FFlagNewAwardBadgeEndpoint
local function onBadgeAwarded_NEW(userId, creatorId, badgeId)
	if not BadgeBlacklist[badgeId] and badgesNotificationsActive and userId == LocalPlayer.UserId then
		BadgeBlacklist[badgeId] = true
		local creatorName = ""
		if game.CreatorType == Enum.CreatorType.Group then
			local groupInfo = GroupService:GetGroupInfoAsync(creatorId)
			if groupInfo then
				creatorName = groupInfo.Name
			end
		elseif game.CreatorType == Enum.CreatorType.User then
			creatorName = Players:GetNameFromUserIdAsync(creatorId)
		end

		local badgeInfo = BadgeService:GetBadgeInfoAsync(badgeId)

		local badgeAwardText = RobloxTranslator:FormatByKey("NotificationScript2.onBadgeAwardedDetail",
															{RBX_NAME = LocalPlayer.Name, CREATOR_NAME = creatorName, BADGE_NAME = badgeInfo.DisplayName })
		local badgeTitle = LocalizedGetString("NotificationScript2.onBadgeAwardedTitle")

		sendNotificationInfo {
			GroupName = "BadgeAwards",
			Title = badgeTitle,
			Text = badgeAwardText,
			DetailText = badgeAwardText,
			Image = BADGE_IMG,
			Duration = DEFAULT_NOTIFICATION_DURATION
		}
	end
end

--todo: remove when removing FFlagNewAwardBadgeEndpoint
local function onBadgeAwarded(message, userId, badgeId)
	if not BadgeBlacklist[badgeId] and badgesNotificationsActive and userId == LocalPlayer.UserId then
		BadgeBlacklist[badgeId] = true
		--SPTODO: Badge notifications are generated on the web and are not (for now) localized.
		sendNotificationInfo {
			GroupName = "BadgeAwards",
			Title = "Badge Awarded",
			Text = message,
			DetailText = message,
			Image = BADGE_IMG,
			Duration = DEFAULT_NOTIFICATION_DURATION
		}
	end
end

-- DEPRECATED Remove with FixGraphicsQuality
function onGameSettingsChanged(property, amount)
	if property == "SavedQualityLevel" then
		local level = GameSettings.SavedQualityLevel.Value + amount
		if level > 10 then
			level = 10
		elseif level < 1 then
			level = 1
		end
		-- value of 0 is automatic, we do not want to send a notification in that case
		if level > 0 and level ~= CurrentGraphicsQualityLevel and GameSettings.SavedQualityLevel ~= Enum.SavedQualitySetting.Automatic then
			local action = (level > CurrentGraphicsQualityLevel) and "Increased" or "Decreased"
			local message = ("%s to (%d)"):format(action, level)

			if level > CurrentGraphicsQualityLevel then
				message = RobloxTranslator:FormatByKey("NotificationScrip2.onCurrentGraphicsQualityLevelChanged.Increased", {RBX_NUMBER = tostring(level)})
			else
				message = RobloxTranslator:FormatByKey("NotificationScrip2.onCurrentGraphicsQualityLevelChanged.Decreased", {RBX_NUMBER = tostring(level)})
			end

			sendNotificationInfo {
				GroupName = "Graphics",
				Title = "Graphics Quality",
				Text = message,
				DetailText = message,
				Image = "",
				Duration = 2
			}
			CurrentGraphicsQualityLevel = level
		end
	end
end

if not PolicyService:IsSubjectToChinaPolicies() then
	if FFlagNewAwardBadgeEndpoint then
		BadgeService.OnBadgeAwarded:connect(onBadgeAwarded_NEW)
		BadgeService.BadgeAwarded:connect(onBadgeAwarded) -- todo: remove this when removing flag (only here in case old servers for a bit send down the old event)
	else
		BadgeService.BadgeAwarded:connect(onBadgeAwarded)
	end
end

if not isTenFootInterface then
	Players.FriendRequestEvent:connect(onFriendRequestEvent)
	PointsService.PointsAwarded:connect(onPointsAwarded)
	--GameSettings.Changed:connect(onGameSettingsChanged)

	if not GetFixGraphicsQuality() then
		game.GraphicsQualityChangeRequest:connect(function(graphicsIncrease) --graphicsIncrease is a boolean
			onGameSettingsChanged("SavedQualityLevel", graphicsIncrease == true and 1 or -1)
		end)
	end
end

local allowScreenshots = not PolicyService:IsSubjectToChinaPolicies()

if allowScreenshots then
	-- Otherwise game.ScreenshotSavedToAlbum signal will be fired, handling in CaptureNotification.lua
	if not shouldSaveScreenshotToAlbum() then
		game.ScreenshotReady:Connect(function(path)
			local titleText = "Screenshot Taken"
			local descriptionText = "Check out your screenshots folder to see it."
			local buttonText = "Open Folder"

			if FFlagLocalizeVideoRecordAndScreenshotText then
				titleText = RobloxTranslator:FormatByKey("NotificationScript2.Screenshot.Title")
				descriptionText = RobloxTranslator:FormatByKey("NotificationScript2.Screenshot.Description")
				buttonText = RobloxTranslator:FormatByKey("NotificationScript2.Screenshot.ButtonText")
			end

			sendNotificationInfo {
				Title = titleText,
				Text = descriptionText,
				Duration = 3.0,
				Button1Text = buttonText,
				Callback = function(text)
					if text == buttonText then
						game:OpenScreenshotsFolder()
					end
				end
			}
		end)
	end

	settings():GetService("GameSettings").VideoRecordingChangeRequest:Connect(function(value)
		if not value then
			local titleText = "Video Recorded"
			local descriptionText = "Check out your videos folder to see it."
			local buttonText = "Open Folder"

			if FFlagLocalizeVideoRecordAndScreenshotText then
				titleText = RobloxTranslator:FormatByKey("NotificationScript2.Video.Title")
				descriptionText = RobloxTranslator:FormatByKey("NotificationScript2.Video.Description")
				buttonText = RobloxTranslator:FormatByKey("NotificationScript2.Video.ButtonText")
			end

			sendNotificationInfo {
				Title = titleText,
				Text = descriptionText,
				Duration = 3.0,
				Button1Text = buttonText,
				Callback = function(text)
					if text == buttonText then
						game:OpenVideosFolder()
					end
				end
			}
		end
	end)
end

GuiService.SendCoreUiNotification = function(title, text)
	local notification = createNotification(title, text, "")
	notification.BackgroundTransparency = .5
	notification.Size = UDim2.new(.5, 0, .1, 0)
	notification.Position = UDim2.new(.25, 0, -0.1, 0)
	notification.NotificationTitle.FontSize = Enum.FontSize.Size36
	notification.NotificationText.FontSize = Enum.FontSize.Size24
	notification.Parent = RbxGui
	notification:TweenPosition(UDim2.new(.25, 0, 0, 0), EASE_DIR, EASE_STYLE, TWEEN_TIME, true)
	wait(5)
	if notification then
		notification:Destroy()
	end
end

-- This is used for when a player calls CreatePlaceInPlayerInventoryAsync
local function onClientLuaDialogRequested(msg, accept, decline)
	PopupText.Text = msg
	--
	local acceptCn, declineCn = nil, nil
	local function disconnectCns()
		if acceptCn then acceptCn:disconnect() end
		if declineCn then declineCn:disconnect() end
		--
		GuiService:RemoveCenterDialog(PopupFrame)
		PopupFrame.Visible = false
	end

	acceptCn = PopupAcceptButton.MouseButton1Click:connect(function()
		disconnectCns()
		MarketplaceService:SignalServerLuaDialogClosed(true)
	end)
	declineCn = PopupDeclineButton.MouseButton1Click:connect(function()
		disconnectCns()
		MarketplaceService:SignalServerLuaDialogClosed(false)
	end)

	local centerDialogSuccess = pcall(
		function()
			GuiService:AddCenterDialog(PopupFrame, Enum.CenterDialogType.QuitDialog,
				function()
					PopupOKButton.Visible = false
					PopupAcceptButton.Visible = true
					PopupDeclineButton.Visible = true
					PopupAcceptButton.Text = accept
					PopupDeclineButton.Text = decline
					PopupFrame.Visible = true
				end,
				function()
					PopupFrame.Visible = false
				end)
		end)

	if not centerDialogSuccess then
		PopupFrame.Visible = true
		PopupAcceptButton.Text = accept
		PopupDeclineButton.Text = decline
	end

	return true
end
MarketplaceService.ClientLuaDialogRequested:connect(onClientLuaDialogRequested)

if not isTenFootInterface and not isNewGamepadMenuEnabled() then
	local gamepadMenu = RobloxGui:WaitForChild("CoreScripts/GamepadMenu")
	local gamepadNotifications = gamepadMenu:FindFirstChild("GamepadNotifications")
	while not gamepadNotifications do
		wait()
		gamepadNotifications = gamepadMenu:FindFirstChild("GamepadNotifications")
	end

	local leaveNotificationFunc = function(name, state, inputObject)
		if state ~= Enum.UserInputState.Begin then return end

		if GuiService.SelectedCoreObject:IsDescendantOf(NotificationFrame) then
			GuiService.SelectedCoreObject = nil
		end

		ContextActionService:UnbindCoreAction("LeaveNotificationSelection")
	end

	gamepadNotifications.Event:connect(function(isSelected)
		if not isSelected then return end

		isPaused = true
		local notifications = NotificationFrame:GetChildren()
		for i = 1, #notifications do
			local noteComponents = notifications[i]:GetChildren()
			for j = 1, #noteComponents do
				if noteComponents[j]:IsA("GuiButton") and noteComponents[j].Visible then
					GuiService.SelectedCoreObject = noteComponents[j]
					break
				end
			end
		end

		if GuiService.SelectedCoreObject then
			ContextActionService:BindCoreAction("LeaveNotificationSelection", leaveNotificationFunc, false, Enum.KeyCode.ButtonB)
		else
			isPaused = false
			local utility = require(RobloxGui.Modules.Settings.Utility)
			local okPressedFunc = function() end
			utility:ShowAlert("You have no notifications", "Ok", --[[settingsHub]] nil, okPressedFunc, true)
		end
	end)

	GuiService.Changed:connect(function(prop)
		if prop == "SelectedCoreObject" then
			if not GuiService.SelectedCoreObject or not GuiService.SelectedCoreObject:IsDescendantOf(NotificationFrame) then
				isPaused = false
			end
		end
	end)
end

local Platform = UserInputService:GetPlatform()
local Modules = RobloxGui:FindFirstChild('Modules')
local CSMModule = Modules:FindFirstChild('ControllerStateManager')
if Modules and not CSMModule then
	local ShellModules = Modules:FindFirstChild('Shell')
	if ShellModules then
		CSMModule = ShellModules:FindFirstChild('ControllerStateManager')
	end
end

if Platform == Enum.Platform.XBoxOne then
	-- Platform hook for controller connection events
	-- Displays overlay to user on controller connection lost
	local PlatformService = nil
	pcall(function() PlatformService = game:GetService('PlatformService') end)
	if PlatformService and CSMModule then
		local controllerStateManager = require(CSMModule)
		if controllerStateManager then
			controllerStateManager:Initialize()

			if not game:IsLoaded() then
				game.Loaded:wait()
			end

			-- retro check in case of controller disconnect while loading
			-- for now, gamepad1 is always mapped to the active user
			controllerStateManager:CheckUserConnected()
		end
	end
end
