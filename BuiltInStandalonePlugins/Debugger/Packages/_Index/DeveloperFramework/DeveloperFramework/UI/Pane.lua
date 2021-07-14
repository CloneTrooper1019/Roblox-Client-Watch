--[[
	A basic pane with minimal configuration.
	All standard props are passed through to the underlying instance, which may be a Frame or ImageLabel.

	Optional Props:
		BackgroundColor: Override the color of the background.
		BorderColor: Override the color of the border image color.
		Padding: An optional number or table adding a UIPadding instance.
		Layout: An optional Enum.FillDirection adding a UIListLayout instance.
		Spacing: An optional number or UDim to space elements out by.
		HorizontalAlignment: Property on UIListLayout
		VerticalAlignment: Property on UIListLayout
		callback OnClick: Triggered when the user clicks on this component.
		callback OnPress: Triggered when the user clicks or taps on this component.
	Styles:
		Default: The pane has no background
		Box: The pane has the current theme's main background.
		RoundBox: The pane has the current theme's main background with the standard rounded border.
		BorderBox: The pane has the current theme's main background with square border.
]]
local FFlagDevFrameworkPaneSupportTheme1 = game:GetFastFlag("DevFrameworkPaneSupportTheme1")
local FFlagDevFrameworkPaneOnClick = game:GetFastFlag("DevFrameworkPaneOnClick")

local Framework = script.Parent.Parent
local ContextServices = require(Framework.ContextServices)
local Roact = require(Framework.Parent.Roact)
local isInputMainPress = require(Framework.Util.isInputMainPress)

local THEME_REFACTOR = require(Framework.Util).RefactorFlags.THEME_REFACTOR

local Dash = require(Framework.packages.Dash)
local assign = Dash.assign
local join = Dash.join
local omit = Dash.omit

local Pane = Roact.PureComponent:extend("Pane")

local function getClassName(props, style)
	local className
	if style.Image then
		if props.OnClick then
			className = "ImageButton"
		else
			className = "ImageLabel"
		end
	elseif props.OnClick then
		className = "TextButton"
	else
		className = "Frame"
	end
	return className
end

Pane.defaultProps = {
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
}

function Pane:init()
	self.onPress = function(_, input)
		if isInputMainPress(input) then
			self.props.OnPress(input)
		end
	end
end

function Pane:render()
	local props = self.props

	local style
	if FFlagDevFrameworkPaneSupportTheme1 then
		local theme = props.Theme
		if THEME_REFACTOR then
			style = props.Stylizer
		else
			style = theme:getStyle("Framework", self)
		end
	else
		style = props.Stylizer
	end
	local children = props[Roact.Children] or {}

	local padding = props.Padding
	if padding then
		local isPaddingNumber = type(padding) == "number"
		children.Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, isPaddingNumber and padding or padding.Top or 0),
			PaddingBottom = UDim.new(0, isPaddingNumber and padding or padding.Bottom or 0),
			PaddingLeft = UDim.new(0, isPaddingNumber and padding or padding.Left or 0),
			PaddingRight = UDim.new(0, isPaddingNumber and padding or padding.Right or 0),
		})
	end
	if props.Layout then
		local spacing
		if props.Spacing then
			if typeof(props.Spacing) == "number" then
				spacing = UDim.new(0, props.Spacing)
			else
				spacing = props.Spacing
			end
		end
		children.Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = props.Layout,
			HorizontalAlignment = props.HorizontalAlignment,
			VerticalAlignment = props.VerticalAlignment,
			Padding = spacing,
		})
	end

	if props.OnPress then
		props[Roact.Event.InputBegan] = self.onPress
	end

	local automaticSize = props.AutomaticSize
	local scaleX = 1
	local scaleY = 1
	if automaticSize then
		if automaticSize == Enum.AutomaticSize.X or automaticSize == Enum.AutomaticSize.XY then
			scaleX = 0
		end
		if automaticSize == Enum.AutomaticSize.Y or automaticSize == Enum.AutomaticSize.XY then
			scaleY = 0
		end
	end

	local className
	if FFlagDevFrameworkPaneOnClick then
		className = getClassName(props, style)
	else
		className = "Frame"
	end

	local defaultProps = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = props.Size or UDim2.fromScale(scaleX, scaleY),
	}
	local color = props.BackgroundColor3 or props.BackgroundColor or style.Background
	if color then
		defaultProps.BackgroundTransparency = 0
	end

	if FFlagDevFrameworkPaneOnClick and props.OnClick then
		props[Roact.Event.Activated] = props.OnClick
		if not style.Image then
			props.Text = ""
		end
	end

	if style.Image then
		if not FFlagDevFrameworkPaneOnClick then
			className = "ImageLabel"
		end
		assign(defaultProps, {
			Image = style.Image,
			ImageColor3 = color,
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = style.SliceCenter,
		})
	elseif color then
		defaultProps.BackgroundColor3 = color
	end
	if style.Border then
		children = {
			Contents = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(scaleX, scaleY),
				AutomaticSize = automaticSize,
				Image = style.Border.Image,
				ImageColor3 = props.BorderColor or style.Border.Background,
				BackgroundTransparency = 1,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = style.Border.SliceCenter,
			}, children)
		}
	end
	local componentProps = omit(join(defaultProps, props), FFlagDevFrameworkPaneSupportTheme1 and {
		Roact.Children,
		"StyleModifier",
		"BackgroundColor",
		"BorderColor",
		"Padding",
		"Layout",
		"Spacing",
		"Style",
		"Stylizer",
		"Theme",
		"HorizontalAlignment",
		"VerticalAlignment",
		"OnClick",
		"OnPress",
	}
	or {
		Roact.Children,
		"StyleModifier",
		"BackgroundColor",
		"BorderColor",
		"Padding",
		"Layout",
		"Spacing",
		"Style",
		"Stylizer",
		"HorizontalAlignment",
		"VerticalAlignment",
		"OnClick",
		"OnPress",
	})

	return Roact.createElement(className, componentProps, children)
end

if FFlagDevFrameworkPaneSupportTheme1 then
	ContextServices.mapToProps(Pane, {
		Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
		Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
	})
else
	ContextServices.mapToProps(Pane, {
		Stylizer = ContextServices.Stylizer,
	})
end

return Pane
