--[[
	Basic component wrapping around a LineHandleAdornment. Used for
	components such as a Wireframe or Lattice to render edges.

	Props:
		Vector3 StartPoint: start position of the line
		Vector3 EndPoint: end position of the line
		instance Adornee: part that this line is attached to
		number Transparency: transparency of the line
		Color3 Color: color of the line
]]

local Plugin = script.Parent.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local ControlPointLink = Roact.PureComponent:extend("ControlPoint")

function ControlPointLink:render()
	local props = self.props

	local startPoint = props.StartPoint
	local endPoint = props.EndPoint
	local adornee = props.Adornee
	local transparency = props.Transparency
	local color = props.Color

	local length = (startPoint - endPoint).Magnitude
	local cframe = CFrame.new(Vector3.new(0, 0, 0), (endPoint - startPoint).Unit)
	cframe = cframe + startPoint

	return Roact.createElement("LineHandleAdornment", {
		Length = length,
		CFrame = cframe,
		Thickness = 2,
		Transparency = transparency,
		Color3 = color,
		Adornee = adornee,
		AlwaysOnTop = false,
		ZIndex = 1,
		Archivable = false,
	})
end

return ControlPointLink