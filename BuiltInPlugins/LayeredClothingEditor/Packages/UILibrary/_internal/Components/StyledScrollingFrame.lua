--[[
	A scrolling frame with a colored background, providing a consistent look
	with the Studio native start page.

	Props:
		UDim2 Position = The position of the scrolling frame.
		UDim2 Size = The size of the scrolling frame.
		UDim2 CanvasSize = The size of the scrolling frame's canvas.

		int LayoutOrder = The order this component will display in a UILayout.
		int ZIndex = The draw index of the frame.

		bool ScrollingEnabled = Whether scrolling in this frame will change the CanvasPosition.
		int ScrollBarPadding = The padding which appears on either side of the scrollbar.
		int ScrollBarThickness = The horizontal width of the scrollbar.

		function OnScroll(Vector2 CanvasPosition) = A callback for when the CanvasPosition changes.
	Optional Props:
		Color3 BackgroundColor: If provided, we set BackgroundTransparency to 0 and show the provided color as background and border
]]
local FFlagLuobuDevPublishLua = game:GetFastFlag("LuobuDevPublishLua")
local FFlagLuobuDevPublishLuaTempOptIn = game:GetFastFlag("LuobuDevPublishLuaTempOptIn")

local DEFAULT_SCROLLBAR_THICKNESS = 8
local DEFAULT_SCROLLBAR_PADDING = 2

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local StyledScrollingFrame = Roact.PureComponent:extend("StyledScrollingFrame")

function StyledScrollingFrame:init()
	self.onScroll = function(rbx)
		if self.props.OnScroll then
			self.props.OnScroll(rbx.CanvasPosition)
		end
	end
end

function StyledScrollingFrame:render()
	return withTheme(function(theme)
		local props = self.props
		local scrollTheme = theme.scrollingFrame

		local position = props.Position
		local size = props.Size
		local canvasSize = props.CanvasSize
		local autoCanvasSize = (FFlagLuobuDevPublishLua or FFlagLuobuDevPublishLuaTempOptIn) and props.AutomaticCanvasSize or nil
		local layoutOrder = props.LayoutOrder
		local zindex = props.ZIndex
		local scrollingEnabled = props.ScrollingEnabled
		local padding = props.ScrollBarPadding or DEFAULT_SCROLLBAR_PADDING
		local scrollBarThickness = props.ScrollBarThickness or DEFAULT_SCROLLBAR_THICKNESS

		local backgroundThickness = scrollBarThickness + (padding * 2)
		local backgroundColor = props.BackgroundColor

		local ref = props[Roact.Ref]
		local children = props[Roact.Children]

		return Roact.createElement("Frame", {
			Position = position,
			Size = size,
			LayoutOrder = layoutOrder,
			ZIndex = zindex,
			BackgroundTransparency = backgroundColor and 0 or 1,
			BackgroundColor3 = backgroundColor,
			BorderColor3 = backgroundColor,
		}, {
			ScrollBarBackground = Roact.createElement("Frame", {
				Position = UDim2.new(1, 0, 0, 0),
				Size = UDim2.new(0, backgroundThickness, 1, 0),
				AnchorPoint = Vector2.new(1, 0),
				BorderSizePixel = 0,
				BackgroundColor3 = scrollTheme.backgroundColor,
				ZIndex = 2,
			}),

			ScrollingFrame = Roact.createElement("ScrollingFrame", {
				Size = UDim2.new(1, -padding, 1, 0),
				CanvasSize = canvasSize,
				AutomaticCanvasSize = autoCanvasSize,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = scrollBarThickness,
				ZIndex = 2,

				TopImage = scrollTheme.topImage,
				MidImage = scrollTheme.midImage,
				BottomImage = scrollTheme.bottomImage,

				ScrollBarImageColor3 = scrollTheme.scrollbarColor,

				ScrollingEnabled = scrollingEnabled,
				ScrollingDirection = Enum.ScrollingDirection.Y,

				[Roact.Change.CanvasPosition] = self.onScroll,
				[Roact.Ref] = ref,
			}, children),
		})
	end)
end

return StyledScrollingFrame
