local Framework = script.Parent.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Plugin = ContextServices.Plugin
local Theme = ContextServices.Theme

local Pane = require(Framework.UI).Pane
local ColoredSquare = require(script.Parent.ColoredSquare)

local Util = require(Framework.Util)
local StyleTable = Util.StyleTable
local Style = Util.Style
local StyleModifier = Util.StyleModifier

local pluginItem = Plugin.new(plugin)

-- Create a Theme for ColoredSquare, with Default and Red styles.
local theme = Theme.new(function(theme, getColor)
	return {
		Examples = {
			ColoredSquare = StyleTable.new("ColoredSquare", function()
				-- A Default style is always required.
				local Default = Style.new({
					Color = getColor("Mock_TestColor"),
				})

				-- When a ColoredSquare is created with props.Style = "Red",
				-- this style will be used.
				local Red = Style.new({
					Color = Color3.new(1, 0, 0),
				})

				-- This style has a StyleModifier subset, so if the ColoredSquare
				-- state includes Hover at StyleModifier, it will use values from
				-- that table, falling back to the unmodified style.
				local BlueOrange = Style.new({
					Color = Color3.new(0, 0, 1),
					[StyleModifier.Hover] = Style.new({
						Color = Color3.new(1, 0.6, 0),
					}),
				})

				return {
					Default = Default,
					Red = Red,
					BlueOrange = BlueOrange,
				}
			end),
		},
	}
end)

return ContextServices.provide({pluginItem, theme}, {
	Roact.createElement(Pane, {
		AutomaticSize = Enum.AutomaticSize.Y,
		Layout = Enum.FillDirection.Vertical
	}, {
		-- Style is implicitly Default if not defined.
		-- ThemedSquare will be white on light theme, and black
		-- on dark theme.
		ThemedSquare = Roact.createElement(ColoredSquare, {
			Position = UDim2.new(0, 0, 0, 0), -- Top left
		}),

		-- Specifying the Red style will draw from the Red entry
		-- defined in the ColoredSquare StyleTable.
		-- We refer to styles by their name (a string).
		RedSquare = Roact.createElement(ColoredSquare, {
			Position = UDim2.new(0, 100, 0, 0), -- Top right
			Style = "Red",
		}),

		-- NOT for production code, but for quick iteration you can
		-- define a style directly on the element at creation time,
		-- rather than make a Style for it in the theme.
		GreenSquare = Roact.createElement(ColoredSquare, {
			Position = UDim2.new(0, 0, 0, 100), -- Bottom left
			Style = Style.new({
				Color = Color3.new(0, 1, 0),
			}),
		}),

		-- This square changes to orange when the mouse hovers over it
		-- by using state.StyleModifier.
		BlueOrangeSquare = Roact.createElement(ColoredSquare, {
			Position = UDim2.new(0, 100, 0, 100), -- Bottom right
			Style = "BlueOrange",
		}),
	})
})
