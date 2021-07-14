local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.InGameMenuDependencies)
local Roact = InGameMenuDependencies.Roact
local RoactRodux = InGameMenuDependencies.RoactRodux
local t = InGameMenuDependencies.t
local Cryo = InGameMenuDependencies.Cryo

local InGameMenu = script.Parent.Parent.Parent

local getFFlagUseNewPlayerLabelDesign = require(InGameMenu.Flags.GetFFlagUseNewPlayerLabelDesign)
local fflagUseNewPlayerLabelDesign = getFFlagUseNewPlayerLabelDesign()
local PlayerLabel = fflagUseNewPlayerLabelDesign and require(InGameMenu.Components.PlayerLabelV2)
	or require(InGameMenu.Components.PlayerLabel)

local Divider = require(InGameMenu.Components.Divider)
local SendInviteButton = require(script.Parent.SendInviteButton)
local SearchBox = require(script.Parent.SearchBox)
local BarOnTopScrollingFrame = require(InGameMenu.Components.BarOnTopScrollingFrame)
local PlayerSearchPredicate = require(InGameMenu.Utility.PlayerSearchPredicate)

local Constants = require(InGameMenu.Resources.Constants)
local InviteStatus = Constants.InviteStatus

local InviteUserToPlaceId = require(InGameMenu.Thunks.InviteUserToPlaceId)

local DIVIDER_INDENT = fflagUseNewPlayerLabelDesign and 104 or 70
local PLAYER_LABEL_HEIGHT = fflagUseNewPlayerLabelDesign and 71 or 70

local SEARCHBOX_HEIGHT = 36
local SEARCHBOX_TOP_PADDING = 8
local SEARCHBOX_BOTTOM_PADDING = 20

local PLACE_ID = tostring(game.PlaceId)

local InviteFriendsList = Roact.PureComponent:extend("InviteFriendsList")

InviteFriendsList.validateProps = t.strictInterface({
	players = t.array(t.strictInterface({
		IsOnline = t.boolean,
		Id = t.integer,
		Username = t.string,
		DisplayName = t.string,
	})),
	invitesState = t.table,
	dispatchInviteUserToPlaceId = t.callback,
})

local function sortPlayers(p1, p2)
	if p1.IsOnline == p2.IsOnline then
		return p1.Username:lower() < p2.Username:lower()
	else
		return p1.IsOnline and not p2.IsOnline
	end
end

function InviteFriendsList:init()
	self.state = {
		searchText = "",
	}
	self.inviteAnimationInProgress = {}
end

function InviteFriendsList:renderListEntries()
	local sortedPlayers = Cryo.List.sort(self.props.players, sortPlayers)

	local playersCount = #sortedPlayers
	local layoutOrder = 1

	local listComponents = {}
	local visibleEntryCount = 0

	listComponents.ListLayout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
	})

	for index, playerInfo in pairs(sortedPlayers) do
		local userId = tostring(playerInfo.Id)
		local userInviteStatus = self.props.invitesState[userId]
		local isEntryVisible = PlayerSearchPredicate(self.state.searchText, playerInfo.Username, playerInfo.DisplayName)


		if isEntryVisible then
			visibleEntryCount = visibleEntryCount + 1
		end

		listComponents["friend_"..index] = Roact.createElement(PlayerLabel, {
			username = playerInfo.Username,
			displayName = fflagUseNewPlayerLabelDesign and playerInfo.DisplayName or nil,
			userId = playerInfo.Id,
			isOnline = playerInfo.IsOnline,
			isSelected = false,
			LayoutOrder = layoutOrder,
			Visible = isEntryVisible,

			onActivated = function()
				local isPending = userInviteStatus == InviteStatus.Pending
				local isSuccess = userInviteStatus == InviteStatus.Success
				local inviteAnimationInProgress = self.inviteAnimationInProgress[playerInfo.Id]
				if not (isPending or isSuccess or inviteAnimationInProgress) then
					self.props.dispatchInviteUserToPlaceId(userId, PLACE_ID)
				end
			end
		}, {
			InviteButton = Roact.createElement(SendInviteButton, {
				userInviteStatus = userInviteStatus,
				onActivated = function()
					self.props.dispatchInviteUserToPlaceId(userId, PLACE_ID)
				end,
				animationBegun = function()
					self.inviteAnimationInProgress[playerInfo.Id] = true
				end,
				animationEnded = function()
					self.inviteAnimationInProgress[playerInfo.Id] = nil
				end,
			})
		})

		layoutOrder = layoutOrder + 1

		if index < playersCount then
			listComponents["divider_" .. layoutOrder] = Roact.createElement(Divider, {
				LayoutOrder = layoutOrder,
				Size = UDim2.new(1, -DIVIDER_INDENT, 0, 1),
				Visible = isEntryVisible,
			})

			layoutOrder = layoutOrder + 1
		end
	end

	return listComponents, visibleEntryCount
end

function InviteFriendsList:render()
	local listEntries, visibleEntryCount = self:renderListEntries()

	local listOffset = SEARCHBOX_HEIGHT + SEARCHBOX_TOP_PADDING + SEARCHBOX_BOTTOM_PADDING

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	}, {
		SearchBox = Roact.createElement(SearchBox, {
			Size = UDim2.new(1, -48, 0, SEARCHBOX_HEIGHT),
			Position = UDim2.new(0.5, 0, 0, SEARCHBOX_TOP_PADDING),
			AnchorPoint = Vector2.new(0.5, 0),
			searchUpdated = function(newSearch)
				self:setState({
					searchText = newSearch,
				})
			end,
		}),

		List = Roact.createElement(BarOnTopScrollingFrame, {
			Position = UDim2.new(0, 0, 0, listOffset),
			Size = UDim2.new(1, 0, 1, -listOffset),
			CanvasSize = UDim2.new(1, 0, 0, visibleEntryCount * (PLAYER_LABEL_HEIGHT + 1)),
			scrollBarOffset = 4,
		}, listEntries)
	})
end

return RoactRodux.UNSTABLE_connect2(
	function(state, props)
		return {
			invitesState = state.invites
		}
	end,
	function(dispatch)
		return {
			dispatchInviteUserToPlaceId = function(userId, placeId)
				dispatch(InviteUserToPlaceId(userId, placeId))
			end
		}
	end
)(InviteFriendsList)