local Plugin = script.Parent.Parent.Parent

local Types = require(Plugin.Src.Types)

local getFIntStudioLightGuideThickness = require(Plugin.Src.Flags.getFIntStudioLightGuideThickness)
local getFIntStudioLightGuideTransparency = require(Plugin.Src.Flags.getFIntStudioLightGuideTransparency)

local ROTATION_MATRICES: Types.Map<Enum.NormalId, CFrame> = {
	[Enum.NormalId.Back] = CFrame.fromMatrix(Vector3.new(), Vector3.new(1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, 1)),
	[Enum.NormalId.Front] = CFrame.fromMatrix(Vector3.new(), Vector3.new(-1, 0, 0), Vector3.new(0, 1, 0), Vector3.new(0, 0, -1)),
	[Enum.NormalId.Right] = CFrame.fromMatrix(Vector3.new(), Vector3.new(0, 0, -1), Vector3.new(0, 1, 0), Vector3.new(1, 0, 0)),
	[Enum.NormalId.Left] = CFrame.fromMatrix(Vector3.new(), Vector3.new(0, 0, 1), Vector3.new(0, 1, 0), Vector3.new(-1, 0, 0)),
	[Enum.NormalId.Bottom] = CFrame.fromMatrix(Vector3.new(), Vector3.new(1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, -1, 0)),
	[Enum.NormalId.Top] = CFrame.fromMatrix(Vector3.new(), Vector3.new(1, 0, 0), Vector3.new(0, 0, -1), Vector3.new(0, 1, 0)),
}
local THICKNESS: number = getFIntStudioLightGuideThickness()
local TRANSPARENCY: number = getFIntStudioLightGuideTransparency()

type coneWireframe = {
	_adornee: PVInstance,
	_parent: Instance,
	_light: Light,
	_handlesFolder: Folder,
	_guidesFolder: Folder,
	_handles: Types.Map<string, HandleAdornment>,
	_listener: RBXScriptConnection,
	_attachmentListener: RBXScriptConnection,
}

local ConeWireframe = {}
ConeWireframe.__index = ConeWireframe

function ConeWireframe.new()
	local self: coneWireframe = {
		_adornee = nil,
		_parent = nil,
		_light = nil,
		_handlesFolder = Instance.new("Folder"),
		_guidesFolder = nil,
		_handles = {},
		_listener = nil,
		_attachmentListener = nil,
	}

	return setmetatable(self, ConeWireframe)
end

function ConeWireframe:render()
	self:_setAncestry()
	self:_setListeners()


	local enabled: boolean = self._light.Enabled
	local range: number = self._light.Range
	local angle: number = self._light.Angle
	local angleRad: number = math.rad(angle)
	local color: Vector3 = self._light.Color
	local radius: number = range * math.tan(angleRad / 2)
	local length: number = range / math.cos(angleRad / 2)

	local spot = self._handles.Spot
	local left = self._handles.Left
	local right = self._handles.Right
	local top = self._handles.Top
	local bottom = self._handles.Bottom

	spot.Adornee = self._adornee
	spot.Radius = radius
	spot.InnerRadius = radius - THICKNESS
	spot.Visible = enabled
	spot.Color3 = color

	left.Height = length
	left.Adornee = self._adornee
	left.Visible = enabled
	left.Color3 = color

	right.Height = length
	right.Adornee = self._adornee
	right.Visible = enabled
	right.Color3 = color

	top.Height = length
	top.Adornee = self._adornee
	top.Visible = enabled
	top.Color3 = color

	bottom.Height = length
	bottom.Adornee = self._adornee
	bottom.Visible = enabled
	bottom.Color3 = color

	self:_setCFrameValues(ROTATION_MATRICES[self._light.Face], radius, range, angleRad)
end

function ConeWireframe:pool()
	assert(self._handlesFolder, "Wireframe already pooled")
	assert(self._light, "Wireframe already pooled")

	self._handlesFolder.Name = "pooled"
	self._handlesFolder.Parent = nil
	self._light = nil

	self:_removeListeners()

	return self
end

function ConeWireframe:adorn(light)
	assert(light, "Can't adorn nil")
	assert(not self._light, "Wireframe already adorned")

	self._light = light
	self._handlesFolder.Name = light.name
	self._handlesFolder.Parent = self._guidesFolder
	self._adornee = light.Parent
	self._parent = light.Parent

	self:_setListeners()

	return self
end

function ConeWireframe:destroy()
	self:_removeHandles()
	self:_removeListeners()

	self._handlesFolder:Destroy()
	self._handlesFolder = nil
end

function ConeWireframe:setGuidesFolder(guidesFolder)
	self._guidesFolder = guidesFolder
end

function ConeWireframe:_setAncestry()
	local adornee: Instance = self._light.parent
	local offset: CFrame = CFrame.new(Vector3.new())

	if adornee:IsA("Attachment") then
		adornee = self._light.parent.parent
		offset = self._light.parent.CFrame
	end

	self._adornee = adornee
	self._offset = offset
	self._parent = self._light.Parent
end

function ConeWireframe:_setCFrameValues(rotationMatrix, radius, range, angleRad)
	if self._handles then
		local hradius: number = radius / 2
		local hrange: number = range / 2
		local hangle: number = angleRad / 2

		self._handles.Spot.CFrame = self._offset * (rotationMatrix * CFrame.new(0, 0, range))
		self._handles.Left.CFrame = self._offset * (rotationMatrix *
			CFrame.new(hradius, 0, hrange) * CFrame.Angles(0, hangle, 0))
		self._handles.Right.CFrame = self._offset * (rotationMatrix *
			CFrame.new(-hradius, 0, hrange) * CFrame.Angles(0, -hangle, 0))
		self._handles.Top.CFrame = self._offset * (rotationMatrix *
			CFrame.new(0, hradius, hrange) * CFrame.Angles(-hangle, 0 , 0))
		self._handles.Bottom.CFrame = self._offset * (rotationMatrix *
			CFrame.new(0, -hradius, hrange) * CFrame.Angles(hangle, 0, 0))
	end
end

function ConeWireframe:setHandles()
	local spot = Instance.new("CylinderHandleAdornment")
	spot.Transparency = TRANSPARENCY
	spot.Height = THICKNESS
	spot.Transparency = TRANSPARENCY
	spot.Parent = self._handlesFolder

	local left: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	left.Radius = THICKNESS / 2
	left.Transparency = TRANSPARENCY
	left.Parent = self._handlesFolder

	local right: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	right.Radius = THICKNESS / 2
	right.Transparency = TRANSPARENCY
	right.Parent = self._handlesFolder

	local top: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	top.Radius = THICKNESS / 2
	top.Transparency = TRANSPARENCY
	top.Parent = self._handlesFolder

	local bottom: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	bottom.Radius = THICKNESS / 2
	bottom.Transparency = TRANSPARENCY
	bottom.Parent = self._handlesFolder

	self._handles.Spot = spot
	self._handles.Left = left
	self._handles.Right = right
	self._handles.Top = top
	self._handles.Bottom = bottom
end

function ConeWireframe:_removeHandles()
	if self._handles then
		self._handles.Spot:Destroy()
		self._handles.Left:Destroy()
		self._handles.Right:Destroy()
		self._handles.Top:Destroy()
		self._handles.Bottom:Destroy()
	end
end

function ConeWireframe:_setListeners()
	if not self._listener then
		self._listener = self._light.Changed:Connect(function()
			self:render()
		end)
	end

	if not self._attachmentListener and self._parent:IsA("Attachment") then
		self._attachmentListener = self._parent:GetPropertyChangedSignal("CFrame"):Connect(function()
			self:render()
		end)
	end
end

function ConeWireframe:_removeListeners()
	if self._listener then
		self._listener:Disconnect()
	end

	if self._attachmentListener then
		self._attachmentListener:Disconnect()
	end

	self._listener = nil
	self._attachmentListener = nil
end

return ConeWireframe