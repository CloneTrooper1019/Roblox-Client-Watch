--[[
	Basic styles shared among multiple StudioFrameworkStyles tables.
]]
local FFlagDevFrameworkRefactorScrollbarColor = game:GetFastFlag("DevFrameworkRefactorScrollbarColor")

local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local Style = Util.Style
local StyleValue = Util.StyleValue

local StyleKey = require(Framework.Style.StyleKey)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	-- TODO: DEVTOOLS-4908 Refactor everything using MainText so that we can remove Common.lua completely
	return {
		MainText = {
			Font = Enum.Font.SourceSans,
			TextSize = 18,
			TextColor = StyleKey.MainText,
		},
	}
else
	return function(theme, getColor)
		local MainText = Style.new({
			Font = Enum.Font.SourceSans,
			TextSize = 18,
			TextColor = theme:GetColor("MainText"),
		})

		local Background = Style.new({
			Color = theme:GetColor("MainBackground"),
		})

		local Border = Style.new({
			BorderColor = theme:GetColor("Border"),
		})

		local BorderHover = Style.new({
			BorderColor = theme:GetColor("DialogMainButton"),
		})

		local Scroller = Style.new({
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			BackgroundColor3 = theme:GetColor("MainBackground"),

			TopImage = "rbxasset://textures/StudioToolbox/ScrollBarTop.png",
			MidImage = "rbxasset://textures/StudioToolbox/ScrollBarMiddle.png",
			BottomImage = "rbxasset://textures/StudioToolbox/ScrollBarBottom.png",

			ScrollingEnabled = true,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ScrollBarThickness = 8,
			ScrollBarImageTransparency = FFlagDevFrameworkRefactorScrollbarColor and 0 or 0.5,
			ScrollBarImageColor3 = StyleValue.new("ScrollbarColor", {
				Light = Color3.fromRGB(25, 25, 25),
				Dark = Color3.fromRGB(204, 204, 204),
			}):get(theme.name),
			VerticalScrollBarInset = Enum.ScrollBarInset.Always
		})

		return {
			Default = Background,
			MainText = MainText,
			Background = Background,
			Border = Border,
			BorderHover = BorderHover,
			Scroller = Scroller,
		}
	end
end
