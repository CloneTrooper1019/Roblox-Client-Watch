--[[
	A Loading bar which renders a background and a foreground, which is scaled based
	on the provided progress of the load.
	Using the default style, the recommended height for this component is 8px.

	Required Props:
		number Progress: The progress of the load, between 0 and 1.

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		StyleModifier StyleModifier: The StyleModifier index into Style.
		UDim2 Size: The size of this component.
		Style Style: The style with which to render this component.
		UDim2 Position: The position of this component.
		Vector2 AnchorPoint: The pivot point of this component's Position prop.
		number ZIndex: The render index of this component.
		number LayoutOrder: The layout order of this component in a list.

	Style Values:
		Component Background: The background of the LoadingBar.
		Style BackgroundStyle: The style with which to render the background.
		Component Foreground: The bar itself which fills the background.
		Style ForegroundStyle: The style with which to render the foreground.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Container = require(Framework.UI.Container)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local LoadingBar = Roact.PureComponent:extend("LoadingBar")
Typecheck.wrap(LoadingBar, script)

function LoadingBar:init(props)
	assert(type(props.Progress) == "number", "LoadingBar expects a 'Progress' prop.")
end

function LoadingBar:render()
	local props = self.props
	local theme = props.Theme
	local style
	if THEME_REFACTOR then
		style = props.Stylizer
	else
		style = theme:getStyle("Framework", self)
	end

	local progress = props.Progress
	progress = math.clamp(progress, 0, 1)

	local size = props.Size
	local position = props.Position
	local anchorPoint = props.AnchorPoint
	local zIndex = props.ZIndex
	local layoutOrder = props.LayoutOrder

	local background = style.Background
	local backgroundStyle = style.BackgroundStyle
	local foreground = style.Foreground
	local foregroundStyle = style.ForegroundStyle

	return Roact.createElement(Container, {
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		ZIndex = zIndex,
		LayoutOrder = layoutOrder,
		Background = background,
		BackgroundStyle = backgroundStyle,
	}, {
		LoadingBar = Roact.createElement(Container, {
			Size = UDim2.new(progress, 0, 1, 0),
			Background = foreground,
			BackgroundStyle = foregroundStyle,
		}),
	})
end

ContextServices.mapToProps(LoadingBar, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return LoadingBar
