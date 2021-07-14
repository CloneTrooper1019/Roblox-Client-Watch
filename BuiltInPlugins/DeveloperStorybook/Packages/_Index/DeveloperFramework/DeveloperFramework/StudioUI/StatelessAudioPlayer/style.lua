local Framework = script.Parent.Parent.Parent

local StudioUIFolderData = require(Framework.StudioUI.StudioUIFolderData)
local MediaPlayerControls = require(StudioUIFolderData.MediaPlayerControls.style)

local Util = require(Framework.Util)
local deepCopy = Util.deepCopy
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		PlaceholderImage = {
			ScaleType = Enum.ScaleType.Fit,
			Image = "rbxasset://textures/DeveloperFramework/AudioPlayer/audioPlay_BG.png",
			Color = Color3.fromRGB(204, 204, 204),
		},
		MediaPlayerControls = deepCopy(MediaPlayerControls),
	}
else
	return function(theme, getColor)
		local mediaPlayerControls = MediaPlayerControls(theme, getColor)

		local Default = {
			PlaceholderImage = {
				ScaleType = Enum.ScaleType.Fit,
				Image = "rbxasset://textures/DeveloperFramework/AudioPlayer/audioPlay_BG.png",
				Color = Color3.fromRGB(204, 204, 204),
			},
			MediaPlayerControls = mediaPlayerControls.Default
		}

		return {
			Default = Default
		}
	end
end
