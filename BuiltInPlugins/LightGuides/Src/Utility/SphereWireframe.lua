local Plugin = script.Parent.Parent.Parent

local Types = require(Plugin.Src.Types)

local getFIntStudioLightGuideThickness = require(Plugin.Src.Flags.getFIntStudioLightGuideThickness)
local getFIntStudioLightGuideTransparency = require(Plugin.Src.Flags.getFIntStudioLightGuideTransparency)

local THICKNESS: number = getFIntStudioLightGuideThickness()
local TRANSPARENCY: number = getFIntStudioLightGuideTransparency()

type sphereWireframe = {
	_adornee: PVInstance,
	_parent: Instance,
	_light: Light,
	_handlesFolder: Folder,
	_guidesFolder: Folder,
	_handles: Types.Map<string, HandleAdornment>,
	_listener: RBXScriptConnection,
	_attachmentListener: RBXScriptConnection,
}

local SphereWireframe = {}
SphereWireframe.__index = SphereWireframe

function SphereWireframe.new()
	local self: sphereWireframe = {
		_adornee = nil,
		_parent = nil,
		_light = nil,
		_handlesFolder = Instance.new("Folder"),
		_guidesFolder = nil,
		_handles = {},
		_listener = nil,
		_attachmentListener = nil,
	}

	return setmetatable(self, SphereWireframe)
end

function SphereWireframe:render()
	self:_setAncestry()
	self:_setListeners()

	local enabled: boolean = self._light.Enabled
	local color: Vector3 = self._light.Color
	local radius: number = self._light.Range

	local axisAdornmentX = self._handles.AxisAdornmentX
	local axisAdornmentY = self._handles.AxisAdornmentY
	local axisAdornmentZ = self._handles.AxisAdornmentZ

	axisAdornmentX.Radius = radius
	axisAdornmentX.InnerRadius = radius - THICKNESS
	axisAdornmentX.Adornee = self._adornee
	axisAdornmentX.Visible = enabled
	axisAdornmentX.Color3 = color
	axisAdornmentX.CFrame = self._offset * CFrame.Angles(0, math.pi / 2, 0)

	axisAdornmentY.Radius = radius
	axisAdornmentY.InnerRadius = radius - THICKNESS
	axisAdornmentY.Adornee = self._adornee
	axisAdornmentY.Visible = enabled
	axisAdornmentY.Color3 = color
	axisAdornmentY.CFrame = self._offset * CFrame.Angles(math.pi / 2, 0, 0)

	axisAdornmentZ.Radius = radius
	axisAdornmentZ.InnerRadius = radius - THICKNESS
	axisAdornmentZ.Adornee = self._adornee
	axisAdornmentZ.Visible = enabled
	axisAdornmentZ.Color3 = color
	axisAdornmentZ.CFrame = self._offset
end

function SphereWireframe:pool()
	assert(self._handlesFolder, "Wireframe already pooled")
	assert(self._light, "Wireframe already pooled")

	self._handlesFolder.Name = "pooled"
	self._handlesFolder.Parent = nil
	self._light = nil

	self:_removeListeners()

	return self
end

function SphereWireframe:adorn(light)
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

function SphereWireframe:destroy()
	self:_removeHandles()
	self:_removeListeners()

	self._handlesFolder:Destroy()
	self._handlesFolder = nil
end

function SphereWireframe:setGuidesFolder(guidesFolder)
	self._guidesFolder = guidesFolder
end

function SphereWireframe:_setAncestry()
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

function SphereWireframe:setHandles()
	local axisAdornmentX = Instance.new("CylinderHandleAdornment")
	axisAdornmentX.Height = THICKNESS
	axisAdornmentX.Transparency = TRANSPARENCY
	axisAdornmentX.Parent = self._handlesFolder

	local axisAdornmentY = Instance.new("CylinderHandleAdornment")
	axisAdornmentY.Height = THICKNESS
	axisAdornmentY.Transparency = TRANSPARENCY
	axisAdornmentY.Parent = self._handlesFolder

	local axisAdornmentZ = Instance.new("CylinderHandleAdornment")
	axisAdornmentZ.Height = THICKNESS
	axisAdornmentZ.Transparency = TRANSPARENCY
	axisAdornmentZ.Parent = self._handlesFolder

	self._handles.AxisAdornmentX = axisAdornmentX
	self._handles.AxisAdornmentY = axisAdornmentY
	self._handles.AxisAdornmentZ = axisAdornmentZ
end

function SphereWireframe:_removeHandles()
	if self._handles then
		self._handles.AxisAdornmentX:Destroy()
		self._handles.AxisAdornmentY:Destroy()
		self._handles.AxisAdornmentZ:Destroy()
	end
end

function SphereWireframe:_setListeners()
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

function SphereWireframe:_removeListeners()
	if self._listener then
		self._listener:Disconnect()
	end

	if self._attachmentListener then
		self._attachmentListener:Disconnect()
	end

	self._listener = nil
	self._attachmentListener = nil
end

return SphereWireframe