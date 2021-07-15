local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local Background = require(Plugin.Core.Types.Background)

local withTheme = ContextHelper.withTheme

local BackgroundIcon = require(Plugin.Core.Components.Footer.BackgroundIcon)
local RoundButton = require(Plugin.Core.Components.RoundButton)

local FooterButton = Roact.PureComponent:extend("FooterButton")

function FooterButton:init(props)
	self.onMouseEnter = function(rbx, x, y)
		props.onHoverStarted(props.index)
	end

	self.onMouseLeave = function(rbx, x, y)
		props.onHoverEnded(props.index)
	end

	self.onMouseButton1Down = function(rbx, x, y)
		props.onClick(props.index)
	end
end

function FooterButton:render()
	return withTheme(function(theme)
		local props = self.props

		local index = props.index
		local name = props.name

		local isSelected = props.isSelected
		local isHovered = props.isHovered

		local footerTheme = theme.footer
		local buttonTheme = footerTheme.button

		local textWidth = props.textWidth or 0

		local externalPadding = 6
		local internalPadding = 4
		local iconSize = Constants.BACKGROUND_BUTTON_ICON_SIZE

		local width = externalPadding + iconSize + internalPadding + textWidth + externalPadding

		local icon = Roact.createElement(BackgroundIcon, {
			backgroundIndex = index,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, iconSize, 0, iconSize),
			LayoutOrder = 1,
		})

		return Roact.createElement(RoundButton, {
			AnchorPoint = Vector2.new(0, 0.5),
			LayoutOrder = index,
			Size = UDim2.new(0, width, 1, 0),

			BackgroundColor3 = isSelected and buttonTheme.backgroundSelectedColor or buttonTheme.backgroundColor,
			BorderColor3 = (isSelected or isHovered) and buttonTheme.borderSelectedColor or buttonTheme.borderColor,

			[Roact.Event.MouseEnter] = self.onMouseEnter,
			[Roact.Event.MouseLeave] = self.onMouseLeave,
			[Roact.Event.MouseButton1Down] = self.onMouseButton1Down,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, externalPadding),
				PaddingLeft = UDim.new(0, externalPadding),
				PaddingRight = UDim.new(0, externalPadding),
				PaddingTop = UDim.new(0, externalPadding),
			}),

			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, internalPadding),
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Icon = icon,

			TextLabel = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = nil,
				Size = UDim2.new(0, textWidth, 1, -1),

				TextColor3 = isSelected and buttonTheme.textSelectedColor or buttonTheme.textColor,

				Font = Constants.FONT,
				Text = name,
				TextSize = Constants.BACKGROUND_BUTTON_FONT_SIZE,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				LayoutOrder = 2,
			}),
		})
	end)
end

return FooterButton
