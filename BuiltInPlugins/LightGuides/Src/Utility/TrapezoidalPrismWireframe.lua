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

type trapezoidalPrismWireframe = {
	_adornee: PVInstance,
	_parent: Instance,
	_light: Light,
	_handlesFolder: Folder,
	_guidesFolder: Folder,
	_handles: Types.Map<string, HandleAdornment>,
	_listener: RBXScriptConnection,
	_sizeListener: RBXScriptConnection,
	_attachmentListener: RBXScriptConnection,
}

local TrapezoidalPrismWireframe = {}
TrapezoidalPrismWireframe.__index = TrapezoidalPrismWireframe

function TrapezoidalPrismWireframe.new()
	local self: trapezoidalPrismWireframe = {
		_adornee = nil,
		_parent = nil,
		_light = nil,
		_handlesFolder = Instance.new("Folder"),
		_guidesFolder = nil,
		_handles = {},
		_listener = nil,
		_sizeListener = nil,
		_attachmentListener = nil,
	}

	return setmetatable(self, TrapezoidalPrismWireframe)
end

function TrapezoidalPrismWireframe:render()
	self:_setAncestry()
	self:_setListeners()

	local size = Vector3.new()

	if self._parent:IsA("BasePart") then
		size = self._parent.Size
	end

	local enabled: boolean = self._light.Enabled
	local color: Vector3 = self._light.Color
	local range: number = self._light.Range
	local angle: number = self._light.Angle
	local angleRad: number = math.rad(angle)
	local outerExtension: number = 2 * (range * math.tan(angleRad / 2))
	local normalVector: Vector3 = Vector3.fromNormalId(self._light.Face)
	local innerWidth: number = (
		size *
		(
			CFrame.Angles(
				0,
				(normalVector.Y - 1) * math.pi / 2,
				(normalVector.Z - 1) * (normalVector.X - 1) * math.pi / 2
			) * normalVector
		)
	).magnitude
	local innerHeight: number = (
		size *
		(
			CFrame.Angles(
				(normalVector.X - 1) * math.pi / 2,
				0,
				(normalVector.Z - 1) * (normalVector.Y - 1) * math.pi / 2
			) * normalVector
		)
	).magnitude
	local outerWidth: number = innerWidth + outerExtension
	local outerHeight: number = innerHeight + outerExtension
	local innerDepth: number = (size * Vector3.fromNormalId(self._light.Face)).magnitude

	local widthComponent: number = math.pow((outerWidth - innerWidth) / 2, 2)
	local heightComponent: number = math.pow((outerHeight - innerHeight) / 2, 2)
	local rangeComponent: number = math.pow(range, 2)
	local length: number = math.sqrt(widthComponent + heightComponent + rangeComponent)

	local innerTopOutline = self._handles.innerTopOutline
	local innerBottomOutline = self._handles.innerBottomOutline
	local innerLeftOutline = self._handles.innerLeftOutline
	local innerRightOutline = self._handles.innerRightOutline
	local outerTopOutline = self._handles.outerTopOutline
	local outerBottomOutline = self._handles.outerBottomOutline
	local outerLeftOutline = self._handles.outerLeftOutline
	local outerRightOutline = self._handles.outerRightOutline
	local topLeftOutline = self._handles.topLeftOutline
	local topRightOutline = self._handles.topRightOutline
	local bottomLeftOutline = self._handles.bottomLeftOutline
	local bottomRightOutline = self._handles.bottomRightOutline

	innerTopOutline.Height = innerWidth
	innerTopOutline.Adornee = self._adornee
	innerTopOutline.Visible = enabled
	innerTopOutline.Color3 = color

	innerBottomOutline.Height = innerWidth
	innerBottomOutline.Adornee = self._adornee
	innerBottomOutline.Visible = enabled
	innerBottomOutline.Color3 = color

	innerLeftOutline.Height = innerHeight
	innerLeftOutline.Adornee = self._adornee
	innerLeftOutline.Visible = enabled
	innerLeftOutline.Color3 = color

	innerRightOutline.Height = innerHeight
	innerRightOutline.Adornee = self._adornee
	innerRightOutline.Visible = enabled
	innerRightOutline.Color3 = color

	outerTopOutline.Height = outerWidth
	outerTopOutline.Adornee = self._adornee
	outerTopOutline.Visible = enabled
	outerTopOutline.Color3 = color

	outerBottomOutline.Height = outerWidth
	outerBottomOutline.Adornee = self._adornee
	outerBottomOutline.Visible = enabled
	outerBottomOutline.Color3 = color

	outerLeftOutline.Height = outerHeight
	outerLeftOutline.Adornee = self._adornee
	outerLeftOutline.Visible = enabled
	outerLeftOutline.Color3 = color

	outerRightOutline.Height = outerHeight
	outerRightOutline.Adornee = self._adornee
	outerRightOutline.Visible = enabled
	outerRightOutline.Color3 = color

	topLeftOutline.Height = length
	topLeftOutline.Adornee = self._adornee
	topLeftOutline.Visible = enabled
	topLeftOutline.Color3 = color

	topRightOutline.Height = length
	topRightOutline.Adornee = self._adornee
	topRightOutline.Visible = enabled
	topRightOutline.Color3 = color

	bottomLeftOutline.Height = length
	bottomLeftOutline.Adornee = self._adornee
	bottomLeftOutline.Visible = enabled
	bottomLeftOutline.Color3 = color

	bottomRightOutline.Height = length
	bottomRightOutline.Adornee = self._adornee
	bottomRightOutline.Visible = enabled
	bottomRightOutline.Color3 = color

	self:_setCFrameValues(
		ROTATION_MATRICES[self._light.Face],
		innerWidth,
		innerHeight,
		outerWidth,
		outerHeight,
		innerDepth,
		range
	)
end

function TrapezoidalPrismWireframe:pool()
	assert(self._handlesFolder, "Wireframe already pooled")
	assert(self._light, "Wireframe already pooled")

	self._handlesFolder.Name = "pooled"
	self._handlesFolder.Parent = nil
	self._light = nil

	self:_removeListeners()

	return self
end

function TrapezoidalPrismWireframe:adorn(light)
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

function TrapezoidalPrismWireframe:destroy()
	self:_removeHandles()
	self:_removeListeners()

	self._handlesFolder:Destroy()
	self._handlesFolder = nil
end

function TrapezoidalPrismWireframe:setGuidesFolder(guidesFolder)
	self._guidesFolder = guidesFolder
end

function TrapezoidalPrismWireframe:_setAncestry()
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

function TrapezoidalPrismWireframe:_setCFrameValues(
	rotationMatrix: CFrame,
	innerWidth: number,
	innerHeight: number,
	outerWidth: number,
	outerHeight: number,
	innerDepth: number,
	range: number
)
	local corner = math.atan(
		((outerWidth - innerWidth) / 2) * math.sqrt(2) / range
	)
	local halfPi: number = math.pi / 2
	local quarterPi: number = math.pi / 4
	local halfInnerHeight: number = innerHeight / 2
	local halfInnerDepth: number = innerDepth / 2
	local halfInnerWidth: number = innerWidth / 2
	local halfOuterHeight: number = outerHeight / 2
	local halfOuterWidth: number = outerWidth / 2
	local outerDepth: number = innerDepth / 2 + range
	local quarterInnerOuterWidth: number = (innerWidth + outerWidth) / 4
	local quarterInnerOuterHeight: number = (innerHeight + outerHeight) / 4
	local halfOuterDepth: number = (innerDepth + range) / 2

	self._handles.innerTopOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(0, halfInnerHeight, halfInnerDepth) *
		CFrame.Angles(0, halfPi, 0)
	)
	self._handles.innerBottomOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(0, -halfInnerHeight, halfInnerDepth) *
		CFrame.Angles(0, halfPi, 0)
	)
	self._handles.innerRightOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(halfInnerWidth, 0, halfInnerDepth) *
		CFrame.Angles(halfPi, 0, 0)
	)
	self._handles.innerLeftOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(-halfInnerWidth, 0, halfInnerDepth) *
		CFrame.Angles(halfPi, 0, 0)
	)
	self._handles.outerTopOutline.CFrame = (
		self._offset *
		rotationMatrix *
		CFrame.new(0, halfOuterHeight, outerDepth) *
		CFrame.Angles(0, halfPi, 0)
	)
	self._handles.outerBottomOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(0, -halfOuterHeight, outerDepth) *
		CFrame.Angles(0, halfPi, 0)
	)
	self._handles.outerLeftOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(halfOuterWidth, 0, outerDepth) *
		CFrame.Angles(halfPi, 0, 0)
	)
	self._handles.outerRightOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(-halfOuterWidth, 0, outerDepth) *
		CFrame.Angles(halfPi, 0, 0)
	)
	self._handles.topLeftOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(quarterInnerOuterWidth, quarterInnerOuterHeight, halfOuterDepth) *
		CFrame.Angles(0, 0, -quarterPi) *
		CFrame.Angles(-corner, 0, 0)
	)
	self._handles.topRightOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(-quarterInnerOuterWidth, quarterInnerOuterHeight, halfOuterDepth) *
		CFrame.Angles(0, 0, quarterPi) *
		CFrame.Angles(-corner, 0, 0)
	)
	self._handles.bottomLeftOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(quarterInnerOuterWidth, -quarterInnerOuterHeight, halfOuterDepth) *
		CFrame.Angles(0, 0, quarterPi) *
		CFrame.Angles(corner, 0, 0)
	)
	self._handles.bottomRightOutline.CFrame = self._offset * (
		rotationMatrix *
		CFrame.new(-quarterInnerOuterWidth, -quarterInnerOuterHeight, halfOuterDepth) *
		CFrame.Angles(0, 0, -quarterPi) *
		CFrame.Angles(corner, 0, 0)
	)
end

function TrapezoidalPrismWireframe:setHandles()	
	local innerTopOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	innerTopOutline.Radius = THICKNESS * 0.5
	innerTopOutline.Transparency = TRANSPARENCY
	innerTopOutline.Parent = self._handlesFolder

	local innerBottomOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	innerBottomOutline.Radius = THICKNESS * 0.5
	innerBottomOutline.Transparency = TRANSPARENCY
	innerBottomOutline.Parent = self._handlesFolder

	local innerLeftOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	innerLeftOutline.Radius = THICKNESS * 0.5
	innerLeftOutline.Transparency = TRANSPARENCY
	innerLeftOutline.Parent = self._handlesFolder

	local innerRightOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	innerRightOutline.Radius = THICKNESS * 0.5
	innerRightOutline.Transparency = TRANSPARENCY
	innerRightOutline.Parent = self._handlesFolder

	local outerTopOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	outerTopOutline.Radius = THICKNESS * 0.5
	outerTopOutline.Transparency = TRANSPARENCY
	outerTopOutline.Parent = self._handlesFolder

	local outerBottomOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	outerBottomOutline.Radius = THICKNESS * 0.5
	outerBottomOutline.Transparency	= TRANSPARENCY
	outerBottomOutline.Parent = self._handlesFolder

	local outerLeftOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	outerLeftOutline.Radius = THICKNESS * 0.5
	outerLeftOutline.Transparency = TRANSPARENCY
	outerLeftOutline.Parent = self._handlesFolder

	local outerRightOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	outerRightOutline.Radius = THICKNESS * 0.5
	outerRightOutline.Transparency = TRANSPARENCY
	outerRightOutline.Parent = self._handlesFolder

	local topLeftOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	topLeftOutline.Radius = THICKNESS * 0.5
	topLeftOutline.Transparency = TRANSPARENCY
	topLeftOutline.Parent = self._handlesFolder

	local topRightOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	topRightOutline.Radius = THICKNESS * 0.5
	topRightOutline.Transparency = TRANSPARENCY
	topRightOutline.Parent = self._handlesFolder

	local bottomLeftOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	bottomLeftOutline.Radius = THICKNESS * 0.5
	bottomLeftOutline.Transparency = TRANSPARENCY
	bottomLeftOutline.Parent = self._handlesFolder

	local bottomRightOutline: CylinderHandleAdornment = Instance.new("CylinderHandleAdornment")
	bottomRightOutline.Radius = THICKNESS * 0.5
	bottomRightOutline.Transparency = TRANSPARENCY
	bottomRightOutline.Parent = self._handlesFolder

	self._handles.innerTopOutline = innerTopOutline
	self._handles.innerBottomOutline = innerBottomOutline
	self._handles.innerLeftOutline = innerLeftOutline
	self._handles.innerRightOutline = innerRightOutline
	self._handles.outerTopOutline = outerTopOutline
	self._handles.outerBottomOutline = outerBottomOutline
	self._handles.outerLeftOutline = outerLeftOutline
	self._handles.outerRightOutline = outerRightOutline
	self._handles.topLeftOutline = topLeftOutline
	self._handles.topRightOutline = topRightOutline
	self._handles.bottomLeftOutline = bottomLeftOutline
	self._handles.bottomRightOutline = bottomRightOutline
end

function TrapezoidalPrismWireframe:_removeHandles()
	if self._handles then
		self._handles.innerTopOutline:Destroy()
		self._handles.innerBottomOutline:Destroy()
		self._handles.innerLeftOutline:Destroy()
		self._handles.innerRightOutline:Destroy()
		self._handles.outerTopOutline:Destroy()
		self._handles.outerBottomOutline:Destroy()
		self._handles.outerLeftOutline:Destroy()
		self._handles.outerRightOutline:Destroy()
		self._handles.topLeftOutline:Destroy()
		self._handles.topRightOutline:Destroy()
		self._handles.bottomLeftOutline:Destroy()
		self._handles.bottomRightOutline:Destroy()
	end
end

function TrapezoidalPrismWireframe:_setListeners()
	if not self._listener then
		self._listener = self._light.Changed:Connect(function()
			self:render()
		end)
	end

	if not self._sizeListener and not self._parent:IsA("Attachment") then
		self._sizeListener = self._parent:GetPropertyChangedSignal("Size"):Connect(function()
			self:render()
		end)
	end

	if not self._attachmentListener and self._parent:IsA("Attachment") then
		self._attachmentListener = self._parent:GetPropertyChangedSignal("CFrame"):Connect(function()
			self:render()
		end)
	end
end

function TrapezoidalPrismWireframe:_removeListeners()
	if self._listener then
		self._listener:Disconnect()
	end

	if self._sizeListener then
		self._sizeListener:Disconnect()
	end

	if self._attachmentListener then
		self._attachmentListener:Disconnect()
	end

	self._listener = nil
	self._sizeListener = nil
	self._attachmentListener = nil
end

return TrapezoidalPrismWireframe