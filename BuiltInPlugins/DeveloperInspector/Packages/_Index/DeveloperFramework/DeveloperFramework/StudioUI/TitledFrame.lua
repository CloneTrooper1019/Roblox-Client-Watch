--[[
	A frame with a title offset to the left side.
	Used as a distinct vertical entry on a SettingsPage.

	Required Props:
		string Title: The title to the left of the content

	Optional Props:
		number TitleWidth: The pixel pize of the padding between the title and content
		Enum.FillDirection FillDirection: The direction in which the content is filled.
		number LayoutOrder: The layoutOrder of this component.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		number ZIndex: The render index of this component.
]]
local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local FitFrame = require(Framework.Util.FitFrame)
local FitFrameVertical = FitFrame.FitFrameVertical
local FitTextLabel = FitFrame.FitTextLabel

local TitledFrame = Roact.PureComponent:extend("TitledFrame")
Typecheck.wrap(TitledFrame, script)

TitledFrame.defaultProps = {
	FillDirection = Enum.FillDirection.Vertical,
	TitleWidth = 180,
}

function TitledFrame:render()
	local props = self.props
	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local font = style.Font
	local padding = style.Padding
	local textColor = style.TextColor
	local textSize = style.TextSize

	local fillDirection = props.FillDirection
	local layoutOrder = props.LayoutOrder
	local title = props.Title
	local titleWidth = props.TitleWidth
	local zIndex = props.ZIndex

	return Roact.createElement(FitFrameVertical, {
		BackgroundTransparency = 1,
		FillDirection = Enum.FillDirection.Horizontal,
		LayoutOrder = layoutOrder,
		width = UDim.new(1, 0),
		ZIndex = zIndex,

		[Roact.Ref] = props[Roact.Ref],
	}, {
		Title = Roact.createElement(FitTextLabel, {
			BackgroundTransparency = 1,
			Font = font,
			TextColor3 = textColor,
			TextSize = textSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Text = title,
			TextWrapped = true,
			width = UDim.new(0, titleWidth),
		}),

		Content = Roact.createElement(FitFrameVertical, {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			contentPadding = UDim.new(0, padding),
			FillDirection = fillDirection,
			LayoutOrder = layoutOrder,
			Position = UDim2.new(1, 0, 0, 0),
			width = UDim.new(1, -titleWidth),
			ZIndex = zIndex,
		}, props[Roact.Children]),
	})
end

ContextServices.mapToProps(TitledFrame, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return TitledFrame
