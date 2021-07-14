local Framework = script.Parent.Parent.Parent

local StyleKey = require(Framework.Style.StyleKey)

local Util = require(Framework.Util)
local Style = Util.Style
local StyleModifier = Util.StyleModifier
local StyleValue = Util.StyleValue
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local UI = require(Framework.UI)
local Decoration = UI.Decoration

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)

local BAR_HEIGHT = 6
local BAR_SLICE_CENTER = Rect.new(3, 0, 4, 6)
local SLIDER_HANDLE_SIZE = 18

if THEME_REFACTOR then
	local knobStyle = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Color = StyleKey.SliderKnobColor,
		Image = StyleKey.SliderKnobImage,
		Size = UDim2.new(0, SLIDER_HANDLE_SIZE, 0, SLIDER_HANDLE_SIZE),
		[StyleModifier.Disabled] = {
			Color = StyleKey.Button,
		},
	}

	return {
		KnobSize = Vector2.new(18, 18),
		Background = Decoration.Image,
		BackgroundStyle = {
			AnchorPoint = Vector2.new(0, 0.5),
			Color = StyleKey.SliderBackground,
			Image = "rbxasset://textures/DeveloperFramework/slider_bg.png",
			Position = UDim2.new(0, 0, 0.5, 0),
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.new(UDim.new(1, 0), UDim.new(0, BAR_HEIGHT)),
			SliceCenter = BAR_SLICE_CENTER,
		},
		Foreground = Decoration.Image,
		ForegroundStyle = {
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxasset://textures/DeveloperFramework/slider_bg.png",
			Color = StyleKey.DialogMainButton,
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.new(UDim.new(1, 0), UDim.new(0, BAR_HEIGHT)),
			SliceCenter = BAR_SLICE_CENTER,
			[StyleModifier.Disabled] = {
				Color = StyleKey.Button,
			},
		},
		LowerKnobBackground = Decoration.Image,
		LowerKnobBackgroundStyle = knobStyle,
		UpperKnobBackground = Decoration.Image,
		UpperKnobBackgroundStyle = knobStyle,
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)

		local BackgroundColor = StyleValue.new("BackgroundColor", {
			Light = Color3.fromRGB(204, 204, 204),
			Dark = Color3.fromRGB(37, 37, 37),
		})

		local KnobColor = StyleValue.new("KnobColor", {
			Light = Color3.fromRGB(255, 255, 255),
			Dark = Color3.fromRGB(85, 85, 85),
		})

		local KnobImage = StyleValue.new("KnobImage", {
			Light = "rbxasset://textures/DeveloperFramework/slider_knob_light.png",
			Dark = "rbxasset://textures/DeveloperFramework/slider_knob.png",
		})

		local knobStyle = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Color = KnobColor:get(theme.Name),
			Image = KnobImage:get(theme.Name),
			Size = UDim2.new(0, SLIDER_HANDLE_SIZE, 0, SLIDER_HANDLE_SIZE),
			[StyleModifier.Disabled] = {
				Color = theme:GetColor("Button"),
			},
		}

		local Default = Style.extend(common.MainText, {
			KnobSize = Vector2.new(18, 18),
			Background = Decoration.Image,
			BackgroundStyle = {
				AnchorPoint = Vector2.new(0, 0.5),
				Color = BackgroundColor:get(theme.Name),
				Image = "rbxasset://textures/DeveloperFramework/slider_bg.png",
				Position = UDim2.new(0, 0, 0.5, 0),
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.new(UDim.new(1, 0), UDim.new(0, BAR_HEIGHT)),
				SliceCenter = BAR_SLICE_CENTER,
			},
			Foreground = Decoration.Image,
			ForegroundStyle = {
				AnchorPoint = Vector2.new(0, 0.5),
				Image = "rbxasset://textures/DeveloperFramework/slider_bg.png",
				Color = theme:GetColor("DialogMainButton"),
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.new(UDim.new(1, 0), UDim.new(0, BAR_HEIGHT)),
				SliceCenter = BAR_SLICE_CENTER,
				[StyleModifier.Disabled] = {
					Color = theme:GetColor("Button"),
				},
			},
			LowerKnobBackground = Decoration.Image,
			LowerKnobBackgroundStyle = knobStyle,
			UpperKnobBackground = Decoration.Image,
			UpperKnobBackgroundStyle = knobStyle,
		})

		return {
			Default = Default,
		}
	end
end
