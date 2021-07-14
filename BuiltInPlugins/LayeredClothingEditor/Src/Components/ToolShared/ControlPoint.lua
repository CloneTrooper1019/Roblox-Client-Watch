--[[
	Simple wrapper around a part to represent a clickable control point.

	Props:
		Vector3 Position: position of the point in 3D world space
		boolean Selected: is this point selected via mouse click
		boolean Hovered: is this point hovered by the mouse
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local ControlPoint = Roact.PureComponent:extend("ControlPoint")

function ControlPoint:render()
	local props = self.props
	local position = props.Position
	local selected = props.Selected
	local hovered = props.Hovered

	local theme = props.Stylizer

	local color = theme.DefaultColor
	if selected then
		color = theme.SelectedColor
	elseif hovered then
		color = theme.HoveredColor
	end

	local children = props[Roact.Children]

	return Roact.createElement("Part", {
		CFrame = CFrame.new(position),
		Size = Vector3.new(theme.PointSize, theme.PointSize, theme.PointSize),
		Transparency = theme.Transparency,
		Color = color,
		Archivable = false,
	}, children)
end

ContextServices.mapToProps(ControlPoint,{
	Stylizer = ContextServices.Stylizer,
})

return ControlPoint