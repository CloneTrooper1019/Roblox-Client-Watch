local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local Style = Util.Style

local StyleKey = require(Framework.Style.StyleKey)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		Color = StyleKey.Border,
		Image = "rbxasset://textures/StudioSharedUI/dropShadow.png",
		ImageSize = 16,
		Offset = Vector2.new(),
		Radius = 6,
		Transparency = 0,
	}
else
	return function(theme, getColor)

		local Default = Style.new({
			Color = theme:GetColor("Border"),
			Image = "rbxasset://textures/StudioSharedUI/dropShadow.png",
			ImageSize = 16,
			Offset = Vector2.new(),
			Radius = 6,
			Transparency = 0
		})

		return {
			Default = Default,
		}
	end
end
