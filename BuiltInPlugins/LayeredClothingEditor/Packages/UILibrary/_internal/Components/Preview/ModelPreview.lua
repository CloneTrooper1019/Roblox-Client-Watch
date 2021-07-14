--[[
	This component handles the model rendering and input support for model preview.

	Necessary properties:
	Position = UDim2
	Size = UDim2
	TargetModel = Model, the model is only for previewing. So, it contains the assetInstance with all he
	scripts being disabled.

	Optional properties:
	OnModelPreviewFrameEntered = callBack, we use those function to make sure input will be captured if
	mouse is within the area of the frame.
	OnModelPreviewFrameLeft = callBack
]]

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local getCamera = require(Library.Camera).getCamera

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local ModelPreview = Roact.PureComponent:extend("ModelPreview")

-- Used for the inital camera position
local INSERT_CAMERA_DIST_MULT = 0.8
local PAN_CAMERA_DIST_MULT = 0.1
local DOUBLE_CLICK_TIME = 0.25

function ModelPreview:init()
	self.orbitDrag = false
	self.panDrag = false
	self.doubleClickTimestamp = tick()

	-- Need reference to ViewportFrame so I can set the preview model to it.
	self.VFRef = Roact.createRef()

	self.modelPreviewCamera = getCamera(self)

	-- This is the model that will be displayed on the ViewportFrame.
	self.VFModel = nil

	self.onInputBegan = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.orbitDrag = true
		end

		if input.UserInputType == Enum.UserInputType.MouseButton3 or
			input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.panDrag = true
		end
	end

	self.onInputChanged = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			and self.orbitDrag or self.panDrag then
			local camera = self.modelPreviewCamera
			local targetFocus = camera.Focus
			local targetCF = targetFocus:ToObjectSpace(camera.CFrame)

			if self.orbitDrag then
				targetCF = CFrame.fromAxisAngle(targetCF.RightVector, input.Delta.y * -0.01) * targetCF
				targetCF = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), input.Delta.x * -0.01) * targetCF
			elseif self.panDrag then
				local dist = (targetCF.p - targetFocus.p).magnitude
				dist = dist ~= dist and 0 or dist -- NaN check
				local distanceFactor = PAN_CAMERA_DIST_MULT * (dist * 0.1)
				local yOffset = targetCF.upVector.Unit * input.Delta.y * distanceFactor
				local xOffset = -targetCF.rightVector.Unit * input.Delta.x * distanceFactor
				targetCF = targetCF + yOffset + xOffset
				targetFocus = targetFocus + yOffset + xOffset
			end

			camera.CFrame = camera.Focus:ToWorldSpace(targetCF)
			camera.Focus = targetFocus
		end
	end

	self.onInputEnded = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.orbitDrag = false
			if tick() < self.doubleClickTimestamp + DOUBLE_CLICK_TIME then
				self.centerCamera()
			end
			self.doubleClickTimestamp = tick()
		end

		if input.UserInputType == Enum.UserInputType.MouseButton3 or
			input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.panDrag = false
		end
	end

	self.zoomCamera = function(zoomIn)
		local zoomFactor = zoomIn and -1 or 1
		local camera = self.modelPreviewCamera
		local current = camera.CFrame
		local focus = camera.Focus

		local dist = (current.p - focus.p).magnitude
		dist = dist ~= dist and 0 or dist -- NaN check

		local moveAmount = math.max(dist * 0.1, 0.1)
		local targetCF = current * CFrame.new(0, 0, zoomFactor * moveAmount)

		camera.CFrame = targetCF
	end

	self.onMouseWheelBackward = function()
		self.zoomCamera(false)
	end

	self.onMouseWheelForward = function()
		self.zoomCamera(true)
	end

	self.centerCamera = function()
		local currentPreviewCopy = self.VFModel
		local camera = self.modelPreviewCamera

		-- Move the model/part in front of the camera
		local success, modelCf, size = pcall(function() return currentPreviewCopy:GetBoundingBox() end)
		if not success then
			size = currentPreviewCopy.Size
			currentPreviewCopy.CFrame = currentPreviewCopy.CFrame - currentPreviewCopy.CFrame.p
		else
			currentPreviewCopy:TranslateBy(-modelCf.p)
		end

		local cameraDistAway = size.magnitude * INSERT_CAMERA_DIST_MULT
		local dir = Vector3.new(1, 1, 1).Unit
		camera.Focus = CFrame.new()
		camera.CFrame = CFrame.new(cameraDistAway * dir, camera.Focus.p)
	end

	-- Because we are using refs and not using state, this component will not
	-- re-render unless we are viewing a different model. Every call to this
	-- function assumes that a different model has been selected.
	self.tryRenderModel = function()
		local myVRFrame = self.VFRef.current
		local currentPreviewCopy = self.VFModel
		myVRFrame:ClearAllChildren()
		currentPreviewCopy.Parent = myVRFrame

		self.centerCamera()
	end
end

function ModelPreview:makeViewportModel()
	local currentPreview = self.props.TargetModel
	if currentPreview:IsA("Model") or currentPreview:IsA("BasePart") then
		self.VFModel = currentPreview:Clone()
	else
		self.VFModel = Instance.new("Model")
		currentPreview:Clone().Parent = self.VFModel
	end
end

function ModelPreview:didMount()
	self:makeViewportModel()
	self.tryRenderModel()
end

function ModelPreview:didUpdate()
	self.tryRenderModel()
end

function ModelPreview:willUnmount()
	if self.VFModel then
		self.VFModel:Destroy()
	end
end

function ModelPreview:render()
	return withTheme(function(theme)
		local props = self.props
		local position = props.Position
		local size = props.Size or UDim2.new(1, 0, 1, 0)
		local ModelPreviewCamera = self.modelPreviewCamera

		local OnModelPreviewFrameEntered = props.OnModelPreviewFrameEntered
		local OnModelPreviewFrameLeft = props.OnModelPreviewFrameLeft

		local layoutOrder = props.LayoutOrder

		self:makeViewportModel()

		-- The element we return is determined by object we receive.
		return Roact.createElement("ViewportFrame", {
			Position = position, -- We should avoid using relative position and size.
			Size = size,

			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			BackgroundColor3 = theme.assetPreview.modelPreview.background,

			CurrentCamera = ModelPreviewCamera,
			[Roact.Ref] = self.VFRef,

			[Roact.Event.MouseEnter] = OnModelPreviewFrameEntered,
			[Roact.Event.MouseLeave] = OnModelPreviewFrameLeft,
			[Roact.Event.MouseWheelForward] = self.onMouseWheelForward,
			[Roact.Event.MouseWheelBackward] = self.onMouseWheelBackward,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.InputChanged] = self.onInputChanged,
			[Roact.Event.TouchPinch] = self.onTouchPinch,

			LayoutOrder = layoutOrder,
		})
	end)
end

return ModelPreview
