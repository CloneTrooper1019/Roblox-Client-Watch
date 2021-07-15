local Plugin = script.Parent.Parent.Parent

local Framework = require(Plugin.Packages.Framework)

local FrameworkUtil = Framework.Util
local Signal = FrameworkUtil.Signal

local AxisLockedDragger = require(script.Parent.AxisLockedDragger)

local MAX_DRAG = 16000
local MIN_DRAG = 4

local BORDER_BLOCKMESH = "BorderMesh"
local BORDER_THICKNESS = 8
local NORMALS = Enum.NormalId:GetEnumItems()

local LargeVoxelRegionPreview = {}
LargeVoxelRegionPreview.__index = LargeVoxelRegionPreview

function LargeVoxelRegionPreview.new(mouse, target)
	local self = setmetatable({
		_mouse = mouse,
		_target = target,
		_position = Vector3.new(),
		_size = Vector3.new(4, 4, 4),
		_onSizeChanged = Signal.new(),
	}, LargeVoxelRegionPreview)

	assert(self._mouse, "Mouse missing in LargeVoxelRegionPreview")

	-- function is used to verify new position of adorns when dragging
	local function getDraggerClamp(movingAdorn, stationaryAdorn)
		return function(newPosition)
			-- Check if we've already deactivated the the region preview
			if not self._adorns or not self._adorns[movingAdorn] or not self._adorns[stationaryAdorn] then
				return newPosition
			end

			local movingPos = self._adorns[movingAdorn]:getPosition()
			local stationaryPos = self._adorns[stationaryAdorn]:getPosition()

			-- minimum dist Check
			local axis = movingPos - stationaryPos
			local distance = axis.Unit:Dot(newPosition - stationaryPos)
			if distance < MIN_DRAG then
				-- recalc delta vector to drop position in the correct spot
				return stationaryPos + axis.Unit * MIN_DRAG
			elseif distance > MAX_DRAG then
				return stationaryPos + axis.Unit * MAX_DRAG
			end

			local regionPos = (newPosition + stationaryPos)/2
			self._position = regionPos

			local sizeDiff = (newPosition - stationaryPos)
			local magnitude = sizeDiff.Magnitude

			local x = sizeDiff.x ~= 0 and magnitude or self._size.x
			local y = sizeDiff.y ~= 0 and magnitude or self._size.y
			local z = sizeDiff.z ~= 0 and magnitude or self._size.z
			self._size = Vector3.new(x, y, z)

			self._onSizeChanged:Fire(self._size, self._position)

			self:updateBlockMesh()
			self:updateAdorns()
			return newPosition
		end
	end

	-- maps to Enum.NormalId,=
	self._adorns = {}
	self._adorns[Enum.NormalId.Right] = AxisLockedDragger.new(
		mouse, Vector3.new(0,0,0), Vector3.new(1,0,0),
		getDraggerClamp(Enum.NormalId.Right, Enum.NormalId.Left))
	self._adorns[Enum.NormalId.Left] = AxisLockedDragger.new(
		mouse, Vector3.new(0,0,0), Vector3.new(-1,0,0),
		getDraggerClamp(Enum.NormalId.Left, Enum.NormalId.Right))

	self._adorns[Enum.NormalId.Top] = AxisLockedDragger.new(
		mouse, Vector3.new(0,0,0), Vector3.new(0,1,0),
		getDraggerClamp(Enum.NormalId.Top, Enum.NormalId.Bottom))
	self._adorns[Enum.NormalId.Bottom] = AxisLockedDragger.new(
		mouse, Vector3.new(0,0,0), Vector3.new(0,-1,0),
		getDraggerClamp(Enum.NormalId.Bottom, Enum.NormalId.Top))

	self._adorns[Enum.NormalId.Front] = AxisLockedDragger.new(
		mouse, Vector3.new(0,0,0), Vector3.new(0,0,1),
		getDraggerClamp(Enum.NormalId.Front, Enum.NormalId.Back))
	self._adorns[Enum.NormalId.Back] = AxisLockedDragger.new(
		mouse, Vector3.new(0,0,0), Vector3.new(0,0,-1),
		getDraggerClamp(Enum.NormalId.Back, Enum.NormalId.Front))

	self._borders = {}


	return self
end

function LargeVoxelRegionPreview:getOnSizeChanged()
	return self._onSizeChanged
end

function LargeVoxelRegionPreview:destroy()
	if self._rootModel then
		self._rootModel:Destroy()
		self._rootModel = nil
	end

	if self._centerPart then
		self._centerPart:Destroy()
		self._centerPart = nil
	end

	if self._blockMesh then
		self._blockMesh:Destroy()
		self._blockMesh = nil
	end

	for _, adorn in pairs(self._adorns) do
		adorn:destroy()
	end
	self._adorns = nil

	for _, border in pairs(self._borders) do
		border:Destroy()
	end
	self._borders = nil
end

function LargeVoxelRegionPreview:updateVisibility(isVisible)
	if self._centerPart then
		self._centerPart.Transparency = isVisible and .9 or 1
	end

	for _, border in pairs(self._borders) do
		border.Transparency = isVisible and .5 or 1
	end

	for _, adorn in pairs(self._adorns) do
		adorn:updateVisibility(isVisible)
	end
end

-- creates and updates existing tiles
function LargeVoxelRegionPreview:updateBlockMesh(isVisible)
	if not self._rootModel then
		local rootModel = Instance.new("Model")
		rootModel.Name = "RegionPreview"
		rootModel.Archivable = false
		self._rootModel = rootModel
		self._rootModel.Parent = self._target
	end

	if not self._centerPart then
		local centerPart = Instance.new("Part")
		centerPart.Name = "RegionCenter"
		centerPart.Size = Vector3.new(1, 1, 1)
		centerPart.TopSurface = 'Smooth'
		centerPart.BottomSurface = 'Smooth'
		centerPart.CastShadow = false
		centerPart.Locked = true
		centerPart.Anchored = true
		centerPart.CanCollide = false
		centerPart.BrickColor = BrickColor.new('Toothpaste')
		centerPart.Material = Enum.Material.Neon
		centerPart.Archivable = false
		centerPart.Transparency = 1

		local blockMesh = Instance.new("BlockMesh")
		blockMesh.Scale = Vector3.new(1,1,1)
		blockMesh.Parent = centerPart

		self._blockMesh = blockMesh
		self._centerPart = centerPart
	end

	self._centerPart.Position = self._position
	self._centerPart.Parent = self._rootModel
	self._blockMesh.Scale = self._size
end

function LargeVoxelRegionPreview:updateAdorns()
	local position = self._position
	local size = self._size
	local extents = size / 2

	self._adorns[Enum.NormalId.Right]:setPosition(position + Vector3.new(extents.x, 0, 0)) -- PosX
	self._adorns[Enum.NormalId.Left]:setPosition(position + Vector3.new(-extents.x, 0, 0)) -- NegX
	self._adorns[Enum.NormalId.Top]:setPosition(position + Vector3.new(0, extents.y, 0)) -- PosY
	self._adorns[Enum.NormalId.Bottom]:setPosition(position + Vector3.new(0, -extents.y, 0)) -- NegY
	self._adorns[Enum.NormalId.Front]:setPosition(position + Vector3.new(0, 0, extents.z)) -- PosZ
	self._adorns[Enum.NormalId.Back]:setPosition(position + Vector3.new(0, 0, -extents.z)) -- NegZ
end

-- these operations only work because the normals are axis aligned
function LargeVoxelRegionPreview:updateBorder(normID1, normID2)
	assert(self._adorns[normID1] and self._adorns[normID2], "accessing invalid terrain")
	local key = string.format("%d_%d", normID1.Value, normID2.Value)
	local pos1 = self._adorns[normID1]:getPosition() - self._position
	local pos2 = self._adorns[normID2]:getPosition() - self._position
	local offset = pos1 + pos2
	if offset.Magnitude < 1 then
		return
	end

	local scale = Vector3.new(
		offset.x == 0 and self._size.x or BORDER_THICKNESS,
		offset.y == 0 and self._size.y or BORDER_THICKNESS,
		offset.z == 0 and self._size.z or BORDER_THICKNESS
	)
	offset = offset + self._position

	if not self._borders[key] then
		local borderRoot = Instance.new("Part")
		borderRoot.Name = "RegionBorder"
		borderRoot.Size = Vector3.new(1, 1, 1)
		borderRoot.TopSurface = 'Smooth'
		borderRoot.BottomSurface = 'Smooth'
		borderRoot.Locked = true
		borderRoot.Anchored = true
		borderRoot.CanCollide = false
		borderRoot.BrickColor = BrickColor.new('Toothpaste')
		borderRoot.Material = Enum.Material.Neon
		borderRoot.Archivable = false
		borderRoot.Transparency = 1
		borderRoot.CastShadow = false

		borderRoot.Parent = self._rootModel
		self._borders[key] = borderRoot

		local border = Instance.new("BlockMesh")
		border.Name = BORDER_BLOCKMESH
		border.Parent = borderRoot
	end

	self._borders[key][BORDER_BLOCKMESH].Scale = scale
	self._borders[key].Position = offset
end

-- should be called after adorn positions have been updated
function LargeVoxelRegionPreview:updateBorders()
	if not self._centerPart then
		self:updateBlockMesh()
	end

	-- iterate through permutations of normals to get
	-- the line that intersects both planes
	for i = 1, #NORMALS-1 do
		for j = i+1, #NORMALS do
			self:updateBorder(NORMALS[i], NORMALS[j])
		end
	end

end

function LargeVoxelRegionPreview:setSizeAndPosition(size, position)
	self._position = position
	self._size = size

	self:updateBlockMesh()
	self:updateAdorns()
	self:updateBorders()
end

return LargeVoxelRegionPreview
