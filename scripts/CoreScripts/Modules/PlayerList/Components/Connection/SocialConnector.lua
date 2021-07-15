local CorePackages = game:GetService("CorePackages")
local Players = game:GetService("Players")

local Roact = require(CorePackages.Roact)
local RoactRodux = require(CorePackages.RoactRodux)

local Components = script.Parent.Parent
local PlayerList = Components.Parent

local SetPlayerFriendStatus = require(PlayerList.Actions.SetPlayerFriendStatus)

local EventConnection = require(script.Parent.EventConnection)

local SocialConnector = Roact.PureComponent:extend("SocialConnector")

function SocialConnector:didMount()
	self.mounted = true
end

function SocialConnector:render()
	return Roact.createFragment({
		FriendStatusChangedConnection = Roact.createElement(EventConnection, {
			event = Players.LocalPlayer.FriendStatusChanged,
			callback = function(player, friendStatus)
				self.props.setPlayerFriendStatus(player, friendStatus)
			end,
		})
	})
end

function SocialConnector:willUnmount()
	self.mounted = false
end

local function mapDispatchToProps(dispatch)
	return {
		setPlayerFriendStatus = function(player, friendStatus)
			return dispatch(SetPlayerFriendStatus(player, friendStatus))
		end,
	}
end

return RoactRodux.connect(nil, mapDispatchToProps)(SocialConnector)
