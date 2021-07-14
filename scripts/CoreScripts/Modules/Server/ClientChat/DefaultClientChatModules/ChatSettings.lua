--	// FileName: ChatSettings.lua
--	// Written by: Xsitsu
--	// Description: Settings module for configuring different aspects of the chat window.

local PlayersService = game:GetService("Players")

local clientChatModules = script.Parent
local ChatConstants = require(clientChatModules:WaitForChild("ChatConstants"))

local module = {}

---[[ Chat Behaviour Settings ]]
module.WindowDraggable = false
module.WindowResizable = false
module.ShowChannelsBar = false
module.GamepadNavigationEnabled = false
module.AllowMeCommand = false -- Me Command will only be effective when this set to true
module.ShowUserOwnFilteredMessage = true	--Show a user the filtered version of their message rather than the original.
-- Make the chat work when the top bar is off
module.ChatOnWithTopBarOff = false
module.ScreenGuiDisplayOrder = 6 -- The DisplayOrder value for the ScreenGui containing the chat.

module.ShowFriendJoinNotification = true -- Show a notification in the chat when a players friend joins the game.

--- Replace with true/false to force the chat type. Otherwise this will default to the setting on the website.
module.BubbleChatEnabled = PlayersService.BubbleChat
module.ClassicChatEnabled = PlayersService.ClassicChat

---[[ Chat Text Size Settings ]]
module.ChatWindowTextSize = 18
module.ChatChannelsTabTextSize = 18
module.ChatBarTextSize = 18
module.ChatWindowTextSizePhone = 14
module.ChatChannelsTabTextSizePhone = 18
module.ChatBarTextSizePhone = 14

---[[ Font Settings ]]
module.DefaultFont = Enum.Font.SourceSansBold
module.ChatBarFont = Enum.Font.SourceSansBold

----[[ Color Settings ]]
module.BackGroundColor = Color3.new(0, 0, 0)
module.DefaultMessageColor = Color3.new(1, 1, 1)
module.DefaultNameColor = Color3.new(1, 1, 1)
module.ChatBarBackGroundColor = Color3.new(0, 0, 0)
module.ChatBarBoxColor = Color3.new(1, 1, 1)
module.ChatBarTextColor = Color3.new(0, 0, 0)
module.ChannelsTabUnselectedColor = Color3.new(0, 0, 0)
module.ChannelsTabSelectedColor = Color3.new(30/255, 30/255, 30/255)
module.DefaultChannelNameColor = Color3.fromRGB(35, 76, 142)
module.WhisperChannelNameColor = Color3.fromRGB(102, 14, 102)
module.ErrorMessageTextColor = Color3.fromRGB(245, 50, 50)

---[[ Window Settings ]]
module.MinimumWindowSize = UDim2.new(0.3, 0, 0.25, 0)
module.MaximumWindowSize = UDim2.new(1, 0, 1, 0) -- Should always be less than the full screen size.
module.DefaultWindowPosition = UDim2.new(0, 0, 0, 0)
local extraOffset = (7 * 2) + (5 * 2) -- Extra chatbar vertical offset
module.DefaultWindowSizePhone = UDim2.new(0.5, 0, 0.5, extraOffset)
module.DefaultWindowSizeTablet = UDim2.new(0.4, 0, 0.3, extraOffset)
module.DefaultWindowSizeDesktop = UDim2.new(0.3, 0, 0.25, extraOffset)

---[[ Fade Out and In Settings ]]
module.ChatWindowBackgroundFadeOutTime = 3.5 --Chat background will fade out after this many seconds.
module.ChatWindowTextFadeOutTime = 30 --Chat text will fade out after this many seconds.
module.ChatDefaultFadeDuration = 0.8
module.ChatShouldFadeInFromNewInformation = false
module.ChatAnimationFPS = 20.0

---[[ Channel Settings ]]
module.GeneralChannelName = "All" -- You can set to nil to turn off echoing to a general channel.
-- Should messages to channels other than general be echoed into the general channel.
-- Setting this to false should be used with ShowChannelsBar
module.EchoMessagesInGeneralChannel = true
module.ChannelsBarFullTabSize = 4 -- number of tabs in bar before it starts to scroll
module.MaxChannelNameLength = 12
-- To make sure whispering behavior remains consistent, this is currently set at 50 characters
module.MaxChannelNameCheckLength = 50
--// Although this feature is pretty much ready, it needs some UI design still.
module.RightClickToLeaveChannelEnabled = false
module.MessageHistoryLengthPerChannel = 50
-- Show the help text for joining and leaving channels. This is not useful unless custom channels have been added.
-- So it is turned off by default.
module.ShowJoinAndLeaveHelpText = false

---[[ Message Settings ]]
module.MaximumMessageLength = 200
module.DisallowedWhiteSpace = {"\n", "\r", "\t", "\v", "\f"}
module.ClickOnPlayerNameToWhisper = true
module.ClickOnChannelNameToSetMainChannel = true
module.BubbleChatMessageTypes = {ChatConstants.MessageTypeDefault, ChatConstants.MessageTypeWhisper}

---[[ Misc Settings ]]
module.WhisperCommandAutoCompletePlayerNames = true

--[[ Display Names ]]
--Uses DisplayNames instead of UserNames in chat messages
module.PlayerDisplayNamesEnabled = true
--Allows users to do /w displayName along with /w userName, only works if PlayerDisplayNamesEnabled is 'true'
module.WhisperByDisplayName = true

local ChangedEvent = Instance.new("BindableEvent")

local proxyTable = setmetatable({},
{
	__index = function(tbl, index)
		return module[index]
	end,
	__newindex = function(tbl, index, value)
		module[index] = value
		ChangedEvent:Fire(index, value)
	end,
})

rawset(proxyTable, "SettingsChanged", ChangedEvent.Event)

return proxyTable
