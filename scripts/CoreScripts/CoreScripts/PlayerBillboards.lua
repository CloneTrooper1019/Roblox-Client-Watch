--[[
	Entry point for the player billboard management from CoreScripts.

	Currently, this includes the new version of BubbleChat and the voice chat
	speech indicator. This is written entirely in Roact. The chat list and
	legacy BubbleChat are still PlayerScripts, and are both still accessible
	under Modules/Server/ClientChat.
]]

local Chat = game:GetService("Chat")
local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RobloxGui = CoreGui:WaitForChild("RobloxGui", math.huge)

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local App = require(RobloxGui.Modules.InGameChat.BubbleChat.Components.App)
local chatReducer = require(RobloxGui.Modules.InGameChat.BubbleChat.Reducers.chatReducer)
local SetMessageText = require(RobloxGui.Modules.InGameChat.BubbleChat.Actions.SetMessageText)
local AddMessageFromEvent = require(RobloxGui.Modules.InGameChat.BubbleChat.Actions.AddMessageFromEvent)
local AddMessageWithTimeout = require(RobloxGui.Modules.InGameChat.BubbleChat.Actions.AddMessageWithTimeout)
local UpdateChatSettings = require(RobloxGui.Modules.InGameChat.BubbleChat.Actions.UpdateChatSettings)
local getPlayerFromPart = require(RobloxGui.Modules.InGameChat.BubbleChat.Helpers.getPlayerFromPart)
local validateMessage = require(RobloxGui.Modules.InGameChat.BubbleChat.Helpers.validateMessage)
local Constants = require(RobloxGui.Modules.InGameChat.BubbleChat.Constants)
local Types = require(RobloxGui.Modules.InGameChat.BubbleChat.Types)
local GameTranslator = require(RobloxGui.Modules.GameTranslator)

local MALFORMED_TEXT_WARNING = "Message text %q sent to chat event %q is not a valid UTF-8 characters sequence"
local WRONG_LENGTH_WARNING = "Message text %q is too long for chat event %q (expected a message of length %i, got %i)"

local MALFORMED_DATA_WARNING = "Malformed message data sent to chat event %q. If you have modified the chat system, " ..
	"check what you are firing to this event"

local chatStore = Rodux.Store.new(chatReducer, nil, {
	Rodux.thunkMiddleware,
})

local root = Roact.createElement(App, {
	store = chatStore
})

local function validateMessageWithWarning(eventName, message)
	local ok, length = validateMessage(message)

	if not ok then
		if length then
			warn(WRONG_LENGTH_WARNING:format(message, eventName, Constants.MAX_MESSAGE_LENGTH, length))
		else
			warn(MALFORMED_TEXT_WARNING:format(message, eventName))
		end
	end

	return ok
end

local function validateMessageData(eventName, messageData)
	local ok, message = Types.IMessageData(messageData)

	if not ok then
		warn(MALFORMED_DATA_WARNING:format(eventName))
		warn(message)
	end

	return ok
end

local handle, newMessageConn, messageDoneFilteringConn, chattedConn
local adorneeId = 0
local messageId = 0
local adorneeIdMap = {}
local function initBubbleChat()
	handle = Roact.mount(root, CoreGui, "BubbleChat")

	coroutine.resume(coroutine.create(function()
		-- Using math.huge as the timeout means this will yield indefinitely without
		-- logging a warning. We don't want to enforce that the
		-- DefaultChatSystemChatEvents folder exists, but we do need to wait for it
		-- incase it does. So this ensures the user can fork chat without getting a
		-- warning they can't resolve.
		local chatEvents = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", math.huge)

		newMessageConn = chatEvents:WaitForChild("OnNewMessage", math.huge).OnClientEvent:Connect(function(messageData)
			if not validateMessageData("OnNewMessage", messageData) then
				return
			end

			if messageData.FromSpeaker == Players.LocalPlayer.Name then
				if not validateMessageWithWarning("OnNewMessage", messageData.Message) then
					return
				end

				chatStore:dispatch(AddMessageFromEvent(messageData))
			end
		end)

		messageDoneFilteringConn = chatEvents:WaitForChild("OnMessageDoneFiltering", math.huge).OnClientEvent:Connect(function(messageData)
			if not validateMessageData("OnMessageDoneFiltering", messageData)
				or not validateMessageWithWarning("OnMessageDoneFiltering", messageData.Message) 
			then
				return
			end

			if messageData.FromSpeaker == Players.LocalPlayer.Name then
				local id = tostring(messageData.ID)
				chatStore:dispatch(SetMessageText(id, messageData.Message))
			else
				chatStore:dispatch(AddMessageFromEvent(messageData))
			end
		end)
	end))

	chattedConn = Chat.Chatted:Connect(function(partOrModel, message)
		local part
		if partOrModel:IsA("Model") then
			if partOrModel.PrimaryPart then
				part = partOrModel.PrimaryPart
			else
				part = partOrModel:FindFirstChildWhichIsA("BasePart", true)
			end
		else
			part = partOrModel
		end

		local player
		if part then
			player = getPlayerFromPart(part)
		end

		local userId
		if player then
			userId = tostring(player.UserId)
		else
			local id = adorneeIdMap[partOrModel]
			if id then
				userId = id
			else
				adorneeId = adorneeId + 1
				userId = "adornee_" .. adorneeId
				adorneeIdMap[partOrModel] = userId
			end
		end

		messageId = messageId + 1

		local message = {
			id = "chatted_" .. messageId,
			userId = userId,
			name = partOrModel.Name,
			text = GameTranslator:TranslateGameText(CoreGui, message),
			timestamp = os.time(),
			adornee = partOrModel
		}

		chatStore:dispatch(AddMessageWithTimeout(message))
	end)
end

local function destroyBubbleChat()
	if handle then
		Roact.unmount(handle)
		handle = nil
	end
	if newMessageConn then
		newMessageConn:Disconnect()
		newMessageConn = nil
	end
	if messageDoneFilteringConn then
		messageDoneFilteringConn:Disconnect()
		messageDoneFilteringConn = nil
	end
	if chattedConn then
		chattedConn:Disconnect()
		chattedConn = nil
	end
end

local function onBubbleChatEnabledChanged()
	destroyBubbleChat()
	if not game:GetEngineFeature("EnableBubbleChatFromChatService") or Chat.BubbleChatEnabled then
		initBubbleChat()
	end
end

if game:GetEngineFeature("EnableBubbleChatFromChatService") then
	Chat:GetPropertyChangedSignal("BubbleChatEnabled"):Connect(onBubbleChatEnabledChanged)
end
onBubbleChatEnabledChanged()

if game:GetEngineFeature("BubbleChatSettingsApi") then
	Chat.BubbleChatSettingsChanged:Connect(function(settings)
		local ok, message = Types.IChatSettings(settings)
		assert(ok, "Bad settings object passed to Chat:SetBubbleChatSettings:\n"..(message or ""))
		chatStore:dispatch(UpdateChatSettings(settings))
	end)
end
