local TooltipRoot = script.Parent
local DialogRoot = TooltipRoot.Parent
local AppRoot = DialogRoot.Parent
local UIBlox = AppRoot.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)
local t = require(Packages.t)
local withStyle = require(UIBlox.Core.Style.withStyle)
local enumerateValidator = require(UIBlox.Utility.enumerateValidator)

local TooltipContainer = require(TooltipRoot.TooltipContainer)

local TooltipOrientation = require(TooltipRoot.Enum.TooltipOrientation)

local Tooltip = Roact.PureComponent:extend("Tooltip")

Tooltip.validateProps = t.strictInterface({
	triggerPosition = t.Vector2,
	triggerSize = t.Vector2,
	bodyText = t.string,
	headerText = t.optional(t.string),
	onDismiss = t.optional(t.callback),
	screenSize = t.optional(t.Vector2), --the app screen size
	position = t.optional(t.UDim2),
	orientation = t.optional(enumerateValidator(TooltipOrientation)),
	triggerOnHover = t.optional(t.boolean),
	forceClickTriggerPoint = t.optional(t.boolean),
	isDirectChild = t.optional(t.boolean),
})

Tooltip.defaultProps = {
	screenSize = Vector2.new(10000, 10000),
	orientation = TooltipOrientation.Bottom,
	triggerOnHover = false,
	forceClickTriggerPoint = false,
	isDirectChild = false,
}

function Tooltip:init()
	self.onDismissDefault = function()
		if self.props.forceClickTriggerPoint or self.props.triggerOnHover then
			return
		end
		if self.props.onDismiss then
			self.props.onDismiss()
		end
	end
end

function Tooltip:render()
	local enableTriggerMask = self.props.forceClickTriggerPoint or self.props.triggerOnHover
	local isDirectChild = self.props.isDirectChild
	return withStyle(function(stylePalette)
		local theme = stylePalette.Theme

		local tooltipComponents = {
			-- Force Click Trigger Point should not prevent the rest of the UI from being interactable
			Background = not self.props.forceClickTriggerPoint and Roact.createElement("TextButton", {
				ZIndex = 0,
				AutoButtonColor = false,
				BackgroundColor3 = theme.Overlay.Color,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = isDirectChild and UDim2.fromOffset(-self.props.triggerPosition.X, -self.props.triggerPosition.Y)
					or UDim2.fromOffset(0, 0),
				Size = UDim2.fromOffset(self.props.screenSize.X, self.props.screenSize.Y),
				Text = "",
				[Roact.Event.Activated] = self.onDismissDefault,
				[Roact.Event.TouchSwipe] = self.onDismissDefault,
				[Roact.Event.MouseWheelForward] = self.onDismissDefault,
				[Roact.Event.MouseWheelBackward] = self.onDismissDefault,
			}),
			TriggerPointMask = enableTriggerMask and Roact.createElement("TextButton", {
				Text = "",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(self.props.triggerSize.X, self.props.triggerSize.Y),
				Position = isDirectChild and UDim2.fromOffset(0, 0)
					or UDim2.fromOffset(self.props.triggerPosition.X, self.props.triggerPosition.Y),
				[Roact.Event.Activated] = self.props.onDismiss,
			}),
			TooltipContainer = Roact.createElement(TooltipContainer, {
				triggerPosition = self.props.triggerPosition,
				triggerSize = self.props.triggerSize,
				bodyText = self.props.bodyText,
				headerText = self.props.headerText,
				screenSize = self.props.screenSize,
				position = self.props.position,
				orientation = self.props.orientation,
				isDirectChild = isDirectChild,
			}),
		}

		return isDirectChild and Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, tooltipComponents)
		or Roact.createFragment(tooltipComponents)
	end)
end

return Tooltip
