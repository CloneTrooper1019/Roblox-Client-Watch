--[[
	Generic component that acts as a container frame with a swizzle control (arrow button) at the top, next to title label.
	Children of this component would become visible/invisible based on if swizzle view is in an expanded/collapsed state.

	Required Props:
		string Title: text to display at top of container, next to arrow
		number LayoutOrder: sort order of frame when in a layout
	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		boolean IsSubsection: if this is a subsection of another swizzle view
		boolean StayOpen: if this swizzle view can be collapsed
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local DoubleClickDetector = require(Plugin.Src.Components.DoubleClickDetector)

local SwizzleView = Roact.PureComponent:extend("SwizzleView")

local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(SwizzleView, script)

function SwizzleView:init()
	self.state = {
		expanded = true,
	}

	self.onSwizzleClick = function()
		self:setState({
			expanded = not self.state.expanded,
		})
	end
end

function SwizzleView:render()
	local props = self.props
	local state = self.state

	local title = props.Title
	local isSubsection = self.props.IsSubsection
	local layoutOrder = props.LayoutOrder
	local stayOpen = props.StayOpen
	local theme = props.Stylizer

	local children = props[Roact.Children]
	if children then
		children["UIListLayout"] = Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, theme.MainPadding),
		})
	end

	local expanded = state.expanded

	local arrowPadding = not stayOpen and theme.Arrows.Collapsed.Size.X.Offset or 0

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, theme.TopBarHeight),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = layoutOrder,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		TopBar = Roact.createElement("Frame", {
			BackgroundColor3 = isSubsection and theme.BackgroundColor or theme.RibbonTab,
			BorderColor3 = theme.BorderColor,
			BorderMode = Enum.BorderMode.Inset,
			BorderSizePixel = 1,
			Size = UDim2.new(1, 0, 0, theme.TopBarHeight),
			LayoutOrder = 1,
		}, {
			DoubleClickDetector = Roact.createElement(DoubleClickDetector, {
				onDoubleClickSuccess = self.onSwizzleClick,
			}, {
				Swizzle = not stayOpen and Roact.createElement("ImageButton", {
					Image = expanded and theme.Arrows.Expanded.Image or theme.Arrows.Collapsed.Image,
					ImageColor3 = theme.ImageColor,
					Size = expanded and theme.Arrows.Expanded.Size or theme.Arrows.Collapsed.Size,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0, theme.TopBarPadding, 0.5, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					[Roact.Event.MouseButton1Click] = self.onSwizzleClick,
				}),

				Title = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Font = theme.Font,
					TextSize = theme.TextSize,
					TextColor3 = theme.TopBarTextColor,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					Size = UDim2.new(1, -arrowPadding - theme.TopBarPadding, 0, theme.TopBarHeight),
					Position = UDim2.new(0, arrowPadding + theme.TopBarPadding, 0, 0),
					Text = title,
				}),
			}),
		}),

		ViewArea = expanded and Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, children)
	})
end

ContextServices.mapToProps(SwizzleView,{
	Stylizer = ContextServices.Stylizer,
})

return SwizzleView