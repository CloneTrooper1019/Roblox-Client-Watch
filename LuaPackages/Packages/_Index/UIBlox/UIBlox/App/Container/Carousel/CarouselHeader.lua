local Carousel = script.Parent
local Container = Carousel.Parent
local App = Container.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local t = require(Packages.t)
local withStyle = require(UIBlox.Core.Style.withStyle)

local GetTextSize = require(UIBlox.Core.Text.GetTextSize)

local IconSize = require(App.ImageSet.Enum.IconSize)
local getIconSize = require(App.ImageSet.getIconSize)
local Images = require(App.ImageSet.Images)

local Core = UIBlox.Core
local Interactable = require(Core.Control.Interactable)
local GenericTextLabel = require(Core.Text.GenericTextLabel.GenericTextLabel)
local ImageSetComponent = require(Core.ImageSet.ImageSetComponent)

local MAX_BOUND = 10000
local SEE_ALL_ARROW = Images["icons/navigation/pushRight_small"]
local TEXT_ICON_PADDING = 4

local CarouselHeader = Roact.PureComponent:extend("CarouselHeader")

CarouselHeader.validateProps = t.strictInterface({
	-- The header text for the carousel
	headerText = t.optional(t.string),

	-- The callback for the see all arrow. if nil, the arrow won't be shown
	onSeeAll = t.optional(t.callback),

	-- The carousel left margin
	carouselMargin = t.optional(t.number),

	-- The layout order
	layoutOrder = t.optional(t.number),
})

CarouselHeader.defaultProps = {
	headerText = "",
	carouselMargin = 0,
}

function CarouselHeader:render()
	local headerText = self.props.headerText
	local onSeeAll = self.props.onSeeAll

	local layoutOrder = self.props.layoutOrder
	local carouselMargin = self.props.carouselMargin

	return withStyle(function(style)
		local fontStyle = style.Font.Header1
		local baseSize = style.Font.BaseSize
		local fontSize = fontStyle.RelativeSize * baseSize
		local textFont = fontStyle.Font

		local textboxBounds = GetTextSize(headerText, fontSize, textFont, Vector2.new(MAX_BOUND, MAX_BOUND))
		local textboxSize = UDim2.fromOffset(textboxBounds.X + TEXT_ICON_PADDING + getIconSize(IconSize.Small),
		 textboxBounds.Y)

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, textboxBounds.Y),
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
		}, {
			CarouselHeaderButton = Roact.createElement(Interactable, {
				Position = UDim2.fromOffset(carouselMargin, 0),
				Size = textboxSize,
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				[Roact.Event.Activated] = onSeeAll,
				--Note State change is not being used right now.
				onStateChanged = function()end,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, TEXT_ICON_PADDING),
				}),
				HeaderText = Roact.createElement(GenericTextLabel, {
					Text = headerText,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					LayoutOrder = 1,
					fontStyle = fontStyle,
					colorStyle = style.Theme.TextEmphasis,
				}),
				SeeAllArrow = onSeeAll and Roact.createElement(ImageSetComponent.Label, {
					Size = UDim2.fromOffset(getIconSize(IconSize.Small), getIconSize(IconSize.Small)),
					BackgroundTransparency = 1,
					Image = SEE_ALL_ARROW,
					ImageColor3 = style.Theme.TextEmphasis.Color,
					ImageTransparency = style.Theme.TextEmphasis.Transparency,
					LayoutOrder = 2,
				}) or nil,
			})
		})
	end)
end

return CarouselHeader
