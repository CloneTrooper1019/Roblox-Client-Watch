--[[
	// FileName: ContextMenuItems.lua
	// Written by: TheGamer101
	// Description: Module for creating the context menu items for the menu and doing the actions when they are clicked.
]]

--- SERVICES
local PlayersService = game:GetService("Players")
local CoreGuiService = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Chat = game:GetService("Chat")
local RunService = game:GetService("RunService")
local AnalyticsService = game:GetService("RbxAnalyticsService")
local GuiService = game:GetService("GuiService")
local CorePackages = game:GetService("CorePackages")

-- MODULES
local RobloxGui = CoreGuiService:WaitForChild("RobloxGui")
local CoreGuiModules = RobloxGui:WaitForChild("Modules")
local RobloxTranslator = require(RobloxGui.Modules.RobloxTranslator)
local GameTranslator = require(RobloxGui.Modules.GameTranslator)
local AvatarMenuModules = CoreGuiModules:WaitForChild("AvatarContextMenu")
local ContextMenuUtil = require(AvatarMenuModules:WaitForChild("ContextMenuUtil"))
local ThemeHandler = require(AvatarMenuModules.ThemeHandler)

local BlockingUtility = require(CoreGuiModules.BlockingUtility)
local PolicyService = require(RobloxGui.Modules.Common.PolicyService)
local t = require(CorePackages.Packages.t)
local ArgCheck = require(CorePackages.ArgCheck)

-- FLAGS
local FFlagInspectMenuSubjectToPolicy = require(CoreGuiModules.Flags.FFlagInspectMenuSubjectToPolicy)
local FFlagAvatarContextMenuItemsChatButtonRefactor = require(CoreGuiModules.Flags.FFlagAvatarContextMenuItemsChatButtonRefactor)

-- VARIABLES

local LocalPlayer = PlayersService.LocalPlayer
while not LocalPlayer do
	PlayersService.PlayerAdded:wait()
	LocalPlayer = PlayersService.LocalPlayer
end

local EnabledContextMenuItems = {
	[Enum.AvatarContextMenuOption.Chat] = true,
	[Enum.AvatarContextMenuOption.Friend] = true,
	[Enum.AvatarContextMenuOption.Emote] = true,
	[Enum.AvatarContextMenuOption.InspectMenu] = true
}
local CustomContextMenuItems = {}
local CustomItemAddedOrder = 0

-- CONSTANTS
-- If Custom buttons exist these layout orders are offset by highest custom button layout order.
local FRIEND_LAYOUT_ORDER = 1
local CHAT_LAYOUT_ORDER = 3
local INSPECT_AND_BUY_LAYOUT_ORDER = 4
local WAVE_LAYOUT_ORDER = 5

local MENU_ITEM_SIZE_X = 0.96
local MENU_ITEM_SIZE_Y = 0
local MENU_ITEM_SIZE_Y_OFFSET = 52
local VIEW_KEY = "InGame.InspectMenu.Action.View"

local ContextMenuItems = {}
ContextMenuItems.__index = ContextMenuItems

-- PRIVATE METHODS
function ContextMenuItems:UpdateInspectMenuEnabled()
	local enabled = GuiService:GetInspectMenuEnabled()
	if FFlagInspectMenuSubjectToPolicy then
		enabled = enabled and not PolicyService:IsSubjectToChinaPolicies()
	end

	if enabled ~= EnabledContextMenuItems[Enum.AvatarContextMenuOption.InspectMenu] then
		EnabledContextMenuItems[Enum.AvatarContextMenuOption.InspectMenu] = enabled
	end
end

function ContextMenuItems:ClearMenuItems()
	local children = self.MenuItemFrame:GetChildren()
	for i = 1, #children do
		if children[i]:IsA("GuiObject") then
			children[i]:Destroy()
		end
	end
end

function ContextMenuItems:AddCustomAvatarMenuItem(menuOption, bindableEvent)
	CustomItemAddedOrder = CustomItemAddedOrder + 1
	CustomContextMenuItems[menuOption] = {
		event = bindableEvent,
		layoutOrder = CustomItemAddedOrder,
	}
end

function ContextMenuItems:RemoveCustomAvatarMenuItem(menuOption)
	CustomContextMenuItems[menuOption] = nil
end

function ContextMenuItems:IsContextAvatarEnumItem(enumItem)
	local enumItems = Enum.AvatarContextMenuOption:GetEnumItems()
	for i = 1, #enumItems do
		if enumItem == enumItems[i] then
			return true
		end
	end
	return false
end

function ContextMenuItems:EnableDefaultMenuItem(menuOption)
	EnabledContextMenuItems[menuOption] = true
end

function ContextMenuItems:RemoveDefaultMenuItem(menuOption)
	EnabledContextMenuItems[menuOption] = false
end

function ContextMenuItems:RegisterCoreMethods()
	local function addMenuItemFunc(args) --[[ menuOption, bindableEvent]]
		if type(args) == "table" then
			local name = ""
			if args[1] and type(args[1]) == "string" then
				name = args[1]
			else
				error("AddAvatarContextMenuOption first argument must be a table or Enum.AvatarContextMenuOption")
			end

			if args[2] and typeof(args[2]) == "Instance" and args[2].ClassName == "BindableEvent" then
				self:AddCustomAvatarMenuItem(name, args[2])
			else
				error("AddAvatarContextMenuOption second table entry must be a BindableEvent")
			end

		elseif typeof(args) == "EnumItem" then
			if self:IsContextAvatarEnumItem(args) then
				self:EnableDefaultMenuItem(args)
			else
				error("AddAvatarContextMenuOption given EnumItem is not valid")
			end
		else
			error("AddAvatarContextMenuOption first argument must be a table or Enum.AvatarContextMenuOption")
		end
	end
	StarterGui:RegisterSetCore("AddAvatarContextMenuOption", addMenuItemFunc)
	local function removeMenuItemFunc(menuOption)
		if type(menuOption) == "string" then
			self:RemoveCustomAvatarMenuItem(menuOption)
		elseif typeof(menuOption) == "EnumItem" then
			if self:IsContextAvatarEnumItem(menuOption) then
				self:RemoveDefaultMenuItem(menuOption)
			else
				error("RemoveAvatarContextMenuOption given EnumItem is not valid")
			end
		else
			error("RemoveAvatarContextMenuOption first argument must be a string or Enum.AvatarContextMenuOption")
		end
	end
	StarterGui:RegisterSetCore("RemoveAvatarContextMenuOption", removeMenuItemFunc)
end

function ContextMenuItems:CreateCustomMenuItems()
	for buttonText, itemInfo in pairs(CustomContextMenuItems) do
		AnalyticsService:TrackEvent("Game", "AvatarContextMenuCustomButton", "name: " .. tostring(buttonText))
		local function customButtonFunc()
			if self.CloseMenuFunc then self:CloseMenuFunc() end

			itemInfo.event:Fire(self.SelectedPlayer)
		end
		buttonText = GameTranslator:TranslateGameText(self.MenuItemFrame, buttonText)
		local customButton = ContextMenuUtil:MakeStyledButton(
			"CustomButton",
			buttonText,
			UDim2.new(MENU_ITEM_SIZE_X, 0, MENU_ITEM_SIZE_Y, MENU_ITEM_SIZE_Y_OFFSET),
			customButtonFunc,
			ThemeHandler:GetTheme()
		)
		customButton.Name = "CustomButton"
		customButton.LayoutOrder = itemInfo.layoutOrder
		customButton.Parent = self.MenuItemFrame
	end
end

-- PUBLIC METHODS

local addFriendString = "Add Friend"
local friendsString = "Friends"
local friendRequestPendingString = "Friend Request Pending"
local acceptFriendRequestString = "Accept Friend Request"
local blockedString = "Player Blocked"

local addFriendDisabledTransparency = 0.75
local friendStatusChangedConn = nil
function ContextMenuItems:CreateFriendButton(status, isBlocked)
	addFriendString = RobloxTranslator:FormatByKey("Corescripts.AvatarContextMenu.AddFriend")
	friendsString = RobloxTranslator:FormatByKey("Corescripts.AvatarContextMenu.Friends")
	friendRequestPendingString = RobloxTranslator:FormatByKey("Corescripts.AvatarContextMenu.FriendRequestPending")
	acceptFriendRequestString = RobloxTranslator:FormatByKey("Corescripts.AvatarContextMenu.AcceptFriendRequest")
	blockedString = RobloxTranslator:FormatByKey("Corescripts.AvatarContextMenu.PlayerBlocked")

	local friendLabel = self.MenuItemFrame:FindFirstChild("FriendStatus")
	if friendLabel then
		friendLabel:Destroy()
		friendLabel = nil
	end
    if friendStatusChangedConn then
        friendStatusChangedConn:disconnect()
    end
	local friendLabelText = nil

	local addFriendFunc = function()
		if friendLabelText and friendLabel.Selectable then
            friendLabel.Selectable = false
            friendLabelText.TextTransparency = addFriendDisabledTransparency
            friendLabelText.Text = friendRequestPendingString
			AnalyticsService:ReportCounter("AvatarContextMenu-RequestFriendship")
			AnalyticsService:TrackEvent("Game", "RequestFriendship", "AvatarContextMenu")
			LocalPlayer:RequestFriendship(self.SelectedPlayer)
		end
	end

	friendLabel, friendLabelText = ContextMenuUtil:MakeStyledButton(
		"FriendStatus",
		addFriendString,
		UDim2.new(MENU_ITEM_SIZE_X, 0, MENU_ITEM_SIZE_Y, MENU_ITEM_SIZE_Y_OFFSET),
		addFriendFunc,
		ThemeHandler:GetTheme()
	)

	if isBlocked then
		friendLabel.Selectable = false
		friendLabelText.TextTransparency = addFriendDisabledTransparency
		friendLabelText.Text = blockedString
	elseif status == Enum.FriendStatus.Friend then
		friendLabel.Selectable = false
		friendLabelText.TextTransparency = addFriendDisabledTransparency
		friendLabelText.Text = friendsString
	elseif status == Enum.FriendStatus.FriendRequestSent then
		friendLabel.Selectable = false
		friendLabelText.TextTransparency = addFriendDisabledTransparency
		friendLabelText.Text = friendRequestPendingString
	elseif status == Enum.FriendStatus.FriendRequestReceived then
		friendLabelText.Text = acceptFriendRequestString
	else
		friendLabel.Selectable = true
		friendLabelText.TextTransparency = 0
	end

	friendLabel.LayoutOrder = FRIEND_LAYOUT_ORDER + CustomItemAddedOrder
	friendLabel.Parent = self.MenuItemFrame
end

function ContextMenuItems:UpdateFriendButton(status, isBlocked)
	local friendLabel = self.MenuItemFrame:FindFirstChild("FriendStatus")
	if friendLabel then
		self:CreateFriendButton(status, isBlocked)
	end
end

function ContextMenuItems:CreateInspectAndBuyButton()
	local function browseItems()
		if self.CloseMenuFunc then self:CloseMenuFunc() end

		-- If the developer disables the menu while someone is already looking at the ACM
		-- the button doesn't disappear, so we need to check again.
		if not EnabledContextMenuItems[Enum.AvatarContextMenuOption.InspectMenu] then
			warn("The Inspect Menu is not currently available.")
			return
		end

		GuiService:InspectPlayerFromUserIdWithCtx(self.SelectedPlayer.UserId, "avatarContextMenu")
	end
	local browseItemsButton = ContextMenuUtil:MakeStyledButton(
		"View",
		RobloxTranslator:FormatByKey(VIEW_KEY),
		UDim2.new(MENU_ITEM_SIZE_X, 0, MENU_ITEM_SIZE_Y, MENU_ITEM_SIZE_Y_OFFSET),
		browseItems,
		ThemeHandler:GetTheme()
	)
	browseItemsButton.LayoutOrder = INSPECT_AND_BUY_LAYOUT_ORDER + CustomItemAddedOrder
	browseItemsButton.Parent = self.MenuItemFrame
end

function ContextMenuItems:CreateEmoteButton()
	local function wave()
		if self.CloseMenuFunc then self:CloseMenuFunc() end

		AnalyticsService:ReportCounter("AvatarContextMenu-Wave")
        AnalyticsService:TrackEvent("Game", "AvatarContextMenuWave", "placeId: " .. tostring(game.PlaceId))

		PlayersService:Chat("/e wave")
	end

	local waveString = RobloxTranslator:FormatByKey("Corescripts.AvatarContextMenu.Wave")
	local waveButton = ContextMenuUtil:MakeStyledButton(
		"Wave",
		waveString,
		UDim2.new(MENU_ITEM_SIZE_X, 0, MENU_ITEM_SIZE_Y, MENU_ITEM_SIZE_Y_OFFSET),
		wave,
		ThemeHandler:GetTheme()
	)
	waveButton.LayoutOrder = WAVE_LAYOUT_ORDER + CustomItemAddedOrder
	waveButton.Parent = self.MenuItemFrame
end

local IChatButtonProps = t.interface({
	localPlayerChatEnabled = t.boolean,
	localPlayerCanChatWithSelectedPlayer = t.boolean,
})

function ContextMenuItems:CreateChatButton(props)
	local chatDisabled = false
	local function chatFunc()
		if chatDisabled then
			return
		end

		if self.CloseMenuFunc then self:CloseMenuFunc() end

		AnalyticsService:ReportCounter("AvatarContextMenu-Chat")
        AnalyticsService:TrackEvent("Game", "AvatarContextMenuChat", "placeId: " .. tostring(game.PlaceId))

		local ChatModule = require(RobloxGui.Modules.ChatSelector)
		ChatModule:SetVisible(true)
		local eventDidFire = ChatModule:EnterWhisperState(self.SelectedPlayer)
		if not eventDidFire then
			-- Fallback to the old version for backwards compatibility with old chat versions
			local ChatBar = nil
			pcall(function() ChatBar = LocalPlayer.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar end)
			if ChatBar then
				ChatBar.Text = "/w " .. self.SelectedPlayer.Name
			end
			ChatModule:FocusChatBar()
		end
	end

	local chatString = RobloxTranslator:FormatByKey("Corescripts.AvatarContextMenu.Chat")
	local chatButton, chatLabelText = ContextMenuUtil:MakeStyledButton(
		"ChatStatus",
		chatString,
		UDim2.new(MENU_ITEM_SIZE_X, 0, MENU_ITEM_SIZE_Y, MENU_ITEM_SIZE_Y_OFFSET),
		chatFunc,
		ThemeHandler:GetTheme()
	)
	chatButton.LayoutOrder = CHAT_LAYOUT_ORDER + CustomItemAddedOrder

	local canChat = false
	if FFlagAvatarContextMenuItemsChatButtonRefactor then
		ArgCheck.assert(IChatButtonProps(props))
		canChat = props.localPlayerChatEnabled
	else
		local success, canLocalUserChat = pcall(function() return Chat:CanUserChatAsync(LocalPlayer.UserId) end)
		canChat = success and (RunService:IsStudio() or canLocalUserChat)
	end

	if canChat then
		chatButton.Parent = self.MenuItemFrame

		local canChatWith = false
		if FFlagAvatarContextMenuItemsChatButtonRefactor then
			canChatWith = props.localPlayerCanChatWithSelectedPlayer
		else
			canChatWith = ContextMenuUtil:GetCanChatWith(self.SelectedPlayer)
		end

		if not canChatWith then
			chatDisabled = true
			chatButton.Selectable = false
			chatLabelText.TextTransparency = addFriendDisabledTransparency
			chatLabelText.Text = RobloxTranslator:FormatByKey("Corescripts.AvatarContextMenu.ChatDisabled")
		end
	else
		chatButton.Parent = nil
	end
end

function ContextMenuItems:RemoveLastButtonUnderline()
	local buttons = self.MenuItemFrame:GetChildren()
	local lastButton = nil
	local highestLayoutOrder = -1
	for _, button in pairs(buttons) do
		if button:IsA("GuiObject") and button.LayoutOrder > highestLayoutOrder then
			highestLayoutOrder = button.LayoutOrder
			lastButton = button
		end
	end
	if lastButton then
		local underline = lastButton:FindFirstChild("Underline")
		if underline then
			underline:Destroy()
		end
	end
end

function ContextMenuItems:BuildContextMenuItems(player, props)
	if not player then return end

	local friendStatus = ContextMenuUtil:GetFriendStatus(player)
	local isBlocked = BlockingUtility:IsPlayerBlockedByUserId(player.UserId)
	self:ClearMenuItems()
	self:SetSelectedPlayer(player)
	if EnabledContextMenuItems[Enum.AvatarContextMenuOption.Friend] then
		self:CreateFriendButton(friendStatus, isBlocked)
	end
	if EnabledContextMenuItems[Enum.AvatarContextMenuOption.Chat] then
		self:CreateChatButton(props)
	end
	if EnabledContextMenuItems[Enum.AvatarContextMenuOption.Emote] then
		self:CreateEmoteButton()
	end

	if EnabledContextMenuItems[Enum.AvatarContextMenuOption.InspectMenu] then
		self:CreateInspectAndBuyButton()
	end
	self:CreateCustomMenuItems()

	self:RemoveLastButtonUnderline()
end

function ContextMenuItems:SetSelectedPlayer(selectedPlayer)
	self.SelectedPlayer = selectedPlayer
end

function ContextMenuItems:SetCloseMenuFunc(closeMenuFunc)
	self.CloseMenuFunc = closeMenuFunc
end

function ContextMenuItems.new(menuItemFrame)
	local obj = setmetatable({}, ContextMenuItems)

	obj.MenuItemFrame = menuItemFrame
	obj.SelectedPlayer = nil

	obj:RegisterCoreMethods()

	-- If disabled in a script, sometimes it registers before we can receive the signal.
	ContextMenuItems:UpdateInspectMenuEnabled()

	return obj
end

GuiService.InspectMenuEnabledChangedSignal:Connect(function(enabled)
	if FFlagInspectMenuSubjectToPolicy then
		enabled = enabled and PolicyService:IsSubjectToChinaPolicies()
	end

	if not enabled then
		ContextMenuItems:RemoveDefaultMenuItem(Enum.AvatarContextMenuOption.InspectMenu)
	else
		ContextMenuItems:EnableDefaultMenuItem(Enum.AvatarContextMenuOption.InspectMenu)
	end
end)

if FFlagInspectMenuSubjectToPolicy then
	spawn(function()
		-- Check whether InspectMenu is disabled by policy after PolicyService is finished initializing
		PolicyService:InitAsync()
		ContextMenuItems:UpdateInspectMenuEnabled()
	end)
end

return ContextMenuItems
