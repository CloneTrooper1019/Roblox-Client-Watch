local StudioService = game:GetService("StudioService")

local DraggerFramework = script.Parent.Parent

local Library = DraggerFramework.Parent.Parent
local Roact = require(Library.Packages.Roact)

-- How much space between the note and the window edge
local EDGE_PADDING = 2

local FRAME_PADDING = 3
local TEXT_MARGIN = 2

local SummonHandlesNote = Roact.PureComponent:extend("SummonHandlesNote")

function SummonHandlesNote:didMount()
	self.localeChangedConnection = self.props.DraggerContext.LocaleChangedSignal:Connect(function()
		self:setState({})
	end)
end

function SimplePadding(props)
	return Roact.createElement("UIPadding", {
		PaddingBottom = UDim.new(0, props.Padding),
		PaddingRight = UDim.new(0, props.Padding),
		PaddingLeft = UDim.new(0, props.Padding),
		PaddingTop = UDim.new(0, props.Padding),
	})
end

function SummonHandlesNote:render()
	local props = self.props
	if props.InView then
		return
	end
	
	local viewportSize = props.DraggerContext:getViewportSize()

	local background = props.DraggerContext:getThemeColor(Enum.StudioStyleGuideColor.Tooltip)
	local border = props.DraggerContext:getThemeColor(Enum.StudioStyleGuideColor.Border)
	local foreground = props.DraggerContext:getThemeColor(Enum.StudioStyleGuideColor.MainText)
	local tabBubble = props.DraggerContext:getThemeColor(Enum.StudioStyleGuideColor.DimmedText)

	return Roact.createElement(Roact.Portal, {
		target = props.DraggerContext:getGuiParent(),
	}, {
		SummonHandlesNoteGui = Roact.createElement("ScreenGui", {}, {
			Frame = Roact.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = background,
				BorderColor3 = border,
				Position = UDim2.new(0, viewportSize.X / 2, 0, EDGE_PADDING),
			}, {
				Padding = Roact.createElement(SimplePadding, {Padding = FRAME_PADDING}),
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, FRAME_PADDING),
				}),
				Tab = Roact.createElement("TextLabel", {
					Text = props.DraggerContext:getText("SummonPivot", "TabText"),
					TextColor3 = foreground,
					BackgroundColor3 = tabBubble,
					AutomaticSize = Enum.AutomaticSize.XY,
					LayoutOrder = 1,
				}, {
					Padding = Roact.createElement(SimplePadding, {Padding = TEXT_MARGIN}),
					Corner = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 4),
					}),
				}),
				Text = Roact.createElement("TextLabel", {
					Text = props.DraggerContext:getText("SummonPivot", "SummonText"),
					TextColor3 = foreground,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					LayoutOrder = 2,
				}, {
					Padding = Roact.createElement(SimplePadding, {Padding = TEXT_MARGIN}),
				})
			})
		})
	})
end

function SummonHandlesNote:willUnmount()
	self.localeChangedConnection:Disconnect()
end

return SummonHandlesNote