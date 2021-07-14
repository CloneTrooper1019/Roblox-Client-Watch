local root = script.Parent
local Packages = root.Parent

local Cryo = require(Packages.Cryo)
local Roact = require(Packages.Roact)

local FitFrameOnAxis = require(script.Parent.FitFrameOnAxis)

return function(props)
	props = props or {}
	local width = props.width

	local filteredProps = Cryo.Dictionary.join(props, {
		axis = FitFrameOnAxis.Axis.Vertical,
		minimumSize = UDim2.new(width, UDim.new(0, 0)),

		width = Cryo.None,
	})

	return Roact.createElement(FitFrameOnAxis, filteredProps)
end