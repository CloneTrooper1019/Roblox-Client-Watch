local TooltipRoot = script.Parent
local DialogRoot = TooltipRoot.Parent
local AppRoot = DialogRoot.Parent
local UIBlox = AppRoot.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local t = require(Packages.t)
local Otter = require(Packages.Otter)

local withStyle = require(UIBlox.Core.Style.withStyle)
local Images = require(AppRoot.ImageSet.Images)
local ImageSetLabel = require(UIBlox.Core.ImageSet.ImageSetComponent).Label
local GenericTextLabel = require(UIBlox.Core.Text.GenericTextLabel.GenericTextLabel)
local GetTextSize = require(UIBlox.Core.Text.GetTextSize)
local GetTextHeight = require(UIBlox.Core.Text.GetTextHeight)

local UIBloxConfig = require(UIBlox.UIBloxConfig)

local enumerateValidator = require(UIBlox.Utility.enumerateValidator)
local divideTransparency = require(UIBlox.Utility.divideTransparency)
local lerp = require(UIBlox.Utility.lerp)

local TooltipOrientation = require(TooltipRoot.Enum.TooltipOrientation)
local getPositionInfo = require(TooltipRoot.getPositionInfo)

local FRAME_MAX_WIDTH = 240
local MARGIN = 12
local PADDING_BETWEEN = 4
local TRIANGLE_HEIGHT = 8

local TriangleImages = {
	[TooltipOrientation.Bottom] = Images["component_assets/triangleUp_16"],
	[TooltipOrientation.Top] = Images["component_assets/triangleDown_16"],
	[TooltipOrientation.Right] = Images["component_assets/triangleLeft_16"],
	[TooltipOrientation.Left] = Images["component_assets/triangleRight_16"],
}

local MOTOR_OPTIONS = {
	frequency = 50,
	dampingRatio = 1,
}

local TooltipContainer = Roact.PureComponent:extend("TooltipContainer")

TooltipContainer.validateProps = t.strictInterface({
	triggerPosition = t.Vector2,
	triggerSize = t.Vector2,
	bodyText = t.string,
	headerText = t.optional(t.string),
	screenSize = t.optional(t.Vector2), --the app screen size
	position = t.optional(t.UDim2),
	orientation = t.optional(enumerateValidator(TooltipOrientation)),
	isDirectChild = t.optional(t.boolean),
})

TooltipContainer.defaultProps = {
	screenSize = Vector2.new(10000, 10000),
	orientation = TooltipOrientation.Bottom,
	isDirectChild = false,
}

function TooltipContainer:init()
	self.visible = true

	local setProgress
	self.progress, setProgress = Roact.createBinding(0)

	self.progressMotor = Otter.createSingleMotor(0)
	self.progressMotor:onStep(setProgress)
	self.progressMotor:setGoal(Otter.spring(1, MOTOR_OPTIONS))
end

function TooltipContainer:render()
	return withStyle(function(stylePalette)
		local font = stylePalette.Font
		local theme = stylePalette.Theme

		local headerFont = font.CaptionHeader
		local bodyFont = font.CaptionBody

		local fontSize = font.BaseSize * font.CaptionBody.RelativeSize

		local bodyTextWidth = GetTextSize(self.props.bodyText, fontSize, bodyFont.Font, Vector2.new()).X
		if UIBloxConfig.tooltipWidthUsesHeaderToo and self.props.headerText then
			local headerTextWidth = GetTextSize(
				self.props.headerText,
				font.BaseSize * headerFont.RelativeSize,
				headerFont.Font,
				Vector2.new()
			).X
			bodyTextWidth = math.max(bodyTextWidth, headerTextWidth)
		end
		local innerWidth = math.min(bodyTextWidth, FRAME_MAX_WIDTH - 2 * MARGIN)
		local frameWidth = innerWidth + 2 * MARGIN

		local bodyTextHeight = GetTextHeight(self.props.bodyText, bodyFont.Font, fontSize, innerWidth)
		local headerTextHeight = self.props.headerText
			and GetTextHeight(self.props.headerText, headerFont.Font, fontSize, innerWidth)
			or 0

		local frameHeight = self.props.headerText
			and headerTextHeight + bodyTextHeight + MARGIN * 2 + PADDING_BETWEEN
			or bodyTextHeight + MARGIN * 2

		local positionInfo = getPositionInfo(
			frameWidth,
			frameHeight,
			self.props.orientation,
			self.props.triggerPosition,
			self.props.triggerSize,
			self.props.screenSize,
			self.props.position)

		local containerPosition = self.progress:map(function(value)
			local startPosition
			if self.props.position then
				startPosition = self.props.position
			else
				startPosition = self.props.isDirectChild and positionInfo.position or positionInfo.absolutePosition
			end
			local endPosition = startPosition + positionInfo.animatedDistance
			return startPosition:lerp(endPosition, value)
		end)

		local backgroundTransparency = self.progress:map(function(value)
			local baseTransparency = theme.BackgroundMuted.Transparency
			local transparencyDivisor = 1
			return lerp(1, divideTransparency(baseTransparency, transparencyDivisor), value)
		end)

		local textTransparency = self.progress:map(function(value)
			local baseTransparency = theme.TextEmphasis.Transparency
			local transparencyDivisor = 2
			return lerp(1, divideTransparency(baseTransparency, transparencyDivisor), value)
		end)

		return Roact.createElement("Frame", {
			Visible = self.visible,
			Position = containerPosition,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = positionInfo.fillDirection == Enum.FillDirection.Vertical
				and UDim2.fromOffset(frameWidth, frameHeight + TRIANGLE_HEIGHT)
				or UDim2.fromOffset(frameWidth + TRIANGLE_HEIGHT, frameHeight),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = positionInfo.fillDirection,
			}),
			CaretFrame = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = positionInfo.caretFrameSize,
				LayoutOrder = positionInfo.caretLayoutOrder,
			}, {
				Caret = Roact.createElement(ImageSetLabel, {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = positionInfo.caretPosition,
					AnchorPoint = positionInfo.caretAnchorPoint,
					Size = positionInfo.caretImageSize,
					Image = TriangleImages[positionInfo.updatedOrientation],
					ImageColor3 = theme.BackgroundMuted.Color,
					ImageTransparency = backgroundTransparency,
					[Roact.Ref] = self.caretRef,
				}),
			}),
			Content = Roact.createElement("TextButton", {
				AutoButtonColor = false,
				Text = "",
				Size = UDim2.fromOffset(frameWidth, frameHeight),
				BackgroundColor3 = theme.BackgroundMuted.Color,
				BackgroundTransparency = backgroundTransparency,
				BorderSizePixel = 0,
				LayoutOrder = positionInfo.contentLayoutOrder,
			}, {
				VerticalLayout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, PADDING_BETWEEN),
					VerticalAlignment = Enum.VerticalAlignment.Center
				}),
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, MARGIN),
					PaddingBottom = UDim.new(0, MARGIN),
					PaddingLeft = UDim.new(0, MARGIN),
					PaddingRight = UDim.new(0, MARGIN),
				}),
				Header = self.props.headerText and Roact.createElement(GenericTextLabel, {
					colorStyle = theme.TextEmphasis,
					fontStyle = headerFont,
					LayoutOrder = 1,
					Text = self.props.headerText,
					TextTransparency = textTransparency,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, 0, 0, headerTextHeight),
				}),
				Body = Roact.createElement(GenericTextLabel, {
					colorStyle = theme.TextDefault,
					fontStyle = bodyFont,
					LayoutOrder = 2,
					Text = self.props.bodyText,
					TextTransparency = textTransparency,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, 0, 0, bodyTextHeight),
				}),
			}),
		})
	end)
end

function TooltipContainer:didMount()
	self.progressMotor:start()
end

function TooltipContainer:didUpdate(lastProps, lastState)
	if lastProps.triggerPosition ~= self.props.triggerPosition then
		if self.props.triggerPosition.Y < 0
			or self.props.triggerPosition.Y + self.props.triggerSize.Y > self.props.screenSize.Y
		then
			self.visible = false
		else
			self.visible = true
		end
	end
end

function TooltipContainer:willUnmount()
	self.progressMotor:destroy()
	self.progressMotor = nil
end

return TooltipContainer
