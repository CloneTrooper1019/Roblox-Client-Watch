--[[
	Displays rotation gimbal handles. When dragging, start and end radii showing
	the central angle of rotation are displayed.
]]

local Workspace = game:GetService("Workspace")

-- Dragger Framework
local DraggerFramework = script.Parent.Parent
local Packages = DraggerFramework.Parent
local Roact = require(Packages.Roact)
local Math = require(DraggerFramework.Utility.Math)

local CULLING_MODE = Enum.AdornCullingMode.Never

local RotateHandleView = Roact.PureComponent:extend("RotateHandleView")

local HANDLE_SEGMENTS = 32
local HANDLE_RADIUS = 4.5
local HANDLE_THICKNESS = 0.15
local ANGLE_DISPLAY_THICKNESS = 0.08
local HANDLE_HITTEST_THICKNESS = HANDLE_THICKNESS * 4
local HANDLE_THIN_BY_FRAC = 0.0
local HANDLE_THICK_BY_FRAC = 1.5
local HANDLE_DIM_TRANSPARENCY = 0.45
local HANDLE_TICK_WIDTH = 0.05
local HANDLE_TICK_WIDE_WIDTH = 0.10
local HANDLE_TICK_RADIUS_FRAC = 0.10 -- Fraction of the radius
local HANDLE_TICK_RADIUS_LONG_FRAC = 0.30 -- Fraction for the primary angles (multiple of 90)
local QUARTER_ROTATION = math.pi / 2

local function isMultipleOf90Degrees(angle)
	local roundedTo90 = math.floor(angle / QUARTER_ROTATION + 0.5) * QUARTER_ROTATION
	return math.abs(angle - roundedTo90) < 0.001
end

function RotateHandleView:render()
	-- TODO: DEVTOOLS-3876: [Modeling] Rotate tool enhancements
	-- Gimbal arc length should be a function of the viewing angle, and handle
	-- should face the camera.

	local radiusOffset = self.props.RadiusOffset or 0.0
	local radius = (HANDLE_RADIUS + radiusOffset) * self.props.Scale
	if self.props.Hovered then
		radius = radius + self.props.Scale * 0.1
	end
	local thickness = HANDLE_THICKNESS * self.props.Scale
	local angleStep = 2 * math.pi / HANDLE_SEGMENTS
	local offset = radius * math.cos(angleStep / 2)

	local children = {}

	-- Thinning for drag
	if self.props.Thin then
		thickness = HANDLE_THIN_BY_FRAC * thickness
	end
	if self.props.Hovered then
		thickness = HANDLE_THICK_BY_FRAC * thickness
	end

	-- Draw main rotation gimbal.
	local halfThickness = 0.5 * thickness
	children["OnTopHandle"] = Roact.createElement("CylinderHandleAdornment", {
		Adornee = Workspace.Terrain,
		CFrame = self.props.HandleCFrame * CFrame.Angles(self.props.StartAngle or 0, math.pi / 2, math.pi / 2),
		Height = thickness,
		Radius = radius + halfThickness,
		InnerRadius = radius - halfThickness,
		Color3 = self.props.Color,
		AlwaysOnTop = true,
		Transparency = HANDLE_DIM_TRANSPARENCY,
		ZIndex = 0,
		AdornCullingMode = CULLING_MODE,
	})
	children["BrightHandle"] = Roact.createElement("CylinderHandleAdornment", {
		Adornee = Workspace.Terrain,
		CFrame = self.props.HandleCFrame * CFrame.Angles(self.props.StartAngle or 0, math.pi / 2, math.pi / 2),
		Height = thickness,
		Radius = radius + halfThickness,
		InnerRadius = radius - halfThickness,
		Color3 = self.props.Color,
		AlwaysOnTop = false,
		ZIndex = 0,
		AdornCullingMode = CULLING_MODE,
	})

	if self.props.TickAngle then
		local angleStep = self.props.TickAngle
		local count = math.ceil(math.pi * 2 / angleStep)
		local smallTickWidth = HANDLE_TICK_WIDTH * self.props.Scale
		local smallTickLength = HANDLE_TICK_RADIUS_FRAC * radius

		-- Information for the primary ticks placed at 90 degree intervals
		-- relative to the angle the rotate started at.
		local primaryTickWidth = HANDLE_TICK_WIDE_WIDTH * self.props.Scale
		local primaryTickLength = HANDLE_TICK_RADIUS_LONG_FRAC * radius
		local placementAngleMod = 0
		local primaryTickAngleMod = 0
		local hasPrimaryTicks = false
		if self.props.StartAngle then
			placementAngleMod = self.props.EndAngle - self.props.StartAngle
			primaryTickAngleMod = self.props.StartAngle
			hasPrimaryTicks = true
		end

		for i = 1, count do
			local angle = math.pi + (i - 1) * angleStep - placementAngleMod
			local isPrimaryTick = hasPrimaryTicks and isMultipleOf90Degrees(angle - primaryTickAngleMod)
			local tickLength = isPrimaryTick and primaryTickLength or smallTickLength
			local tickWidth = isPrimaryTick and primaryTickWidth or smallTickWidth
			local cframe =
				self.props.HandleCFrame *
				CFrame.Angles(angle, 0, 0) *
				CFrame.new(0, 0, radius - 0.5 * smallTickLength)
			children["Tick" .. tostring(i)] = Roact.createElement("BoxHandleAdornment", {
				Adornee = Workspace.Terrain,
				AlwaysOnTop = false,
				CFrame = cframe,
				Color3 = self.props.Color,
				Size = Vector3.new(tickWidth, tickWidth, tickLength),
				ZIndex = 0,
				AdornCullingMode = CULLING_MODE,
			})
			children["OnTopTick" .. tostring(i)] = Roact.createElement("BoxHandleAdornment", {
				Adornee = Workspace.Terrain,
				AlwaysOnTop = true,
				Transparency = HANDLE_DIM_TRANSPARENCY,
				CFrame = cframe,
				Color3 = self.props.Color,
				Size = Vector3.new(tickWidth, tickWidth, tickLength),
				ZIndex = 0,
				AdornCullingMode = CULLING_MODE,
			})
		end
	end

	-- Draw the swept angle as circular section at the outer edge. The circular
	-- section shows the smallest swept angle back to the starting point.
	if self.props.StartAngle and self.props.EndAngle then
		local smallTickLength = HANDLE_TICK_RADIUS_FRAC * radius
		local primaryTickLength = HANDLE_TICK_RADIUS_LONG_FRAC * radius
		local outerWidth = 0.5 * (primaryTickLength - smallTickLength)

		local theta = self.props.EndAngle - self.props.StartAngle
		local startAngle = self.props.StartAngle
		if theta > math.pi then
			theta = theta - math.pi * 2
		end
		if theta < -math.pi then
			theta = theta + math.pi * 2
		end
		if theta < 0 then
			startAngle = startAngle + theta
			theta = math.abs(theta)
		end
		if math.abs(theta) > 0.001 then
			children.AngleSweepElement = Roact.createElement("CylinderHandleAdornment", {
				Adornee = Workspace.Terrain,
				CFrame = self.props.HandleCFrame * CFrame.Angles(startAngle - math.pi / 2, math.pi / 2, math.pi / 2),
				Height = 0,
				Radius = radius,
				InnerRadius = 0,
				Angle = math.deg(theta),
				Color3 = self.props.Color,
				AlwaysOnTop = true,
				Transparency = 0.6,
				ZIndex = 0,
			})
		end

		local angleDisplayThickness = ANGLE_DISPLAY_THICKNESS * self.props.Scale
		local function createAngleDisplay(angle)
			local offset = CFrame.new(0, 0, -(radius + outerWidth) / 2)
			local cframe = self.props.HandleCFrame * CFrame.Angles(angle, 0, 0) * offset
			return Roact.createElement("CylinderHandleAdornment", {
				Adornee = Workspace.Terrain,
				AlwaysOnTop = true,
				CFrame = cframe,
				Color3 = self.props.Color,
				Height = radius + outerWidth,
				Radius = angleDisplayThickness / 2,
				ZIndex = 0,
			})
		end
		children.EndAngleElement = createAngleDisplay(self.props.EndAngle)
	end

	return Roact.createElement("Folder", {}, children)
end

--[[
	Check if the mouse is over the rotation handle.

	The point of intersection between the mouse ray and plane perpendicular
	to the rotation axis is computed. The hit radius (distance from the origin
	of rotation to the intersection point) is compared to the gimbal radius,
	within a threshold to aid handle selection.
]]
function RotateHandleView.hitTest(props, mouseRay)
	local cframe = props.HandleCFrame
	local unitRay = mouseRay.Unit

	local radiusOffset = props.RadiusOffset or 0.0
	local radius = (HANDLE_RADIUS + radiusOffset) * props.Scale
	local thickness = HANDLE_HITTEST_THICKNESS * props.Scale
	local normal = cframe.RightVector
	local point = cframe.Position

	local smallestDistance = math.huge
	local foundHit = false
	local hit, t

	-- Top ring
	local topPoint = point + normal * 0.5 * thickness
	t = Math.intersectRayPlane(unitRay.Origin, unitRay.Direction, topPoint, normal)
	if t >= 0 and t < smallestDistance then
		local mouseWorld = unitRay.Origin + unitRay.Direction * t
		local hitRadius = (mouseWorld - topPoint).Magnitude

		local distance = math.abs(hitRadius - radius)
		if distance < 0.5 * thickness then
			foundHit = true
			smallestDistance = t
		end
	end

	-- Bottom ring
	local bottomPoint = point - normal * 0.5 * thickness
	t = Math.intersectRayPlane(unitRay.Origin, unitRay.Direction, bottomPoint, -normal)
	if t >= 0 and t < smallestDistance then
		local mouseWorld = unitRay.Origin + unitRay.Direction * t
		local hitRadius = (mouseWorld - bottomPoint).Magnitude

		local distance = math.abs(hitRadius - radius)
		if distance < 0.5 * thickness then
			foundHit = true
			smallestDistance = t
		end
	end

	-- Get the ray in local space, so that we can use the intersectRayCylinder
	-- call for the intersection. The canonical normal of the cylinder is
	-- (1, 0, 0) which is what that call expects.
	local o = cframe:PointToObjectSpace(unitRay.Origin)
	local d = cframe:VectorToObjectSpace(unitRay.Direction)

	-- Inner Cylinder
	local innerRadius = radius - 0.5 * thickness
	hit, t = Math.intersectRayCylinder(o, d, innerRadius, thickness)
	if hit and t < smallestDistance then
		foundHit = true
		smallestDistance = t
	end

	-- Outer Cylinder
	local outerRadius = radius + 0.5 * thickness
	hit, t = Math.intersectRayCylinder(o, d, outerRadius, thickness)
	if hit and t < smallestDistance then
		foundHit = true
		smallestDistance = t
	end

	if foundHit then
		return smallestDistance
	else
		return nil
	end
end

return RotateHandleView
