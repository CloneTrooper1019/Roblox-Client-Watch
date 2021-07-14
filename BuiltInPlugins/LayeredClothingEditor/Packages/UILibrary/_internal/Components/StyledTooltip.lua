--[[
	An element which can be added to a component to give that component a tooltip.
	When the user hovers the mouse over the component, the tooltip will appear
	after a short delay.

	Required Props:
        table Elements = The table containing roact elements to display in the tooltip.
		Vector2 TooltipExtents = vector containing tooltip size
		bool Enabled = Whether the tooltip will display on hover.

	Optional Props:
		float ShowDelay = The time in seconds before the tooltip appears
			after the user stops moving the mouse over the element. Defaults to 0.5.
		int Priority = The display order of this element, compared to other focused
			elements or elements that show on top.
]]

local SHOW_DELAY_DEFAULT = 0.5

local RunService = game:GetService("RunService")

local Library = script.Parent.Parent
local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local Focus = require(Library.Focus)
local ShowOnTop = Focus.ShowOnTop
local withFocus = Focus.withFocus

local DropShadow = require(Library.Components.DropShadow)

local Tooltip = Roact.PureComponent:extend("Tooltip")

function Tooltip:init(props)
	self.state = {
		showToolTip = false,
	}

    self.isElementHovered = false
    self.isTooltipHovered = false
	self.mousePos = nil

	self.connectHover = function()
		self.hoverConnection = RunService.Heartbeat:Connect(function()
			if self.isElementHovered or self.isTooltipHovered then
				if tick() >= self.targetTime then
					self.disconnectHover()
					self:setState({
						showToolTip = true,
					})
				end
			end
		end)
	end

	self.disconnectHover = function()
		if self.hoverConnection then
			self.hoverConnection:Disconnect()
		end
	end

	self.elementMouseEnter = function(rbx, xpos, ypos)
		local showDelay = props.ShowDelay or SHOW_DELAY_DEFAULT
		self.isElementHovered = true
		self.targetTime = tick() + showDelay
		if not self.mousePos then
			self.mousePos = Vector2.new(xpos, ypos)
		end
		self.connectHover()
	end

	self.elementMouseMoved = function(rbx, xpos, ypos)
		local showDelay = props.ShowDelay or SHOW_DELAY_DEFAULT
		self.targetTime = tick() + showDelay
	end

	self.elementMouseLeave = function()
		self.isElementHovered = false
		local hovered = self.isElementHovered or self.isTooltipHovered
		self:setState({
			showToolTip = hovered,
		})
		if not hovered then
			self.targetTime = 0
			self.mousePos = nil
			self.disconnectHover()
		end
    end

	self.tooltipMouseEnter = function(rbx, xpos, ypos)
		self.isTooltipHovered = true
	end

	self.tooltipMouseMoved = function(rbx, xpos, ypos)
		local showDelay = props.ShowDelay or SHOW_DELAY_DEFAULT
		self.targetTime = tick() + showDelay
	end

	self.tooltipMouseLeave = function()
		self.isTooltipHovered = false
		local hovered = self.isElementHovered or self.isTooltipHovered
		self:setState({
			showToolTip = hovered,
		})
		if not hovered then
			self.targetTime = 0
			self.mousePos = nil
			self.disconnectHover()
		end
	end
end

function Tooltip:willUnmount()
	self.disconnectHover()
end

function Tooltip:render()
	return withTheme(function(theme)
		return withFocus(function(pluginGui)
			local props = self.props
			local state = self.state

			local styledTooltipTheme = theme.styledTooltip

			local enabled = props.Enabled
			local priority = props.Priority or 0

            local mousePos = self.mousePos

            local elements = props.Elements
            local tooltipWidth = props.TooltipExtents and props.TooltipExtents.X
            local tooltipHeight = props.TooltipExtents and props.TooltipExtents.Y

			local content = {}

			if state.showToolTip and mousePos and enabled and pluginGui then
				local targetX = mousePos.X
				local targetY = mousePos.Y

				local targetWidth = pluginGui.AbsoluteSize.X
				local targetHeight = pluginGui.AbsoluteSize.Y


				if targetX + tooltipWidth >= targetWidth then
					targetX = targetWidth - tooltipWidth
				end

				if targetY + tooltipHeight >= targetHeight then
					targetY = targetHeight - tooltipHeight
				end

				content.TooltipContainer = Roact.createElement(ShowOnTop, {
					Priority = priority,
				}, {
					Tooltip = Roact.createElement("Frame", {
						Position = UDim2.new(0, targetX, 0, targetY),
						Size = UDim2.new(0, tooltipWidth, 0, tooltipHeight),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,

                        [Roact.Event.MouseEnter] = self.tooltipMouseEnter,
                        [Roact.Event.MouseMoved] = self.tooltipMouseMoved,
                        [Roact.Event.MouseLeave] = self.tooltipMouseLeave,
					}, {
						DropShadow = Roact.createElement(DropShadow, {
							Transparency = styledTooltipTheme.shadowTransparency,
							Color = styledTooltipTheme.shadowColor,
							Offset = styledTooltipTheme.shadowOffset,
							ZIndex = 1,
						}),

						ContentFrame = Roact.createElement("Frame", {
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundColor3 = styledTooltipTheme.backgroundColor,
							BorderSizePixel = 0,
							ZIndex = 2,
						}, elements),
					})
				})
			end

			return Roact.createElement("Frame",{
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,

				[Roact.Event.MouseEnter] = self.elementMouseEnter,
				[Roact.Event.MouseMoved] = self.elementMouseMoved,
				[Roact.Event.MouseLeave] = self.elementMouseLeave,
			}, content)
		end)
	end)
end

return Tooltip
