local getFFlagDraggerPerf = require(script.Parent.Parent.Flags.getFFlagDraggerPerf)
local FFlagDraggerPerf = getFFlagDraggerPerf()

local UniformScale = Vector3.new(1, 1, 1)

local function getShape(part)
	if part:IsA('WedgePart') then
		return 'Wedge', UniformScale
	elseif part:IsA('CornerWedgePart') then
		return 'CornerWedge', UniformScale
	elseif part:IsA('Terrain') then
		return 'Terrain', UniformScale
	elseif part:IsA('UnionOperation') then
		return 'Brick', UniformScale
	elseif part:IsA('MeshPart') then
		return 'Brick', UniformScale
	elseif part:IsA('Part') then
		-- BasePart
		if part.Shape == Enum.PartType.Ball then
			return 'Sphere', UniformScale
		elseif part.Shape == Enum.PartType.Cylinder then
			return 'Cylinder', UniformScale
		elseif part.Shape == Enum.PartType.Block then
			return 'Brick', UniformScale
		else
			assert(false, "Unreachable")
		end
	else
		return 'Brick', UniformScale
	end
end

return function(part, hit, assumedCFrame)
	local cf
	if FFlagDraggerPerf then
		cf = assumedCFrame or part.CFrame
	else
		cf = part.CFrame
	end
	local pos = cf.p

	local sx = part.Size.x/2
	local sy = part.Size.y/2
	local sz = part.Size.z/2

	local xvec = cf.RightVector
	local yvec = cf.UpVector
	local zvec = -cf.LookVector

	local verts, edges, faces;

	local shape, scale = getShape(part)

	sx = sx * scale.X
	sy = sy * scale.Y
	sz = sz * scale.Z

	if shape == 'Brick' or shape == 'Sphere' or shape == 'Cylinder' then
		--8 vertices
		verts = {
			pos +xvec*sx  +yvec*sy  +zvec*sz, --top 4
			pos +xvec*sx  +yvec*sy  -zvec*sz,
			pos -xvec*sx  +yvec*sy  +zvec*sz,
			pos -xvec*sx  +yvec*sy  -zvec*sz,
			--
			pos +xvec*sx  -yvec*sy  +zvec*sz, --bottom 4
			pos +xvec*sx  -yvec*sy  -zvec*sz,
			pos -xvec*sx  -yvec*sy  +zvec*sz,
			pos -xvec*sx  -yvec*sy  -zvec*sz,
		}
		--12 edges
		edges = {
			{verts[1], verts[2], math.min(2*sx, 2*sy)}, --top 4
			{verts[3], verts[4], math.min(2*sx, 2*sy)},
			{verts[1], verts[3], math.min(2*sy, 2*sz)},
			{verts[2], verts[4], math.min(2*sy, 2*sz)},
			--
			{verts[5], verts[6], math.min(2*sx, 2*sy)}, --bottom 4
			{verts[7], verts[8], math.min(2*sx, 2*sy)},
			{verts[5], verts[7], math.min(2*sy, 2*sz)},
			{verts[6], verts[8], math.min(2*sy, 2*sz)},
			--
			{verts[1], verts[5], math.min(2*sx, 2*sz)}, --verticals
			{verts[2], verts[6], math.min(2*sx, 2*sz)},
			{verts[3], verts[7], math.min(2*sx, 2*sz)},
			{verts[4], verts[8], math.min(2*sx, 2*sz)},
		}
		--6 faces
		faces = {
			{verts[1],  xvec, 'RightSurface',  zvec, {verts[5], verts[6], verts[2], verts[1]}}, --right
			{verts[3], -xvec, 'LeftSurface',   zvec, {verts[3], verts[4], verts[8], verts[7]}}, --left
			{verts[1],  yvec, 'TopSurface',    xvec, {verts[1], verts[2], verts[4], verts[3]}}, --top
			{verts[5], -yvec, 'BottomSurface', xvec, {verts[7], verts[8], verts[6], verts[5]}}, --bottom
			{verts[1],  zvec, 'BackSurface',   xvec, {verts[1], verts[3], verts[7], verts[5]}}, --back
			{verts[2], -zvec, 'FrontSurface',  xvec, {verts[6], verts[8], verts[4], verts[2]}}, --front
		}
	elseif shape == 'Sphere' or shape == 'Cylinder' then
		-- Just have one face and vertex, at the hit pos
		verts = { hit }
		edges = {} --edge can be selected as the normal of the face if the user needs it
		local norm = (hit-pos).Unit
		local norm2 = norm:Cross(Vector3.new(0,1,0)).Unit

		local surfaceName
		if math.abs(norm.X) > math.abs(norm.Y) and math.abs(norm.X) > math.abs(norm.Z) then
			surfaceName = (norm.X > 0) and "RightSurface" or "LeftSurface"
		elseif math.abs(norm.Y) > math.abs(norm.Z) then
			surfaceName = (norm.Y > 0) and "TopSurface" or "BottomSurface"
		else
			surfaceName = (norm.Z > 0) and "BackSurface" or "FrontSurface"
		end
		faces = {
			{hit, norm, surfaceName, norm2, {}}
		}
	elseif shape == 'CornerWedge' then
		local slantVec1 = ( zvec*sy + yvec*sz).Unit
		local slantVec2 = (-xvec*sy + yvec*sx).Unit
		-- 5 verts
		verts = {
			pos +xvec*sx  +yvec*sy  -zvec*sz, --top 1
			--
			pos +xvec*sx  -yvec*sy  +zvec*sz, --bottom 4
			pos +xvec*sx  -yvec*sy  -zvec*sz,
			pos -xvec*sx  -yvec*sy  +zvec*sz,
			pos -xvec*sx  -yvec*sy  -zvec*sz,
		}
		-- 8 edges
		edges = {
			{verts[2], verts[3], 0}, -- bottom 4
			{verts[3], verts[5], 0},
			{verts[5], verts[4], 0},
			{verts[4], verts[1], 0},
			--
			{verts[1], verts[3], 0}, -- vertical
			--
			{verts[1], verts[2], 0}, -- side diagonals
			{verts[1], verts[5], 0},
			--
			{verts[1], verts[4], 0}, -- middle diagonal
		}
		-- 5 faces
		faces = {
			{verts[2], -yvec, 'BottomSurface', xvec, {verts[2], verts[3], verts[5], verts[4]}}, -- bottom
			--
			{verts[1],  xvec, 'RightSurface', -yvec, {verts[1], verts[3], verts[2]}}, -- sides
			{verts[1], -zvec, 'FrontSurface', -yvec, {verts[1], verts[3], verts[5]}},
			--
			{verts[1],  slantVec1, 'BackSurface', xvec, {verts[1], verts[2], verts[4]}}, -- tops
			{verts[1],  slantVec2, 'LeftSurface', zvec, {verts[1], verts[5], verts[4]}},
		}

	elseif shape == 'Wedge' then
		local slantVec = (-zvec*sy + yvec*sz).Unit
		--6 vertices
		verts = {
			pos +xvec*sx  +yvec*sy  +zvec*sz, --top 2
			pos -xvec*sx  +yvec*sy  +zvec*sz,
			--
			pos +xvec*sx  -yvec*sy  +zvec*sz, --bottom 4
			pos +xvec*sx  -yvec*sy  -zvec*sz,
			pos -xvec*sx  -yvec*sy  +zvec*sz,
			pos -xvec*sx  -yvec*sy  -zvec*sz,
		}
		--9 edges
		edges = {
			{verts[1], verts[2], math.min(2*sy, 2*sz)}, --top 1
			--
			{verts[1], verts[4], math.min(2*sy, 2*sz)}, --slanted 2
			{verts[2], verts[6], math.min(2*sy, 2*sz)},
			--
			{verts[3], verts[4], math.min(2*sx, 2*sy)}, --bottom 4
			{verts[5], verts[6], math.min(2*sx, 2*sy)},
			{verts[3], verts[5], math.min(2*sy, 2*sz)},
			{verts[4], verts[6], math.min(2*sy, 2*sz)},
			--
			{verts[1], verts[3], math.min(2*sx, 2*sz)}, --vertical 2
			{verts[2], verts[5], math.min(2*sx, 2*sz)},
		}
		--5 faces
		faces = {
			{verts[1],  xvec, 'RightSurface', zvec, {verts[4], verts[1], verts[3]}}, --right
			{verts[2], -xvec, 'LeftSurface', zvec, {verts[2], verts[6], verts[5]}}, --left
			{verts[3], -yvec, 'BottomSurface', xvec, {verts[5], verts[6], verts[4], verts[3]}}, --bottom
			{verts[1],  zvec, 'BackSurface', xvec, {verts[1], verts[2], verts[5], verts[3]}}, --back
			{verts[2], slantVec, 'FrontSurface', slantVec:Cross(xvec), {verts[2], verts[1], verts[4], verts[6]}}, --slanted
		}
	elseif shape == 'Terrain' then
		assert(false, "Called GetGeometry on Terrain")
	else
		assert(false, "Bad shape: "..shape)
	end

	local geometry = {
		part = part;
		shape = (shape == 'Sphere' or shape == 'Cylinder') and shape or 'Mesh';
		vertices = verts;
		edges = edges;
		faces = faces;
		vertexMargin = math.min(sx, sy, sz) * 2;
	}

	local geomId = 0

	for _, dat in ipairs(faces) do
		geomId = geomId + 1
		dat.id = geomId
		dat.point = dat[1]
		dat.normal = dat[2]
		dat.surface = dat[3]
		dat.direction = dat[4]
		dat.vertices = dat[5]
		dat.part = part
		dat.type = 'Face'
		--avoid Event bug (if both keys + indicies are present keys are discarded when passing tables)
		dat[1], dat[2], dat[3], dat[4] = nil, nil, nil, nil
	end
	for _, dat in ipairs(edges) do
		geomId = geomId + 1
		dat.id = geomId
		dat.a, dat.b = dat[1], dat[2]
		dat.direction = (dat.b - dat.a).Unit
		dat.length = (dat.b - dat.a).Magnitude
		dat.edgeMargin = dat[3]
		dat.part = part
		dat.vertexMargin = geometry.vertexMargin
		dat.type = 'Edge'
		--avoid Event bug (if both keys + indicies are present keys are discarded when passing tables)
		dat[1], dat[2], dat[3] = nil, nil, nil
	end
	for i, dat in ipairs(verts) do
		geomId = geomId + 1
		verts[i] = {
			position = dat;
			id = geomId;
			type = 'Vertex';
		}
	end

	return geometry
end