--[[
	A generic expandable widget which automatically sizes to its contents and can accept any kind of components.
	Intended to be a lightweight control to toggle visibility of a frame which contains togglable content.

	Required Props:
		table TopLevelContent: Table of components for the always visible top-level content.
		table ExpandableContent: Table of components whose visibility can be toggled.

	Optional Props:
		callback OnClick: Function that wll be called on clicking the topLevelItems.
		boolean IsExpanded: Whether or not the contents are visible.
		Vector2 AnchorPoint: The pivot point of this component's Position prop.
		number LayoutOrder: The layout order of this component in a list.
		UDim2 Position: The position of this component.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local UI = Framework.UI
local Pane = require(UI.Pane)

local ExpandableWidget = Roact.PureComponent:extend("ExpandableWidget")
Typecheck.wrap(ExpandableWidget, script)

function ExpandableWidget:render()
	local props = self.props

	local position = props.Position
	local anchorPoint = props.AnchorPoint
	local isExpanded = props.IsExpanded
	local layoutOrder = props.LayoutOrder
	local topLevelContent = props.TopLevelContent
	local expandableContent = props.ExpandableContent
	local onClick = props.OnClick

	return Roact.createElement(Pane, {
		AutomaticSize = Enum.AutomaticSize.XY,
		AnchorPoint = anchorPoint,
		Layout = Enum.FillDirection.Vertical,
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Position = position,
		Size = UDim2.new(1, 0, 0, 0),
	}, {
		TopLevelItem = Roact.createElement("TextButton", {
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 0,
			BackgroundTransparency = 1,
			Text = "",
			[Roact.Event.Activated] = onClick,
			Size = UDim2.new(1, 0, 0, 0),
		}, topLevelContent),

		ExpandableFrame = isExpanded and Roact.createElement("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 0),
		}, expandableContent),
	})
end

return ExpandableWidget
