--[[
	Renders a model with interactive preview features for panning and dragging.

	Required Props:
		Instance Model: The Instance to preview.

	Optional Props:
		Theme Theme: A Theme ContextItem, which is provided via mapToProps.
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		number LayoutOrder: LayoutOrder of the component.
		UDim2 Position: The position of this component.
		UDim2 Size: The size of this component.
		callback OnMouseEnter: called on MouseEnter - useful to delegate mouse scroll input to this component.
		callback OnMouseLeave: called on MouseLeave - useful to delegate mouse scroll input to this component.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local Util = require(Framework.Util)
local Typecheck = Util.Typecheck
local Math = Util.Math

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

local AssetRenderModel = Roact.PureComponent:extend("AssetRenderModel")
Typecheck.wrap(AssetRenderModel, script)

local INSERT_CAMERA_DIST_MULT = 0.8
local PAN_CAMERA_DIST_MULT = 0.1

-- TODO STM-169: Should we unify this with AssetConfig's PreviewArea component?
function AssetRenderModel:init()
	self.isOrbitDragging = false
	self.isPanDragging = false
	self.lastClickTime = 0

	self.viewportFrameRef = Roact.createRef()

	local camera = Instance.new("Camera")
	camera.Name = "AssetRenderModelCamera"
	self.camera = camera

	self.viewportFrameModel = nil

	self.onInputBegan = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.isOrbitDragging = true
		end

		if input.UserInputType == Enum.UserInputType.MouseButton3 or
			input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.isPanDragging = true
		end
	end

	self.onInputEnded = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.isOrbitDragging = false
			local DOUBLE_CLICK_INTERVAL_SECONDS = 0.25
			if tick() < self.lastClickTime + DOUBLE_CLICK_INTERVAL_SECONDS then
				self.centerCamera()
			end
			self.lastClickTime = tick()
		end

		if input.UserInputType == Enum.UserInputType.MouseButton3 or
			input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.isPanDragging = false
		end
	end

	self.onInputChanged = function(_, input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			and self.isOrbitDragging or self.isPanDragging then
			local camera = self.camera
			local targetFocus = camera.Focus
			local targetCF = targetFocus:ToObjectSpace(camera.CFrame)

			if self.isOrbitDragging then
				targetCF = CFrame.fromAxisAngle(targetCF.RightVector, input.Delta.y * -0.01) * targetCF
				targetCF = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), input.Delta.x * -0.01) * targetCF
			elseif self.isPanDragging then
				local dist = (targetCF.p - targetFocus.p).magnitude
				dist = Math.isNaN(dist) and 0 or dist
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

	self.zoomCamera = function(zoomFactor)
		local camera = self.camera
		local current = camera.CFrame
		local focus = camera.Focus

		local dist = (current.p - focus.p).magnitude
		dist = Math.isNaN(dist) and 0 or dist

		local moveAmount = math.max(dist * 0.1, 0.1)
		local targetCF = current * CFrame.new(0, 0, zoomFactor * moveAmount)

		camera.CFrame = targetCF
	end

	self.onMouseWheelBackward = function()
		self.zoomCamera(-1)
	end

	self.onMouseWheelForward = function()
		self.zoomCamera(1)
	end

	self.centerCamera = function()
		local model = self.viewportFrameModel
		local camera = self.camera

		-- Move the model/part in front of the camera
		local success, modelCf, size = pcall(function()
			return model:GetBoundingBox()
		end)

		if not success then
			size = model.Size
			model.CFrame = model.CFrame - model.CFrame.p
		else
			model:TranslateBy(-modelCf.p)
		end

		local cameraDistAway = size.magnitude * INSERT_CAMERA_DIST_MULT
		local dir = Vector3.new(1, 1, 1).Unit
		camera.Focus = CFrame.new()
		camera.CFrame = CFrame.new(cameraDistAway * dir, camera.Focus.p)
	end
end

function AssetRenderModel:updateViewportModel()
	local inputModel = self.props.Model

	if inputModel:IsA("Model") or inputModel:IsA("BasePart") then
		self.viewportFrameModel = inputModel:Clone()
	else
		self.viewportFrameModel = Instance.new("Model")
		inputModel:Clone().Parent = self.viewportFrameModel
	end

	local viewportFrame = self.viewportFrameRef:getValue()

	if viewportFrame then
		viewportFrame:ClearAllChildren()
		self.viewportFrameModel.Parent = viewportFrame

		self.centerCamera()
	end
end

function AssetRenderModel:didMount()
	self:updateViewportModel()
end

function AssetRenderModel:didUpdate(prevProps)
	if prevProps.Model ~= self.props.Model then
		self:updateViewportModel()
	end
end

function AssetRenderModel:willUnmount()
	if self.viewportFrameModel then
		self.viewportFrameModel:Destroy()
	end

	if self.camera then
		self.camera:Destroy()
	end
end

function AssetRenderModel:render()
	local props = self.props
	local layoutOrder = props.LayoutOrder
	local position = props.Position
	local size = props.Size or UDim2.new(1, 0, 1, 0)

	local camera = self.camera

	return Roact.createElement("ViewportFrame", {
		LayoutOrder = layoutOrder,
		Position = position,
		Size = size,

		BorderSizePixel = 0,
		BackgroundTransparency = 1,

		CurrentCamera = camera,
		[Roact.Ref] = self.viewportFrameRef,

		[Roact.Event.MouseEnter] = props.OnMouseEnter,
		[Roact.Event.MouseLeave] = props.OnMouseLeave,
		[Roact.Event.MouseWheelForward] = self.onMouseWheelForward,
		[Roact.Event.MouseWheelBackward] = self.onMouseWheelBackward,
		[Roact.Event.InputBegan] = self.onInputBegan,
		[Roact.Event.InputEnded] = self.onInputEnded,
		[Roact.Event.InputChanged] = self.onInputChanged,
	})
end

ContextServices.mapToProps(AssetRenderModel, {
	Stylizer = THEME_REFACTOR and ContextServices.Stylizer or nil,
	Theme = (not THEME_REFACTOR) and ContextServices.Theme or nil,
})

return AssetRenderModel
