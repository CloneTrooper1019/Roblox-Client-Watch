local CorePackages = game:GetService("CorePackages")
local GuiService = game:GetService("GuiService")
local HttpRbxApiService = game:GetService("HttpRbxApiService")
local AppTempCommon = CorePackages.AppTempCommon

local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local Players = game:GetService("Players")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local ShareGame = RobloxGui.Modules.Settings.Pages.ShareGame

local isSelectionGroupEnabled = require(ShareGame.isSelectionGroupEnabled)
local Constants = require(ShareGame.Constants)
local ConversationEntry = require(ShareGame.Components.ConversationEntry)
local FriendsErrorPage = require(ShareGame.Components.FriendsErrorPage)
local InviteUserIdToPlaceId = require(ShareGame.Thunks.InviteUserIdToPlaceId)
local LoadingFriendsPage = require(ShareGame.Components.LoadingFriendsPage)
local NoFriendsPage = require(ShareGame.Components.NoFriendsPage)
local PlayerSearchPredicate = require(CoreGui.RobloxGui.Modules.InGameMenu.Utility.PlayerSearchPredicate)

local User = require(AppTempCommon.LuaApp.Models.User)
local httpRequest = require(AppTempCommon.Temp.httpRequest)
local memoize = require(AppTempCommon.Common.memoize)

local RetrievalStatus = require(CorePackages.AppTempCommon.LuaApp.Enum.RetrievalStatus)

local FFlagLuaInviteModalEnabled = settings():GetFFlag("LuaInviteModalEnabledV384")

local getTranslator = require(ShareGame.getTranslator)
local RobloxTranslator = getTranslator()

local ENTRY_HEIGHT = 62
local ENTRY_PADDING = 18

local NO_RESULTS_FONT = Enum.Font.SourceSans
local NO_RESULTS_TEXTCOLOR = Constants.Color.GRAY3
local NO_RESULTS_TEXTSIZE = 19
local NO_RESULTS_TRANSPRENCY = 0.22

local PRESENCE_WEIGHTS = {
	[User.PresenceType.ONLINE] = 3,
	[User.PresenceType.IN_GAME] = 2,
	[User.PresenceType.IN_STUDIO] = 1,
	[User.PresenceType.OFFLINE] = 0,
}

local ConversationList = Roact.PureComponent:extend("ConversationList")
if FFlagLuaInviteModalEnabled then
	ConversationList.defaultProps = {
		entryHeight = ENTRY_HEIGHT,
		entryPadding = ENTRY_PADDING
	}
end

function ConversationList:init()
	if isSelectionGroupEnabled() then
		self.scrollingRef = Roact.createRef()
	end
end

function ConversationList:render()
	local analytics = self.props.analytics
	local children = self.props[Roact.Children] or {}

	local entryHeight
	local entryPadding
	if FFlagLuaInviteModalEnabled then
		entryHeight = self.props.entryHeight
		entryPadding = self.props.entryPadding
	else
		entryHeight = ENTRY_HEIGHT
		entryPadding = ENTRY_PADDING
	end

	local friends = self.props.friends
	local friendsRetrievalStatus = self.props.friendsRetrievalStatus
	local layoutOrder = self.props.layoutOrder
	local size = self.props.size
	local zIndex = self.props.zIndex
	local topPadding = self.props.topPadding

	local invites = self.props.invites
	local inviteUser = self.props.inviteUser
	local searchText = self.props.searchText

	children["RowListLayout"] = Roact.createElement("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, entryPadding),
	})

	local numEntries = 0
	-- Populate list of conversations with friends
	for i, user in ipairs(friends) do
		local isEntryShown = PlayerSearchPredicate(searchText, user.name, user.displayName)

		children["User-" .. tostring(i)] = Roact.createElement(ConversationEntry, {
			analytics = analytics,
			visible = isEntryShown,
			size = UDim2.new(1, 0, 0, entryHeight),
			layoutOrder = i,
			zIndex = zIndex,
			title = user.displayName,
			subtitle = "@" .. user.name,
			presence = user.presence,
			users = {user},
			inviteUser = inviteUser,
			inviteStatus = invites[user.id],
		})

		if isEntryShown then
			numEntries = numEntries + 1
		end
	end

	if #friends == 0 or friendsRetrievalStatus == RetrievalStatus.Fetching then
		local zeroFriendsComponent = LoadingFriendsPage

		if friendsRetrievalStatus == RetrievalStatus.Done then
			zeroFriendsComponent = NoFriendsPage
		elseif friendsRetrievalStatus == RetrievalStatus.Failed then
			zeroFriendsComponent = FriendsErrorPage
		end

		return Roact.createElement(zeroFriendsComponent, {
			BorderSizePixel = 0,
			LayoutOrder = layoutOrder,
			Position = UDim2.new(0, 0, 0, topPadding),
			ZIndex = zIndex,
		})
	else
		if numEntries == 0 then
			return Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				LayoutOrder = layoutOrder,
				Font = NO_RESULTS_FONT,
				Size = UDim2.new(1, 0, 0, entryHeight),
				Text = RobloxTranslator:FormatByKey("Feature.SettingsHub.Label.InviteSearchNoResults"),
				TextColor3 = NO_RESULTS_TEXTCOLOR,
				TextSize = NO_RESULTS_TEXTSIZE,
				TextTransparency = NO_RESULTS_TRANSPRENCY,
				ZIndex = zIndex,
			})
		end
	end

	local isSelectable = nil
	if isSelectionGroupEnabled() then
		isSelectable = false
	end

	return Roact.createElement("ScrollingFrame", {
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Size = size,
		CanvasSize = UDim2.new(0, 0, 0, numEntries * (entryHeight + entryPadding)),
		ScrollBarThickness = 0,
		ZIndex = zIndex,
		Selectable = isSelectable,
		[Roact.Ref] = isSelectionGroupEnabled() and self.scrollingRef or nil,
	}, children)
end

local function handleBinding(self)
	if isSelectionGroupEnabled() then
		local conversationList = self.scrollingRef:getValue()
		if conversationList then
			if conversationList:FindFirstAncestorOfClass("ScreenGui").Enabled then
				if GuiService.SelectedCoreObject == nil then
					GuiService:AddSelectionParent("invitePrompt", conversationList)
					for _, object in ipairs(conversationList:GetChildren()) do
						if object:IsA("GuiObject") and object.LayoutOrder == 1 then
							GuiService.SelectedCoreObject = object
							break
						end
					end
				end
			end
		end

	end
end

ConversationList.didUpdate = handleBinding
ConversationList.didMount = handleBinding

local selectFriends = memoize(function(users)
	local friends = {}
	local function friendPreference(friend1, friend2)
		local friend1Weight = PRESENCE_WEIGHTS[friend1.presence]
		local friend2Weight = PRESENCE_WEIGHTS[friend2.presence]

		if friend1Weight == friend2Weight then
			return friend1.name:lower() < friend2.name:lower()
		else
			return friend1Weight > friend2Weight
		end
	end

	for _, user in pairs(users) do
		if user.isFriend then
			friends[#friends + 1] = user
		end
	end

	table.sort(friends, friendPreference)

	return friends
end)

local connector = RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			friends = selectFriends(state.Users),
			friendsRetrievalStatus = state.Friends.retrievalStatus[tostring(Players.LocalPlayer.UserId)],
			invites = state.Invites,
		}
	end,
	function(dispatch)
		return {
			inviteUser = function(userId)
				local requestImpl = httpRequest(HttpRbxApiService)
				local placeId = tostring(game.PlaceId)

				return dispatch(InviteUserIdToPlaceId(requestImpl, userId, placeId))
			end,
		}
	end
)

return connector(ConversationList)
