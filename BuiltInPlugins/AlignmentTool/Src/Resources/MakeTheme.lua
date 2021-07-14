--[[
	Creates the theme for the plugin.

	Extends the default StudioFrameworkStyles, and also defines values specific
	to components created within this plugin and constant values shared across components.

	Params:
		bool createMock: An optional param that should only be set to true in testing.
]]

local Plugin = script.Parent.Parent.Parent

local Cryo = require(Plugin.Packages.Cryo)
local Framework = require(Plugin.Packages.Framework)

local THEME_REFACTOR = Framework.Util.RefactorFlags.THEME_REFACTOR

local FrameworkStyle = Framework.Style
local Colors = FrameworkStyle.Colors
local StudioTheme = FrameworkStyle.Themes.StudioTheme
local StyleKey = FrameworkStyle.StyleKey
local ui = FrameworkStyle.ComponentSymbols
local getRawComponentStyle = FrameworkStyle.getRawComponentStyle

local Util = Framework.Util
local StyleModifier = Util.StyleModifier

local getFFlagDevFrameworkCheckbox = require(Plugin.Src.Flags.getFFlagDevFrameworkCheckbox)

if THEME_REFACTOR then
	local darkThemeOverride = {
		[StyleKey.HelpIconColor] = Colors.Gray_Light,
		[StyleKey.SelectableButtonBorderColor] = Colors.Gray,
		[StyleKey.SelectableButtonSelectedColor] = Colors.Gray_Mid,
	}
	local lightThemeOverride = {
		[StyleKey.HelpIconColor] = Color3.fromRGB(184, 184, 184),
		[StyleKey.SelectableButtonBorderColor] = Colors.Gray_Light,
		[StyleKey.SelectableButtonSelectedColor] = Colors.Gray_Lighter,
	}

	local PluginTheme = {
		CheckboxImageSize = not getFFlagDevFrameworkCheckbox() and UDim2.new(0, 16, 0, 16) or nil,
		CheckboxLabelSpacing = not getFFlagDevFrameworkCheckbox() and 6 or nil,

		SectionPadding = UDim.new(0, 15),
		SectionContentPadding = UDim.new(0, 10),
		SectionContentPaddingCompact = UDim.new(0, 6),

		InfoLabel = {
			ErrorTextColor = StyleKey.ErrorText,
			WarningTextColor = StyleKey.WarningText,
			InfoTextColor = StyleKey.MainText,
		},

		MainView = {
			ListItemPadding = UDim.new(0, 10),
			Padding = 10,
			PrimaryButtonSize = UDim2.new(0, 160, 0, 32),
		},

		RelativeToSetting = {
			HelpIconPadding = UDim.new(0, 2),
		},

		LabeledElementList = {
			ItemContentPadding = UDim.new(0, 10),
			ItemPaddingHorizontal = UDim.new(0, 15),
			ItemPaddingVertical = UDim.new(0, 8),
			MaximumLabelWidth = 100,
			SectionPadding = UDim.new(0, 15),
		},

		[ui.Button] = Cryo.Dictionary.join(getRawComponentStyle("Button"), {
			["&Selectable"] = {
				BackgroundStyle = {
					BorderSize = 1,
					Transparency = 1,
				},
				[StyleModifier.Hover] = {
					BackgroundStyle = {
						BorderColor = StyleKey.SelectableButtonBorderColor,
						BorderSize = 1,
						Color = StyleKey.ButtonHover,
						Transparency = 0,
					},
				},
				[StyleModifier.Selected] = {
					BackgroundStyle = {
						BorderColor = StyleKey.SelectableButtonBorderColor,
						BorderSize = 1,
						Color = StyleKey.SelectableButtonSelectedColor,
						Transparency = 0,
					},
				},
			},
		}),

		[ui.Image] = Cryo.Dictionary.join(getRawComponentStyle("Image"), {
			["&HelpIcon"] = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Color = StyleKey.HelpIconColor,
				Image = "rbxasset://textures/AlignTool/Help.png",
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),

				[StyleModifier.Disabled] = {
					Transparency = 0.5,
				},
			},
		}),
	}

	return function(createMock)
		local styleRoot
		if createMock then
			styleRoot = StudioTheme.mock()
		else
			styleRoot = StudioTheme.new(darkThemeOverride, lightThemeOverride)
		end

		return styleRoot:extend(PluginTheme)
	end
else
	assert(false, "Align Tool requires Stylizer")
end
