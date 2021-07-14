--[[
	A frame with a title offset to the left side.
	Used as a distinct vertical entry on a SettingsPage.

	Props:
		string Title = The text to display in this TitledFrame's left-hand title.
		int MaxHeight = The maximum height of this TitledFrame in pixels. Defaults to 100.
		int LayoutOrder = The order which this TitledFrame will sort to in a UIListLayout.
		int TextSize = The size of text
	Optional:
		Image Tooltip = a tooltip to describe the title
]]

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)
local Theming = require(Library.Theming)
local withTheme = Theming.withTheme
local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")

local CENTER_GUTTER = 180

local function TitledFrame(props)
	return withTheme(function(theme)
		local textSize = props.TextSize
		local centerGutter = props.CenterGutter or CENTER_GUTTER
		local tooltip = FFlagLuobuDevPublishLua and props.Tooltip or nil

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = props.ZIndex or 1,
			Size = UDim2.new(1, 0, 0, props.MaxHeight or 100),
			LayoutOrder = props.LayoutOrder or 1,
		}, {
			Title = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(0, centerGutter, 1, 0),

				TextColor3 = theme.titledFrame.text,
				Font = theme.titledFrame.font,
				TextSize = textSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				Text = props.Title,
				TextWrapped = true,
			}, {
				Tooltip = FFlagLuobuDevPublishLua and tooltip or nil,
			}),

			Content = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Size = UDim2.new(1, -centerGutter, 1, 0),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 0),
			}, props[Roact.Children]),
		})
	end)
end

return TitledFrame