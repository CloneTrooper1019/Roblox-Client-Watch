--[[
	An element with rounded corners.
	Designed to function almost identically to a standard roblox Frame.

	Props:
		Color3 BackgroundColor3 = The background color of the frame.
		float BackgroundTransparency = The transparency of the frame's background and border.
		Color3 BorderColor = The border color of the frame.
		int BorderSizePixel:
			If == 0, the border will not render. If ~= 0, the border will render.

		UDim2 Size = The size of the frame.
		UDim2 Position = The position of the frame.
		Vector2 AnchorPoint = The center point of this frame.
		int LayoutOrder = The layout order of the frame, if in a Layout.
		int ZIndex = The draw index of the frame.

		function OnActivated = A callback fired when the user clicks the frame.
		function OnMouseEnter = A callback fired when the mouse enters the frame.
		function OnMouseLeave = A callback fired when the mouse leaves the frame.

		[Roact.Change.AbsoluteSize] = An event that fires when the frame's AbsoluteSize changes
		[Roact.Change.AbsolutePosition] = An event that fires when the frame's AbsolutePosition changes
]]

local Library = script.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local ROUNDED_FRAME_SLICE = Rect.new(3, 3, 13, 13)
local DEFAULT_BORDER_COLOR = Color3.fromRGB(27, 42, 53)
local DEFAULT_SIZE = UDim2.new(0, 100, 0, 100)

local RoundFrame = Roact.PureComponent:extend("RoundFrame")

function RoundFrame:init(initialProps)
	local isButton = initialProps.OnActivated ~= nil
	self.elementType = isButton and "ImageButton" or "ImageLabel"
end

function RoundFrame:render()
	return withTheme(function(theme)
		local props = self.props
		local roundFrameTheme = theme.roundFrame

		local backgroundColor = props.BackgroundColor3
		local backgroundTransparency = props.BackgroundTransparency
		local borderColor = props.BorderColor3 or DEFAULT_BORDER_COLOR
		local borderSize = props.BorderSizePixel or 1
		local size = props.Size or DEFAULT_SIZE
		local position = props.Position
		local anchorPoint = props.AnchorPoint
		local layoutOrder = props.LayoutOrder
		local zindex = props.ZIndex
		local activatedCallback = props.OnActivated
		local mouseEnterCallback = props.OnMouseEnter
		local mouseLeaveCallback = props.OnMouseLeave

		local borderTransparency
		if borderSize == 0 then
			borderTransparency = 1
		else
			borderTransparency = backgroundTransparency
		end

		return Roact.createElement(self.elementType, {
			Size = size,
			Position = position,
			AnchorPoint = anchorPoint,
			LayoutOrder = layoutOrder,
			ZIndex = zindex,

			BackgroundTransparency = 1,
			ImageColor3 = backgroundColor,
			ImageTransparency = backgroundTransparency,

			Image = roundFrameTheme.backgroundImage,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = ROUNDED_FRAME_SLICE,

			[Roact.Event.MouseEnter] = mouseEnterCallback,
			[Roact.Event.MouseLeave] = mouseLeaveCallback,
			[Roact.Event.Activated] = activatedCallback,

			[Roact.Change.AbsoluteSize] = props[Roact.Change.AbsoluteSize],
			[Roact.Change.AbsolutePosition] = props[Roact.Change.AbsolutePosition],
		}, {
			Border = Roact.createElement("ImageLabel", {
				Size = UDim2.new(1, 0, 1, 0),

				BackgroundTransparency = 1,
				ImageColor3 = borderColor,
				ImageTransparency = borderTransparency,

				Image = roundFrameTheme.borderImage,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = ROUNDED_FRAME_SLICE,
				SliceScale = borderSize,
			}, props[Roact.Children])
		})
	end)
end

return RoundFrame
