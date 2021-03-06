local Plugin = script.Parent.Parent.Parent

local Framework = require(Plugin.Packages.Framework)
local Cryo = require(Plugin.Packages.Cryo)

local RefactorFlags = Framework.Util.RefactorFlags

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local StudioTheme = Framework.Style.Themes.StudioTheme
local Theme = Framework.ContextServices.Theme

local Style = Framework.Util.Style
local StyleTable = Framework.Util.StyleTable

local FrameworkStyle = Framework.Style
local BaseTheme = FrameworkStyle.Themes.BaseTheme
local StyleKey = FrameworkStyle.StyleKey
local ui = FrameworkStyle.ComponentSymbols

local function makeTerrainToolsTheme()
	return {
		[ui.LoadingBar] = Cryo.Dictionary.join(BaseTheme[ui.LoadingBar], {
			ForegroundStyle = Cryo.Dictionary.join(BaseTheme[ui.LoadingBar].ForegroundStyle, {
				Color = StyleKey.DialogMainButton,
				BorderTransparency = 1,
			}),
		}),

		[ui.Tooltip] = Cryo.Dictionary.join(BaseTheme[ui.Tooltip], {
			MaxWidth = 1000,
		}),

		Spinner = {
			TimeBetweenBlocks = 0.05,
			Colors = {
				Color3.fromRGB(172, 172, 172),
				Color3.fromRGB(172, 172, 172),
				Color3.fromRGB(159, 159, 159),
				Color3.fromRGB(140, 140, 140),
				Color3.fromRGB(122, 122, 122),
				Color3.fromRGB(103, 103, 103),
				Color3.fromRGB( 84,  84,  84),
				Color3.fromRGB( 65,  65,  65),
			},
			BlockWidth = 2,
			InnerRadius = 7,
		},
	}
end

local function DEPRECATED_makeTerrainToolsTheme(theme, getColor)
	local studioFrameworkStyles = StudioFrameworkStyles.new(theme, getColor)

	local tooltip = StyleTable.new("Tooltip", function()
		return {
			Default = Style.extend(studioFrameworkStyles.Tooltip.Default, {
				MaxWidth = 1000,
			}),
		}
	end)

	local loadingBar = StyleTable.new("LoadingBar", function()
		local base = studioFrameworkStyles.LoadingBar.Default
		return {
			Default = Style.extend(base, {
				ForegroundStyle =  Style.extend(base.ForegroundStyle, {
					Color = theme:GetColor("DialogMainButton"),
					BorderTransparency = 1,
				}),
			}),
		}
	end)

	local spinner = StyleTable.new("Spinner", function()
		local Default = Style.new({
			TimeBetweenBlocks = 0.05,
			Colors = {
				Color3.fromRGB(172, 172, 172),
				Color3.fromRGB(172, 172, 172),
				Color3.fromRGB(159, 159, 159),
				Color3.fromRGB(140, 140, 140),
				Color3.fromRGB(122, 122, 122),
				Color3.fromRGB(103, 103, 103),
				Color3.fromRGB( 84,  84,  84),
				Color3.fromRGB( 65,  65,  65),
			},
			BlockWidth = 2,
			InnerRadius = 7,
		})

		return {
			Default = Default,
		}
	end)

	return {
		Framework = StyleTable.extend(studioFrameworkStyles, {
			Tooltip = tooltip,
			LoadingBar = loadingBar,
		}),

		TerrainTools = {
			Spinner = spinner,
		},
	}
end

return function(makeMock)
	makeMock = makeMock or false

	if RefactorFlags.THEME_REFACTOR then
		local studioTheme = makeMock and StudioTheme.mock() or StudioTheme.new()
		return studioTheme:extend(makeTerrainToolsTheme())
	else
		if makeMock then
			return Theme.mock(DEPRECATED_makeTerrainToolsTheme, function()
				return {
					Name = "MockTheme",
					GetColor = function() return Color3.fromRGB(0, 0, 0) end,
				}
			end)
		else
			return Theme.new(DEPRECATED_makeTerrainToolsTheme)
		end
	end
end
