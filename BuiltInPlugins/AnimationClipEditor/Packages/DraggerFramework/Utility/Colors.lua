local Colors = {}

Colors.WHITE = Color3.new(1, 1, 1)
Colors.BLACK = Color3.new(0, 0, 0)
Colors.GRAY = Color3.new(0.7, 0.7, 0.7)

Colors.X_AXIS = Color3.new(1, 0, 0)
Colors.Y_AXIS = Color3.new(0, 1, 0)
Colors.Z_AXIS = Color3.new(0, 0, 1)

Colors.WeldJoint = Color3.new(1, 1, 1)
Colors.RotatingJoint = Color3.new(0, 0, 1)
Colors.InvalidJoint = Color3.new(1, 0, 0)

Colors.SizeLimitReached = Color3.new(1, 1, 0)

function Colors.makeDimmed(color)
	return color:Lerp(Colors.BLACK, 0.3)
end

return Colors
