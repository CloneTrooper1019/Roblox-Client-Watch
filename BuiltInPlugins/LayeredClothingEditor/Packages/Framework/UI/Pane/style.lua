local Framework = script.Parent.Parent.Parent

local Dash = require(Framework.packages.Dash)
local join = Dash.join

local StyleKey = require(Framework.Style.StyleKey)

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)

local Util = require(Framework.Util)
local StyleModifier = Util.StyleModifier
local Style = Util.Style
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	local box = {
		Background = StyleKey.MainBackground,
		[StyleModifier.Hover] = {
			Background = StyleKey.ButtonHover,
		},
		[StyleModifier.Selected] = {
			Background = StyleKey.DialogMainButton,
		}
	}
	local subtleBox = join(box, {
		Background = StyleKey.SubBackground,
	})
	local roundBox = join(box, {
		Image = "rbxasset://textures/StudioToolbox/RoundedBackground.png",
		SliceCenter = Rect.new(3, 3, 13, 13),
	})
	local borderBox = join(roundBox, {
		Border = {
			Background = StyleKey.Border,
			Image = "rbxasset://textures/StudioToolbox/RoundedBorder.png",
			SliceCenter = Rect.new(3, 3, 13, 13),
		}
	})
	return {
		["&Box"] = box,
		["&SubtleBox"] = subtleBox,
		["&RoundBox"] = roundBox,
		["&BorderBox"] = borderBox,
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)

		local Default = Style.extend(common.MainText, {})

		local Box = Style.extend(Default, {
			Background = theme:GetColor("MainBackground"),
		})

		local RoundBox = Style.extend(Box, {
			Image = "rbxasset://textures/StudioToolbox/RoundedBackground.png",
			SliceCenter = Rect.new(3, 3, 13, 13),
		})

		local BorderBox = Style.extend(RoundBox, {
			Border = {
				Background = theme:GetColor("Border"),
				Image = "rbxasset://textures/StudioToolbox/RoundedBorder.png",
				SliceCenter = Rect.new(3, 3, 13, 13),
			}
		})

		return {
			Default = Default,
			Box = Box,
			RoundBox = RoundBox,
			BorderBox = BorderBox,
		}
	end
end
