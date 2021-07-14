--[[
	An element which can be added to a component to give that component a tooltip.
	When the user hovers the mouse over the component, the tooltip will appear
	after a short delay.

	If the component is rendered using AutomaticSize, add it as a child of the tooltip instead
	and the tooltip will act as an automatically-sized container for the child.

	Required Props:
		Focus Focus: A Focus ContextItem, which is provided via mapToProps.
		string Text: The text to display in the tooltip.

	Optional Props:
		table Child: An optional Roact element which should be displayed
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		boolean Enabled: Whether the tooltip will display on hover.
		number MaxWidth: The maximum width of this tooltip
		Enum.TextXAlignment TextXAlignment: The text X alignment of this tooltip.
		integer Priority: The display order of this element, compared to other focused
			elements or elements that show on top.

	Style Values:
		integer Padding: The padding of the box in pixels.
		number MaxWidth: The maximum width of this tooltip. The tooltip will never
			grow beyond the width of the containing PluginGui.
		number ShowDelay: The time in seconds before the tooltip appears
			after the user stops moving the mouse over the element.
]]

local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local ShowOnTop = require(Framework.UI.ShowOnTop)
local DropShadow = require(Framework.UI.DropShadow)
local Box = require(Framework.UI.Box)
local TextLabel = require(Framework.UI.TextLabel)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local Tooltip = Roact.PureComponent:extend("Tooltip")
Typecheck.wrap(Tooltip, script)

Tooltip.defaultProps = {
	Enabled = true,
	Priority = 0
}

function Tooltip:init(props)
	self.state = {
		showTooltip = false,
	}
	self.hoverConnection = nil
	self.mousePosition = nil

	self.mouseEnter = function(rbx, xpos, ypos)
		self.targetTime = tick() + self:getShowDelay()
		self.mousePosition = Vector2.new(xpos, ypos)
		self:connectHover()
	end

	self.mouseMoved = function(rbx, xpos, ypos)
		self.mousePosition = Vector2.new(xpos, ypos)
		self.targetTime = tick() + self:getShowDelay()
	end

	self.mouseLeave = function()
		self.targetTime = 0
		self.mousePosition = nil
		self:disconnectHover()
		self:setState({
			showTooltip = false,
		})
	end
end

function Tooltip:getShowDelay()
	local theme = self.props.Theme

	local style
	if THEME_REFACTOR then
		style = self.props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	return style.ShowDelay
end

function Tooltip:connectHover()
	self:disconnectHover()
	self.hoverConnection = RunService.Heartbeat:Connect(function()
		if tick() >= self.targetTime then
			self:disconnectHover()
			self:setState({
				showTooltip = true,
			})
		end
	end)
end

function Tooltip:disconnectHover()
	if self.hoverConnection then
		self.hoverConnection:Disconnect()
		self.hoverConnection = nil
	end
end

function Tooltip:willUnmount()
	self:disconnectHover()
end

function Tooltip:render()
	local props = self.props
	local state = self.state

	local theme = props.Theme

	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local padding = style.Padding
	local dropShadowPadding = style.DropShadow and style.DropShadow.Radius or 0
	local offset = style.Offset
	local maxWidth = props.MaxWidth or style.MaxWidth

	local text = props.Text
	local enabled = props.Enabled
	local priority = props.Priority

	local mousePosition = self.mousePosition

	local content = {
		Child = props.Child or nil
	}

	local pluginGui = props.Focus.target

	if state.showTooltip and mousePosition and enabled and pluginGui then
		local targetX = mousePosition.X + offset.X
		local targetY = mousePosition.Y + offset.Y

		local pluginGuiWidth = pluginGui.AbsoluteSize.X
		local pluginGuiHeight = pluginGui.AbsoluteSize.Y

		local paddingSize = (dropShadowPadding + padding) * 2

		local maxRequestedWidth = math.min(pluginGuiWidth, maxWidth)
		local maxAvailableWidth = math.max(0, maxRequestedWidth - paddingSize)

		local textBound = TextService:GetTextSize(text,
			style.TextSize, style.Font, Vector2.new(maxAvailableWidth, math.huge))

		-- GetTextSize calculates a float value and then rounds it down before returning
		local tooltipTargetWidth = textBound.X + paddingSize + 1
		local tooltipTargetHeight = textBound.Y + paddingSize + 1

		if targetX + tooltipTargetWidth >= pluginGuiWidth then
			targetX = pluginGuiWidth - tooltipTargetWidth
		end

		if targetY + tooltipTargetHeight >= pluginGuiHeight then
			targetY = pluginGuiHeight - tooltipTargetHeight
		end

		content.TooltipContainer = Roact.createElement(ShowOnTop, {
			Priority = priority,
		}, {
			Tooltip = Roact.createElement("Frame", {
				Position = UDim2.new(0, targetX, 0, targetY),
				Size = UDim2.new(0, tooltipTargetWidth, 0, tooltipTargetHeight),
				BackgroundTransparency = 1
			}, {
				DropShadow = Roact.createElement(DropShadow, {
					Style = style.DropShadow
				}, {
					ContentFrame = Roact.createElement(Box, {}, {
						Padding = Roact.createElement("UIPadding", {
							PaddingTop = UDim.new(0, padding),
							PaddingBottom = UDim.new(0, padding),
							PaddingLeft = UDim.new(0, padding),
							PaddingRight = UDim.new(0, padding),
						}),
						Label = Roact.createElement(TextLabel, {
							Size = UDim2.new(1, 0, 1, 0),
							Text = text,
							TextWrapped = true,
							TextXAlignment = props.TextXAlignment,
						})
					}),
				})
			})
		})
	end

	return Roact.createElement("Frame", {
		Size = props.Child and UDim2.fromScale(0, 0) or UDim2.fromScale(1, 1),
		AutomaticSize = props.Child and Enum.AutomaticSize.XY or nil,
		BackgroundTransparency = 1,
		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseMoved] = self.mouseMoved,
		[Roact.Event.MouseLeave] = self.mouseLeave,
	}, content)
end

ContextServices.mapToProps(Tooltip, {
	Focus = ContextServices.Focus,
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return Tooltip
