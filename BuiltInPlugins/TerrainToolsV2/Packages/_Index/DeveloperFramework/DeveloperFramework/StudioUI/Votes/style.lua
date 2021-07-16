local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local deepCopy = Util.deepCopy
local Style = Util.Style
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR
local Common = require(Framework.StudioUI.StudioFrameworkStyles.Common)

local height = 16
local textSize = 24

if THEME_REFACTOR then
	local common = deepCopy(Common)

	return {
		Size = UDim2.new(1, 0, 0, height),

		Text = Cryo.Dictionary.join(common.MainText, {
			TextSize = textSize,
		}),

		Icon = {
			Image = "rbxasset://textures/DeveloperFramework/Votes/rating_small.png",
			Size = UDim2.fromOffset(height, height),
		}
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)

		local Default = Style.extend({
			Size = UDim2.new(1, 0, 0, height),

			Text = Style.extend(common.MainText, {
				TextSize = textSize,
			}),

			Icon = {
				Image = "rbxasset://textures/DeveloperFramework/Votes/rating_small.png",
				Size = UDim2.fromOffset(height, height),
			}
		})

		return {
			Default = Default
		}
	end
end
