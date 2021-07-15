local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)
local t = require(CorePackages.Packages.t)
local Otter = require(CorePackages.Packages.Otter)
local UIBlox = require(CorePackages.UIBlox)

local Components = script.Parent.Parent
local Connection = Components.Connection
local LayoutValues = require(Connection.LayoutValues)
local WithLayoutValues = LayoutValues.WithLayoutValues

local DropDownButton = require(script.Parent.DropDownButton)
local DropDownPlayerHeader = require(script.Parent.DropDownPlayerHeader)
local FriendDropDownButton = require(script.Parent.FriendDropDownButton)

local LocalPlayer = Players.LocalPlayer

local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local RobloxTranslator = require(RobloxGui.Modules.RobloxTranslator)

local FFlagShowInGameBlockingLuobu = require(RobloxGui.Modules.Flags.FFlagShowInGameBlockingLuobu)
local FFlagShowInGameReportingLuobu = require(RobloxGui.Modules.Flags.FFlagShowInGameReportingLuobu)
local FFlagInspectMenuSubjectToPolicy = require(RobloxGui.Modules.Flags.FFlagInspectMenuSubjectToPolicy)

local Images = UIBlox.App.ImageSet.Images

local isNewInGameMenuEnabled = require(RobloxGui.Modules.isNewInGameMenuEnabled)

local PlayerList = Components.Parent

local ClosePlayerDropDown = require(PlayerList.Actions.ClosePlayerDropDown)

local BlockPlayer = require(PlayerList.Thunks.BlockPlayer)
local UnblockPlayer = require(PlayerList.Thunks.UnblockPlayer)
local RequestFriendship = require(PlayerList.Thunks.RequestFriendship)

local PlayerDropDown = Roact.PureComponent:extend("PlayerDropDown")

PlayerDropDown.validateProps = t.strictInterface({
	positionY = t.number,
	minPositionBoundY = t.number,
	maxPositionBoundY = t.number,
	contentsVisible = t.boolean,

	selectedPlayer = t.optional(t.instanceIsA("Player")),
	isVisible = t.boolean,
	playerRelationship = t.optional(t.strictInterface({
		isBlocked = t.boolean,
		friendStatus = t.enum(Enum.FriendStatus),
		isFollowing = t.boolean,
		isFollower = t.boolean,
	})),
	inspectMenuEnabled = t.boolean,
	isTenFootInterface = t.boolean,
	subjectToChinaPolicies = t.boolean,

	closeDropDown = t.callback,
	blockPlayer = t.callback,
	unblockPlayer = t.callback,
	requestFriendship = t.callback,
})

function PlayerDropDown:init()
	self.innerFrameRef = Roact.createRef()

	self.motorOptions = {
		dampingRatio = 1,
		frequency = 4,
	}

	--TODO: Change this to use bindings when roact 1.0 drops
	self.motor = Otter.createSingleMotor(1)
	self.motor:onStep(function(value)
		local innerFrame = self.innerFrameRef.current

		if innerFrame then
			if value == 1 then
				innerFrame.Visible = false
			else
				innerFrame.Visible = true
			end
			innerFrame.Position = UDim2.new(value, 0, 0, 0)
		end
	end)

	self.dropDownPosition = 0
end

function PlayerDropDown:createFriendButton(playerRelationship)
	local selectedPlayer = self.props.selectedPlayer
	return Roact.createElement(FriendDropDownButton, {
		layoutOrder = 1,
		playerRelationship = playerRelationship,
		selectedPlayer = selectedPlayer,
		dropDownOpen = self.props.isVisible,
		requestFriendship = self.props.requestFriendship,
		contentVisible = true,
	})
end

function PlayerDropDown:createBlockButton(playerRelationship)
	local selectedPlayer = self.props.selectedPlayer
	local blockedText = RobloxTranslator:FormatByKey("PlayerDropDown.Block")
	local unblockText = RobloxTranslator:FormatByKey("PlayerDropDown.UnBlock")
	local blockIcon = Images["icons/actions/block"]

	return Roact.createElement(DropDownButton, {
		layoutOrder = 4,
		text = playerRelationship.isBlocked and unblockText or blockedText,
		icon = blockIcon,
		lastButton = false,
		forceShowOptions = false,
		onActivated = function()
			if playerRelationship.isBlocked then
				self.props.unblockPlayer(selectedPlayer)
			else
				self.props.blockPlayer(selectedPlayer)
			end
		end,
	})
end

function PlayerDropDown:createReportButton()
	local selectedPlayer = self.props.selectedPlayer
	local reportIcon = Images["icons/actions/feedback"]

	return Roact.createElement(DropDownButton, {
		layoutOrder = 5,
		text = RobloxTranslator:FormatByKey("PlayerDropDown.Report"),
		icon = reportIcon,
		lastButton = true,
		forceShowOptions = false,
		onActivated = function()
			if isNewInGameMenuEnabled() then
				-- todo: move InGameMenu to a script global when removing isNewInGameMenuEnabled
				local InGameMenu = require(RobloxGui.Modules.InGameMenu)
				InGameMenu.openReportDialog(selectedPlayer)
			else
				-- This module has to be required here or it yields on initalization which breaks the unit tests.
				-- TODO: Revist this with new in game menu.
				local ReportAbuseMenu = require(RobloxGui.Modules.Settings.Pages.ReportAbuseMenu)
				ReportAbuseMenu:ReportPlayer(selectedPlayer)
				self.props.closeDropDown()
			end
		end,
	})
end

function PlayerDropDown:createInspectButton()
	local selectedPlayer = self.props.selectedPlayer
	local inspectIcon = Images["icons/actions/zoomIn"]

	return Roact.createElement(DropDownButton, {
		layoutOrder = 3,
		text = RobloxTranslator:FormatByKey("PlayerDropDown.Examine"),
		icon = inspectIcon,
		lastButton = selectedPlayer == LocalPlayer,
		forceShowOptions = false,
		onActivated = function()
			GuiService:InspectPlayerFromUserIdWithCtx(selectedPlayer.UserId, "leaderBoard")
			self.props.closeDropDown()
		end,
	})
end

function PlayerDropDown:render()
	return WithLayoutValues(function(layoutValues)
		local selectedPlayer = self.props.selectedPlayer

		if not selectedPlayer or self.props.isTenFootInterface then
			return nil
		end

		local dropDownButtons = {}

		dropDownButtons["UIListLayout"] = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, layoutValues.DropDownButtonPadding),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})

		dropDownButtons["PlayerHeader"] = Roact.createElement(DropDownPlayerHeader, {
			player = self.props.selectedPlayer,
		})
		local dropDownHeaderHeight = layoutValues.DropDownButtonPadding + layoutValues.DropDownHeaderSizeY
		local dropDownHeight = dropDownHeaderHeight

		local playerRelationship = self.props.playerRelationship
		if selectedPlayer ~= LocalPlayer then
			if not playerRelationship.isBlocked then
				dropDownButtons["FriendButton"] = self:createFriendButton(playerRelationship)
				dropDownHeight = dropDownHeight + layoutValues.DropDownButtonPadding + layoutValues.DropDownButtonSizeY
			end

			local showPlayerBlocking = not self.props.subjectToChinaPolicies or FFlagShowInGameBlockingLuobu
			local showPlayerReporting = not self.props.subjectToChinaPolicies or FFlagShowInGameReportingLuobu

			if showPlayerBlocking then
				dropDownButtons["BlockButton"] = self:createBlockButton(playerRelationship)
				dropDownHeight = dropDownHeight + layoutValues.DropDownButtonPadding + layoutValues.DropDownButtonSizeY
			end

			if showPlayerReporting then
				dropDownButtons["ReportButton"] = self:createReportButton()
				dropDownHeight = dropDownHeight + layoutValues.DropDownButtonPadding + layoutValues.DropDownButtonSizeY
			end
		end

		local disableInspectPolicy = FFlagInspectMenuSubjectToPolicy and self.props.subjectToChinaPolicies
		if self.props.inspectMenuEnabled and not disableInspectPolicy then
			dropDownButtons["InspectButton"] = self:createInspectButton()
			dropDownHeight = dropDownHeight + layoutValues.DropDownButtonPadding + layoutValues.DropDownButtonSizeY
		end

		dropDownHeight = dropDownHeight - layoutValues.DropDownButtonPadding

		local dropDownPosition = self.dropDownPosition
		dropDownPosition = dropDownPosition + (layoutValues.DropDownHeaderBackgroundSize - layoutValues.DropDownHeaderSizeY)
		if dropDownPosition + dropDownHeight > self.props.maxPositionBoundY then
			dropDownPosition = dropDownPosition - (dropDownPosition + dropDownHeight - self.props.maxPositionBoundY)
		elseif dropDownPosition < self.props.minPositionBoundY then
			dropDownPosition = dropDownPosition + (self.props.minPositionBoundY - dropDownPosition)
		end

		return Roact.createElement("Frame", {
			LayoutOrder = self.props.layoutOrder,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(0, 0, 0, dropDownPosition),
			Size = UDim2.new(0, layoutValues.PlayerDropDownSizeX + layoutValues.PlayerDropDownOffset, 0, dropDownHeight),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}, {
			InnerFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, -layoutValues.PlayerDropDownOffset, 1, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = true,

				[Roact.Ref] = self.innerFrameRef,
			}, dropDownButtons)
		})
	end)
end

function PlayerDropDown:getDropDownPosition()
	if self.props.isVisible and self.props.contentsVisible then
		return 0
	end
	return 1
end

function PlayerDropDown:didMount()
	local targetPosition = self:getDropDownPosition()
	self.motor:start()
	self.motor:setGoal(Otter.spring(targetPosition, self.motorOptions))
end

function PlayerDropDown:willUpdate(nextProps, nextState)
	if nextProps.selectedPlayer ~= self.props.selectedPlayer then
		self.dropDownPosition = nextProps.positionY
	end
end

function PlayerDropDown:didUpdate(previousProps, previousState)
	if previousProps.selectedPlayer ~= self.props.selectedPlayer then
		self.motor:setGoal(Otter.instant(1))
		self.motor:step(0)
	end

	local targetPosition = self:getDropDownPosition()
	self.motor:setGoal(Otter.spring(targetPosition, self.motorOptions))
end

function PlayerDropDown:willUnmount()
	self.motor:destroy()
end

local function mapStateToProps(state)
	local selectedPlayer = state.playerDropDown.selectedPlayer

	return {
		selectedPlayer = selectedPlayer,
		isVisible = state.playerDropDown.isVisible,
		playerRelationship = selectedPlayer and state.playerRelationship[selectedPlayer.UserId],
		inspectMenuEnabled = state.displayOptions.inspectMenuEnabled,
		isTenFootInterface = state.displayOptions.isTenFootInterface,
		subjectToChinaPolicies = state.displayOptions.subjectToChinaPolicies,
	}
end

local function mapDispatchToProps(dispatch)
	return {
		closeDropDown = function()
			return dispatch(ClosePlayerDropDown())
		end,

		blockPlayer = function(player)
			return dispatch(BlockPlayer(player))
		end,

		unblockPlayer = function(player)
			return dispatch(UnblockPlayer(player))
		end,
		
		requestFriendship = function(player, isAccept)
			return dispatch(RequestFriendship(player))
		end,
	}
end

return RoactRodux.UNSTABLE_connect2(mapStateToProps, mapDispatchToProps)(PlayerDropDown)
