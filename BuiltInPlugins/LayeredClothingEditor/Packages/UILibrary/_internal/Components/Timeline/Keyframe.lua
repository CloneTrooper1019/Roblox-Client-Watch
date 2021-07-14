-- TODO: Delete file when FFlagRemoveUILibraryTimeline is retired
--[[
	A single keyframe which can be displayed on a media timeline.

	Props:
		int Width = The size in pixels of the keyframe item. Determines both width and height.
		UDim2 Position = The position of the keyframe.
		int ZIndex = The display order of the keyframe.
		int BorderSizePixel = The size of the keyframe's border highlight.
		string Style = A style key for coloring this keyframe. Indexed into the keyframe theme.

		bool Selected = Whether this keyframe is currently selected. Changes the appearance.

		function OnActivated = A callback for when the user clicks on this keyframe.
		function OnRightClick = A callback for when the user right-clicks on this keyframe.
		function OnInputBegan = A callback for when the user starts interacting with the keyframe.
		function OnInputEnded = A callback for when the user stops interacting with the keyframe.
]]

local Library = script.Parent.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)
local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local DEFAULT_WIDTH = 10
local DEFAULT_BORDER_SIZE = 2

local Keyframe = Roact.PureComponent:extend("Keyframe")

function Keyframe:render()
	return withTheme(function(theme)
		local props = self.props

		local style = props.Style
		local selected = props.Selected

		local themeBase = style and theme.keyframe[style] or theme.keyframe.Default
		local keyframeTheme = selected and themeBase.selected or themeBase

		local position = props.Position
		local borderSize = props.BorderSizePixel or DEFAULT_BORDER_SIZE
		local width = props.Width or DEFAULT_WIDTH
		local zindex = props.ZIndex

		local onActivated = props.OnActivated
		local onRightClick = props.OnRightClick
		local onInputBegan = props.OnInputBegan
		local onInputEnded = props.OnInputEnded

		return Roact.createElement("ImageButton", {
			Size = UDim2.new(0, width, 0, width),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position,
			Rotation = 45,
			ZIndex = zindex,

			ImageTransparency = 1,
			BackgroundTransparency = 0,
			AutoButtonColor = false,

			BorderSizePixel = borderSize,
			BorderColor3 = keyframeTheme.borderColor,
			BackgroundColor3 = keyframeTheme.backgroundColor,

			[Roact.Event.Activated] = onActivated,
			[Roact.Event.MouseButton2Click] = onRightClick,

			[Roact.Event.InputBegan] = onInputBegan,
			[Roact.Event.InputEnded] = onInputEnded,
		}, props[Roact.Children])
	end)
end

return Keyframe
