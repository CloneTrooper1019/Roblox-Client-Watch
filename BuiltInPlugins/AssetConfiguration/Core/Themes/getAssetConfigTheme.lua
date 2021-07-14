--[[
	Gets the new Stylizer-compatible AssetConfigTheme
	This should replace AssetConfigTheme once UILibrary and withTheme are completely removed.
]]
local FFlagToolboxReplaceUILibraryComponentsPt2 = game:GetFastFlag("ToolboxReplaceUILibraryComponentsPt2")
local FFlagToolboxReplaceUILibraryComponentsPt3 = game:GetFastFlag("ToolboxReplaceUILibraryComponentsPt3")

local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs

local Framework = require(Libs.Framework)

local FrameworkStyle = Framework.Style
local StyleKey = FrameworkStyle.StyleKey
local ui = FrameworkStyle.ComponentSymbols
local getRawComponentStyle = FrameworkStyle.getRawComponentStyle
local StyleModifier = require(Libs.Framework.Util.StyleModifier)

local Cryo = require(Plugin.Libs.Cryo)

return function()
	if not FFlagToolboxReplaceUILibraryComponentsPt2 or not FFlagToolboxReplaceUILibraryComponentsPt3 then
		return
	end

	local roundBox = getRawComponentStyle("RoundBox")
	local button = getRawComponentStyle("Button")

	return {
		assetConfig = {
			labelTextColor = StyleKey.DimmedText,
			textColor = StyleKey.MainText,

			packagePermissions = {
				backgroundColor = StyleKey.MainBackground,
				subTextColor = StyleKey.SubText,

				searchBar = {
					dropDown = {
						backgroundColor = StyleKey.InputFieldBackground,
						headerText = StyleKey.SubText,

						hovered = {
							backgroundColor = StyleKey.ItemHovered,
						},

						selected = {
							backgroundColor = StyleKey.ButtonSelected,
						},
					},
				}
			}
		},

		detailedDropdown = {
			displayText = StyleKey.MainText,
			descriptionText = StyleKey.SubText,
			backgroundColor = StyleKey.MainBackground,
			borderColor = StyleKey.DialogButtonBorder,

			hovered = {
				displayText = StyleKey.MainTextHover,
			},
		},

		footer = {
			backgroundColor = StyleKey.MainBackground,
			borderColor = StyleKey.Border,
		},

		inputFields = {
			backgroundColor = StyleKey.InputFieldBackground,
			toolTip = StyleKey.DimmedText,
			error = StyleKey.ErrorText,
		},

		tags = {
			textColor = StyleKey.MainText,
		},

		[ui.Button] = Cryo.Dictionary.join(button, {
			["&SelectedDetailedDropdownItem"] = {
				BackgroundStyle = Cryo.Dictionary.join(roundBox, {
					Color = StyleKey.ItemSelected,
					TextColor = StyleKey.MainTextSelected,
				}),
			},
		}),

		[ui.RoundBox] = Cryo.Dictionary.join(roundBox, {
			["&CatalogTag"] = {
				Color = StyleKey.MainBackground,
				BorderColor = StyleKey.Border,
			},
			["&TagsComponent"] = {
				Color = StyleKey.InputFieldBackground,
				BorderColor = StyleKey.Border,

				[StyleModifier.Selected] = {
					BorderColor = StyleKey.InputFieldBorderSelected,
				},
				[StyleModifier.Disabled] = {
					Color = StyleKey.InputFieldBackgroundDisabled,
				},
			},
			["&TagsComponentError"] = {
				BorderColor = StyleKey.ErrorText,
			},
		}),
	}
end