local root = script.Parent
local Packages = root.Parent

local Cryo = require(Packages.Cryo)
local Roact = require(Packages.Roact)

local FitFrameOnAxis = require(script.Parent.FitFrameOnAxis)

return function(props)
	props = props or {}
	local height = props.height

	local filteredProps = Cryo.Dictionary.join(props, {
		axis = FitFrameOnAxis.Axis.Horizontal,
		minimumSize = UDim2.new(UDim.new(0, 0), height),

		height = Cryo.None,
	})

	return Roact.createElement(FitFrameOnAxis, filteredProps)
end