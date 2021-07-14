--[[
	An element which can be added to a component to give that component a tooltip.
	When the user hovers the mouse over the component, the tooltip will appear
	after a short delay.

	Props:
		string Text = The text to display in the tooltip.
		float ShowDelay = The time in seconds before the tooltip appears
			after the user stops moving the mouse over the element. Defaults to 0.5.
		bool Enabled = Whether the tooltip will display on hover.
		int Priority = The display order of this element, compared to other focused
			elements or elements that show on top.
]]

local PADDING = 3
local SHADOW_OFFSET = Vector2.new(3, 3)
local OFFSET = Vector2.new(10, 5)
local SHOW_DELAY_DEFAULT = 0.5

local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

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
	local showDelay = props.ShowDelay or SHOW_DELAY_DEFAULT

	self.state = {
		showToolTip = false,
	}

	self.isHovered = false
	self.mousePos = nil

	self.connectHover = function()
		self.hoverConnection = RunService.Heartbeat:Connect(function()
			if self.isHovered then
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

	self.mouseEnter = function(rbx, xpos, ypos)
		self.isHovered = true
		self.targetTime = tick() + showDelay
		self.mousePos = Vector2.new(xpos, ypos)
		self.connectHover()
	end

	self.mouseMoved = function(rbx, xpos, ypos)
		self.mousePos = Vector2.new(xpos, ypos)
		self.targetTime = tick() + showDelay
	end

	self.mouseLeave = function()
		self.isHovered = false
		self.targetTime = 0
		self.mousePos = nil
		self.disconnectHover()
		self:setState({
			showToolTip = false,
		})
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

			local tooltipTheme = theme.tooltip
			local textSize = tooltipTheme.textSize

			local text = props.Text
			local enabled = props.Enabled
			local priority = props.Priority or 0

			local mousePos = self.mousePos

			local content = {}

			if state.showToolTip and mousePos and enabled and pluginGui then
				local targetX = mousePos.X + OFFSET.X
				local targetY = mousePos.Y + OFFSET.Y

				local targetWidth = pluginGui.AbsoluteSize.X
				local targetHeight = pluginGui.AbsoluteSize.Y

				local textBound = TextService:GetTextSize(text,
					textSize, tooltipTheme.font, Vector2.new(100, 9000))

				local tooltipTargetWidth = textBound.X + 2 * PADDING
				local tooltipTargetHeight = textBound.Y + 2 * PADDING

				if targetX + tooltipTargetWidth >= targetWidth then
					targetX = targetWidth - tooltipTargetWidth
				end

				if targetY + tooltipTargetHeight >= targetHeight then
					targetY = targetHeight - tooltipTargetHeight
				end

				content.TooltipContainer = Roact.createElement(ShowOnTop, {
					Priority = priority,
				}, {
					Tooltip = Roact.createElement("Frame", {
						Position = UDim2.new(0, targetX, 0, targetY),
						Size = UDim2.new(0, tooltipTargetWidth, 0, tooltipTargetHeight),
						BackgroundTransparency = 1,
						ZIndex = 10,
					}, {
						DropShadow = Roact.createElement(DropShadow, {
							Transparency = tooltipTheme.shadowTransparency,
							Color = tooltipTheme.shadowColor,
							Offset = SHADOW_OFFSET,
							ZIndex = 1,
						}),

						ContentFrame = Roact.createElement("Frame", {
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 2,

							BackgroundColor3 = tooltipTheme.backgroundColor,
							BorderColor3 = tooltipTheme.borderColor,
						}, {
							UIPadding = Roact.createElement("UIPadding", {
								PaddingBottom = UDim.new(0, PADDING),
								PaddingLeft = UDim.new(0, PADDING),
								PaddingRight = UDim.new(0, PADDING),
								PaddingTop = UDim.new(0, PADDING),
							}),

							Label = Roact.createElement("TextLabel", {
								Size = UDim2.new(1, 0, 1, 0),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								Text = text,

								TextColor3 = tooltipTheme.textColor,

								Font = tooltipTheme.font,
								TextSize = textSize,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextYAlignment = Enum.TextYAlignment.Top,
								TextWrapped = true,
								ZIndex = 3,
							}),
						})
					})
				})
			end

			return Roact.createElement("Frame",{
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,

				[Roact.Event.MouseEnter] = self.mouseEnter,
				[Roact.Event.MouseMoved] = self.mouseMoved,
				[Roact.Event.MouseLeave] = self.mouseLeave,
			}, content)
		end)
	end)
end

return Tooltip
