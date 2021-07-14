--[[
	A simple tab component with optional image, label & tooltip.
	Can render hovered, selected or disabled.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local TabsTypes = require(Framework.UI.Tabs.types)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local withAbsoluteSize = require(Framework.Wrappers.withAbsoluteSize)
local withControl = require(Framework.Wrappers.withControl)

local Dash = require(Framework.packages.Dash)
local assign = Dash.assign

local UI = Framework.UI
local Pane = require(UI.Pane)
local Tooltip = require(UI.Tooltip)
local Image = require(UI.Image)
local TextLabel = require(UI.TextLabel)

local SimpleTab = Roact.PureComponent:extend("SimpleTab")

function SimpleTab:init()
	assert(THEME_REFACTOR, "Tabs not supported in Theme1, please upgrade your plugin to Theme2")
	self.onPress = function()
		local props = self.props
		if not props.Disabled then
			props.OnTabSelected(props.Tab)
		end
	end
end

function SimpleTab:render()
	local props: TabsTypes.ConnectedTabProps = self.props
	local style = self.props.Stylizer
	local icon = props.Tab.Icon
	local label = props.Tab.Label
	local tooltip = props.Tab.Tooltip
	local selected = props.Selected
	local color = style.Color
	local size = props.AbsoluteSize
	local bottomLineColor = style.BottomLineColor
	local lineX = 0
	local lineWidth = size.X
	if selected then
		lineX = style.BorderSize
		lineWidth -= style.BorderSize * 2
	end
	local pane = Roact.createElement(Pane, assign({
		AutomaticSize = Enum.AutomaticSize.XY,
		Style = "Box",
		LayoutOrder = props.Index,
		OnPress = self.onPress,
	}, props.WrapperProps), {
		Row = Roact.createElement(Pane, {
			Spacing = style.Spacing,
			Padding = style.Padding,
			Layout = Enum.FillDirection.Horizontal,
			BackgroundColor = style.BackgroundColor,
			BorderColor3 = style.BorderColor,
			BorderMode = Enum.BorderMode.Inset,
			BorderSizePixel = style.BorderSize,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 32),
		}, {
			Icon = icon and Roact.createElement(Image, {
				Image = icon,
				ImageColor3 = color,
				Size = UDim2.fromOffset(16, 16),
				LayoutOrder = 1,
			}),
			Label = label and Roact.createElement(TextLabel, {
				TextColor = color,
				AutomaticSize = Enum.AutomaticSize.XY,
				Text = label,
				LayoutOrder = 2,
			}),
		}),
		TopLine = selected and Roact.createElement(Pane, {
			Position = UDim2.fromOffset(style.BorderSize, 0),
			Size = UDim2.new(0, lineWidth, 0, style.TopLineHeight),
			BackgroundColor = style.TopLineColor,
			ZIndex = 2
		}),
		BottomLine = Roact.createElement(Pane, {
			Size = UDim2.new(0, lineWidth, 0, style.BorderSize),
			Position = UDim2.new(0, lineX, 0, 32),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor = bottomLineColor,
			ZIndex = 1
		}),
	})
	if tooltip then
		return Roact.createElement(Tooltip, {
			Text = tooltip,
			Child = pane
		})
	else
		return pane
	end
end

ContextServices.mapToProps(SimpleTab, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return withAbsoluteSize(withControl(SimpleTab))
