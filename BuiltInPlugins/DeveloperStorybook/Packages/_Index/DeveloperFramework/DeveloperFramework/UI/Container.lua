--[[
	A basic container. If no Background is provided, it is invisible.
	Does not have a Style and does not rely on Theme.

	Optional Props:
		Enum.AutomaticSize AutomaticSize: The AutomaticSize of the component.
		boolean ClipsDescendants: Whether the container ClipsDescendants
		Component Background: The Decoration to use as this component's background.
		Style BackgroundStyle: The Style to style the Background decoration with.
		StyleModifier BackgroundStyleModifier: The Modifier to index into the Background style with.
		boolean Active: Determines whether the container should sink input.
			NB: This does not stop input from propagating unless ElementOverride is set to "ImageButton".
		number Margin: A constant margin all around the component, including the background.
		table Margin: Specific margin values for Top, Bottom, Left, and Right.
		number Padding: A constant padding all around the interior of the component.
		table Padding: Specific padding values for Top, Bottom, Left, and Right.
		UDim2 Size: The size of this component.
		UDim2 Position: The position of this component.
		Vector2 AnchorPoint: The pivot point of this component's Position prop.
		number ZIndex: The render index of this component.
		number LayoutOrder: The layout order of this component in a list.
		Enum.SizeConstraint SizeConstraint: the direction(s) that the container can be resized in.
		boolean Visible: whether or not the component is rendered.
		string ElementOverride: use this built-in GuiObject instead of Frame.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Util = require(Framework.Util)
local Immutable = Util.Immutable
local Typecheck = Util.Typecheck

local FlagsList = Util.Flags.new({
	FFlagToolboxReplaceUILibraryComponentsPt2 = {"ToolboxReplaceUILibraryComponentsPt2"},
})

local Container = Roact.PureComponent:extend("Container")
Typecheck.wrap(Container, script)

function Container:render()
	local props = self.props

	local background = props.Background
	local backgroundStyle = props.BackgroundStyle
	local backgroundStyleModifier = props.BackgroundStyleModifier

	local active = props.Active
	local automaticSize = props.AutomaticSize
	local padding = props.Padding
	local margin = props.Margin
	local size = props.Size or UDim2.new(1, 0, 1, 0)
	local position = props.Position
	local anchorPoint = props.AnchorPoint
	local zIndex = props.ZIndex
	local layoutOrder = props.LayoutOrder
	local visible = props.Visible
	local elementOverride = props.ElementOverride
	local ref = props[Roact.Ref]
	local clipsDescendants = props.ClipsDescendants or false

	local children = props[Roact.Children] or {}
	if type(padding) == "number" then
		children = Immutable.JoinDictionaries(children, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, padding),
				PaddingBottom = UDim.new(0, padding),
				PaddingLeft = UDim.new(0, padding),
				PaddingRight = UDim.new(0, padding),
			})
		})
	elseif type(padding) == "table" then
		children = Immutable.JoinDictionaries(children, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, padding.Top),
				PaddingBottom = UDim.new(0, padding.Bottom),
				PaddingLeft = UDim.new(0, padding.Left),
				PaddingRight = UDim.new(0, padding.Right),
			})
		})
	end

	local marginComponent
	if margin then
		if type(margin) == "number" then
			marginComponent = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, margin),
				PaddingBottom = UDim.new(0, margin),
				PaddingLeft = UDim.new(0, margin),
				PaddingRight = UDim.new(0, margin),
			})
		elseif type(margin) == "table" then
			marginComponent = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, margin.Top),
				PaddingBottom = UDim.new(0, margin.Bottom),
				PaddingLeft = UDim.new(0, margin.Left),
				PaddingRight = UDim.new(0, margin.Right),
			})
		end
	end

	local contentSize = UDim2.new(1, 0, 1, 0)
	if FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") and automaticSize then
		contentSize = size
	end

	return Roact.createElement(elementOverride or "Frame", {
		Active = active,
		AutomaticSize = FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") and automaticSize or nil,
		BackgroundTransparency = 1,
		Size = size,
		SizeConstraint = props.SizeConstraint,
		Position = position,
		LayoutOrder = layoutOrder,
		AnchorPoint = anchorPoint,
		ZIndex = zIndex,
		Visible = visible,
		[Roact.Ref] = ref,
		[Roact.Change.AbsoluteSize] = props[Roact.Change.AbsoluteSize],
		[Roact.Change.AbsolutePosition] = FlagsList:get("FFlagToolboxReplaceUILibraryComponentsPt2") and props[Roact.Change.AbsolutePosition] or nil,
	}, {
		Margin = marginComponent,

		Decoration = background and Roact.createElement(background, {
			Style = backgroundStyle,
			StyleModifier = backgroundStyleModifier,
		}),

		Contents = Roact.createElement("Frame", {
			ClipsDescendants = clipsDescendants,
			BackgroundTransparency = 1,
			Size = contentSize,
			ZIndex = 2,
		}, children),
	})
end

return Container
