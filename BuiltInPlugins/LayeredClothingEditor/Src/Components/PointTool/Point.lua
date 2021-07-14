--[[
	Represents a single mesh vertex to be displayed in 3D view.

	Props:
		Vector3 Position: position of the point in 3D world space
		boolean Selected: is this point selected via mouse click
		boolean Hovered: is this point hovered by the mouse
		instance Adornee: part that this point is attached to
		number Transparency: transparency of the point
		Color3 Color: color of the point
		number Weight: used as alpha for interpolation of point color
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local Point = Roact.PureComponent:extend("Point")

function Point:render()
	local props = self.props

	local theme = props.Stylizer

	local position = props.Position
	local selected = props.Selected
	local adornee = props.Adornee
	local hovered = props.Hovered
	local weight = props.Weight
	local transparency = props.Transparency
	local color = theme.DefaultColor
	if selected then
		color = theme.SelectedColorNoWeight:lerp(theme.SelectedColor, weight)
	elseif hovered then
		color = theme.HoveredColor
	end

	return Roact.createElement("SphereHandleAdornment", {
		CFrame = CFrame.new(position),
		Transparency = transparency,
		Color3 = color,
		ZIndex = 1,
		AlwaysOnTop = false,
		Adornee = adornee,
		Radius = theme.DefaultPointSize,
		Archivable = false,
	})
end

ContextServices.mapToProps(Point,{
	Stylizer = ContextServices.Stylizer,
})

return Point