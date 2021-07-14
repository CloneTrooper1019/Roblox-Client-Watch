--!nocheck

-----------------------------------
-----------MODULE SCRIPTS----------
-----------------------------------

local Metapart = require(script.Parent.Metapart)
local Input = require(script.Parent.Input)
local Utility = require(script.Parent.Utility)
local RecyclingBin = require(script.Parent.RecyclingBin)

-----------------------------------
-------------FAST FLAGS------------
-----------------------------------

local getFFlagFixTransformScalingSpheresAndCylinders =
	require(script.Parent.Flags.getFFlagFixTransformScalingSpheresAndCylinders)

-----------------------------------
--------------VARIABLES------------
-----------------------------------

local adornKeeper = {}
local shadowKeeper = {}
local planeKeeper = {}

local cg = game:GetService("CoreGui")
local tempAdorns = Instance.new("Folder",cg)
tempAdorns.Name = "TransformTempAdornments"

local initialized = false

local workplaneAccessor = nil

local strayAdornee = nil

--measure
local measureFrame1 = nil
local measureLabel1 = nil
local unitLabel1 = nil

local measureFrame2 = nil
local measureLabel2 = nil
local unitLabel2 = nil

local measureLine = {}
local measureCone = {}

local planeOriginLines = {}

local rotateLines = {}

local rotateAxisLine = {}

local renderRotation = false
local internalRotate = false

local planeHoverTransition = false
local currentPlaneHoverTransitionLevel = 0
local planeHoverTransitionSpeed = 0.1

local planeSelectionActive = false

local miniPlaneLines = {}

local shadowTransparency = 0.7
local shadowTransparencyHover = 0.2

local oneDegrees = "rbxasset://textures/transformOneDegree.png"
local fiveDegrees = "rbxasset://textures/transformFiveDegrees.png"
local oneEigthDegrees = "rbxasset://textures/transformTwentyTwoDegrees.png"
local ninetyDegrees = "rbxasset://textures/transformNinetyDegrees.png"
local planeImage = "rbxasset://textures/whiteCircle.png"
local rotationArrow = "rbxasset://textures/rotationArrow.png"
local gradient = "rbxasset://textures/gradient.png"

--duplicate - please consolidate
local H_NONE = 0
local T_Y_POS = 1
local S_X_POS = 2
local S_X_NEG = 3
local S_Z_POS = 4
local S_Z_NEG = 5
local S_Y_POS = 6
local S_X_POS_Z_POS = 7
local S_X_POS_Z_NEG = 8
local S_X_NEG_Z_POS = 9
local S_X_NEG_Z_NEG = 10
local R_XY = 11 -- 3
local R_XZ = 12 -- 2
local R_YZ = 13 -- 1
local H_PLANE = 14

local currentHandle = H_NONE

local hoveredHandles = {}

local yScale = 1

local TYPE_STUDS = 1
local TYPE_DEGREES = 2

-----------------------------------
--------------FUNCTIONS------------
-----------------------------------

local function setUnitText(measureFrame, measureLabel, unitLabel, str, unitType)
	if not measureFrame then return end
	
	measureLabel.Text = str
	measureLabel.Size = UDim2.new(0, measureLabel.TextBounds.X, 0, measureLabel.TextBounds.Y)
	measureLabel.Position = UDim2.new(0, 3, 0, 0)
	
	unitLabel.Text = unitType == TYPE_STUDS and "studs" or "o"
	unitLabel.Size = UDim2.new(0, unitLabel.TextBounds.X, 0, unitLabel.TextBounds.Y)
	unitLabel.Position = UDim2.new(0, measureLabel.TextBounds.X + 4, 0, unitType == TYPE_STUDS and 7 or 0)
	
	measureFrame.Size = UDim2.new(0, measureLabel.TextBounds.X + unitLabel.TextBounds.X + 7, 0, measureLabel.TextBounds.Y + 2)
end

local function setLinePosition(cone1, cone2, line1, line2, line3, point1, point2, direction)
	cone1.CFrame = CFrame.new(point2, point1) - point2 + point1 + ((point2 - point1).unit * cone1.Height) + direction
	cone2.CFrame = CFrame.new(point1, point2) - point1 + point2 - ((point2 - point1).unit * cone2.Height) + direction
	line1.CFrame = CFrame.new(point1 + direction, point2 + direction)
	line1.Length = (point1 - point2).magnitude
	
	line2.CFrame = CFrame.new(point1, point1 + direction)
	line2.Length = direction.magnitude
	line3.CFrame = CFrame.new(point2, point2 + direction)
	line3.Length = direction.magnitude
end

local rotationBin = Instance.new("Folder",tempAdorns)
rotationBin.Name = "Rotation"

local function clearRotation()
	local children = rotationBin:GetChildren()
	if #children > 0 then
		RecyclingBin:RecycleObjects(children)
	end
end

local function setRotation(cframe, radius, degrees)
	if degrees == 0 then
		clearRotation()
		return
	end
	
	local direction = degrees / math.abs(degrees)
	
	local flip = cframe:pointToObjectSpace(game.Workspace.Camera.CoordinateFrame.p).Z > 0
	
	if flip then
		direction = direction * -1
	end
		
	if not internalRotate then
		if direction > 0 then
			degrees = math.floor(degrees)
		else
			degrees = math.ceil(degrees)
		end
		
		radius = radius * 1.15
	end
	
	local amount = math.abs(degrees)
	local pending = {}
	local function pendIt(image)
		table.insert(pending,{
			CFrame = cframe:toWorldSpace(CFrame.Angles(flip and math.rad(180) or 0,0, math.rad(amount * direction)) * CFrame.new(Vector3.new(-radius * 0.5, radius * 0.5, 0)));
			Image = image;
		})
	end
	
		
	while amount >= 90 do
		--add 90
		if direction < 0 then
			amount = amount - 90
		end
		
		pendIt(ninetyDegrees)
		
		if direction > 0 then
			amount = amount - 90
		end
	end
	
	while internalRotate and amount >= 22.5 do
		--add 90
		if direction < 0 then
			amount = amount - 22.5
		end
		
		pendIt(oneEigthDegrees)
		
		if direction > 0 then
			amount = amount - 22.5
		end
	end
	
	while amount >= 5 do
		if direction < 0 then
			amount = amount - 5
		end
		
		pendIt(fiveDegrees)
		
		if direction > 0 then
			amount = amount - 5
		end
	end
	
	while amount >= 1 do
		if direction < 0 then
			amount = amount - 1
		end
		
		pendIt(oneDegrees)

		if direction > 0 then
			amount = amount - 1
		end
	end
	
	local imageAdorns = RecyclingBin:Allocate("ImageHandleAdornment",#pending,rotationBin)
	for i,data in ipairs(pending) do
		local im = imageAdorns[i]
		im.Adornee = strayAdornee
		im.ZIndex = 1
		im.AlwaysOnTop = true
		im.Size = Vector2.new(radius, radius)
		im.Color3 = Color3.new(1, 0, 0)
		im.Transparency = 0.6
		im.CFrame = data.CFrame
		im.Image = data.Image
	end
end

local rotationFrame = nil
local rotationRadius = nil
local rotationDegrees = nil

local function setRotatePosition(cframe, radius, degrees)
	renderRotation = true
	local largeLineLength = radius / 10
	local smallLineLength = largeLineLength / 2
	for i = 1, 72 do
		rotateLines[i].Length = ((i - 1) % 9 == 0) and largeLineLength or smallLineLength
		local angle = (i - 1) * 5
		local direction = Vector3.new(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0) * radius
		rotateLines[i].Transparency = internalRotate and .4 or 0
		rotateLines[i].CFrame = cframe:toWorldSpace(CFrame.new(direction, direction * 2))
	
	end
	
	for i = 73, 88 do
		rotateLines[i].Length = largeLineLength
		local angle = (i - 73) * 22.5
		local direction = Vector3.new(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0) * radius
		rotateLines[i].Transparency = internalRotate and 0 or .4
		rotateLines[i].CFrame = cframe:toWorldSpace(CFrame.new(direction, direction * 0.5))
	end
	
	rotationFrame = cframe
	rotationRadius = radius
	rotationDegrees = degrees
end

local startRadius = 0.3

local function setPlaneFrame(cframe)
	planeOriginLines[1].CFrame = cframe:toWorldSpace(CFrame.new(Vector3.new(0, startRadius, 0), Vector3.new(0, 2, 0)))
	planeOriginLines[2].CFrame = cframe:toWorldSpace(CFrame.new(Vector3.new(0, -startRadius, 0), Vector3.new(0, -2, 0)))
	planeOriginLines[3].CFrame = cframe:toWorldSpace(CFrame.new(Vector3.new(startRadius, 0, 0), Vector3.new(2, 0, 0)))
	planeOriginLines[4].CFrame = cframe:toWorldSpace(CFrame.new(Vector3.new(-startRadius, 0, 0), Vector3.new(-2, 0, 0)))
	planeOriginLines[5].CFrame = cframe:toWorldSpace(CFrame.new(Vector3.new(0, 0, startRadius), Vector3.new(0, 0, 2)))
	planeOriginLines[6].CFrame = cframe:toWorldSpace(CFrame.new(Vector3.new(0, 0, -startRadius), Vector3.new(0, 0, -2)))
end

local initialPlaneClick = false
local currentlyOverHandle = false

local function hoverEnterHandle(handle)
	hoveredHandles[handle] = true
	if not adornKeeper[handle][2].Visible or Input.getButtonState(Input.Enum.Key.MOUSE_BUTTON1)  then return end
	if handle == currentHandle then currentlyOverHandle = true end
	if handle >= currentHandle and currentHandle ~= H_NONE then return end
	
	if handle == H_PLANE then
		planeHoverTransition = true
	else
		if not planeSelectionActive then
			adornKeeper[handle][2].Color3 = adornKeeper[handle][4][1]
			adornKeeper[handle][2].Transparency = adornKeeper[handle][4][2]
			if shadowKeeper[handle] then
				shadowKeeper[handle].Color3 = adornKeeper[handle][4][1]
				shadowKeeper[handle].Transparency = shadowTransparencyHover
			end
		end
	end
	currentHandle = handle
	currentlyOverHandle = true
end

local function resetHandle(handle)
	adornKeeper[handle][2].Color3 = adornKeeper[handle][5][1]
	adornKeeper[handle][2].Transparency = adornKeeper[handle][5][2]
	if shadowKeeper[handle] then
		shadowKeeper[handle].Color3 = Color3.new(0, 0, 0)
		shadowKeeper[handle].Transparency = shadowTransparency
	end
end
local function hoverLeaveHandle(handle)
	hoveredHandles[handle] = nil
	if handle == currentHandle then currentlyOverHandle = false end
	if Input.getButtonState(Input.Enum.Key.MOUSE_BUTTON1) then return end
	if handle == H_PLANE then
		planeHoverTransition = false
	else
		resetHandle(handle)
	end
	
	local finalHandle = H_NONE
	
	for k, v in pairs(hoveredHandles) do
		if v then finalHandle = k end
	end	
	
	currentHandle = H_NONE
	if finalHandle ~= H_NONE then
		if (finalHandle == H_PLANE) then
			hoveredHandles[H_PLANE] = nil
			return
		end
		hoverEnterHandle(finalHandle)
	end
end

local function planeInputBegan(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		
		initialPlaneClick = true
	end
end

local function planeInputEnded(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if currentHandle == H_PLANE and initialPlaneClick then
			planeSelectionActive = not planeSelectionActive
		end
		initialPlaneClick = false
	end
end

local function InitializeBoxAdorn(offset, size, color, top, zIndex)
	if zIndex == nil then zIndex = 0 end
	
	local tmpBoxAdorn = Instance.new("BoxHandleAdornment", cg)
	tmpBoxAdorn.SizeRelativeOffset = offset
	tmpBoxAdorn.Size = size
	tmpBoxAdorn.Color3 = color
	tmpBoxAdorn.AlwaysOnTop = top
	tmpBoxAdorn.ZIndex = zIndex
	return tmpBoxAdorn
end

local function InitializeImageAdorn(offset, size, color, top, zIndex, cFrame, visible, image)
	local imageAdorn = Instance.new("ImageHandleAdornment", cg)
	imageAdorn.Image = image
	imageAdorn.SizeRelativeOffset = offset
	imageAdorn.Size = size
	imageAdorn.CFrame = cFrame
	imageAdorn.Color3 = color[1]
	imageAdorn.ZIndex = zIndex
	imageAdorn.Transparency = color[2]
	imageAdorn.AlwaysOnTop = top
	imageAdorn.Visible = visible
	return imageAdorn
end

local function InitializeConeAdorn(offset, size, color, top, zIndex, cFrame)
	local coneAdorn = Instance.new("ConeHandleAdornment", cg)
	coneAdorn.SizeRelativeOffset = offset
	coneAdorn.CFrame = cFrame
	coneAdorn.Height = size.X
	coneAdorn.Radius = size.Y
	coneAdorn.Color3 = color[1]
	coneAdorn.ZIndex = zIndex
	coneAdorn.AlwaysOnTop = top
	return coneAdorn
end

local lightBlue = Color3.new(38.0 / 255.0, 136.0 / 255.0, 240.0 / 255.0)
local darkBlue = Color3.new(21/255, 26/255, 89/255)
local black = Color3.new(0, 0, 0)
local white = Color3.new(1, 1, 1)
local yellow = Color3.new(239/255,230/255,64/255)
local grey = Color3.new(184/255, 184/255, 184/255)

local rbxBlue = Color3.new(0, 162/255, 1)
local rbxGreen = Color3.new(63/255, 198/255, 121/255)
local rbxRed = Color3.new(226/255,35/255,26/255)

local red = BrickColor.Red().Color

local BOX_ADORN = 0
local OUTLINE_BOX_ADORN = 1
local CONE_ADORN = 2
local IMAGE_ADORN = 3

local function createAdorn(type, name, hoverColor, offColor, outerSize, innerSize, offset, cframe, image)
	if cframe == nil then cframe = CFrame.new() end
	if type == BOX_ADORN then
		local boxAdorn = InitializeBoxAdorn(offset, outerSize, offColor[1], true, 2)
		local shadow = InitializeBoxAdorn(offset, outerSize, black, true, 1)
		shadow.Transparency = shadowTransparency
		boxAdorn.MouseEnter:connect(function() hoverEnterHandle(name) end)
		boxAdorn.MouseLeave:connect(function() hoverLeaveHandle(name) end)
		adornKeeper[name] = {boxAdorn, boxAdorn, name, hoverColor, offColor, outerSize, innerSize}
		shadowKeeper[name] = shadow
	elseif type == OUTLINE_BOX_ADORN then
		local boxAdornSmall = InitializeBoxAdorn(offset, innerSize, offColor[1], true, 3)
		local boxAdornLarge = InitializeBoxAdorn(offset, outerSize, black, true, 2)
		local shadow = InitializeBoxAdorn(offset, outerSize, black, true, 1)
		shadow.Transparency = shadowTransparency
		boxAdornLarge.MouseEnter:connect(function() hoverEnterHandle(name) end)
		boxAdornLarge.MouseLeave:connect(function() hoverLeaveHandle(name) end)
		adornKeeper[name] = {boxAdornLarge, boxAdornSmall, name, hoverColor, offColor, outerSize, innerSize}
		shadowKeeper[name] = shadow
	elseif type == CONE_ADORN then
		local coneAdornSmall = InitializeConeAdorn(offset, innerSize, offColor, true, 2, cframe)
		local coneAdornLarge = InitializeConeAdorn(offset, outerSize, {black, 0}, true, 1, cframe - Vector3.new(0, 0.05, 0))
		coneAdornLarge.MouseEnter:connect(function() hoverEnterHandle(T_Y_POS) end)
		coneAdornLarge.MouseLeave:connect(function() hoverLeaveHandle(T_Y_POS) end)
		adornKeeper[name] = {coneAdornLarge, coneAdornSmall, name, hoverColor, offColor, outerSize, innerSize}
	elseif type == IMAGE_ADORN then
		local imageAdorn = InitializeImageAdorn(offset, outerSize, offColor, true, 6, cframe, true, image)
		local imageAdornShadow = InitializeImageAdorn(offset, innerSize, {black, 0}, true, 2, cframe, false, image)
		if name == R_XZ then imageAdorn.Name = "R_XY" end
		imageAdorn.MouseEnter:connect(function() hoverEnterHandle(name) end)
		imageAdorn.MouseLeave:connect(function() hoverLeaveHandle(name) end)
		adornKeeper[name] = {imageAdornShadow, imageAdorn , name, hoverColor, offColor, outerSize, innerSize}
	end
end

local function initializeAdorns()
	--translation
	createAdorn(CONE_ADORN, T_Y_POS, {red, 0}, {yellow, 0}, Vector3.new(.8, .3, 0), Vector3.new(.6, .21, 0), Vector3.new(0, 1, 0), CFrame.new(Vector3.new(0, 3.05, 0), Vector3.new(0, 5, 0)))

	--cardinal
	createAdorn(BOX_ADORN, S_X_POS, {red, 0}, {darkBlue, 0}, Vector3.new(.1,.1,.1), Vector3.new(.1,.1,.1), Vector3.new(1, -1, 0))
	createAdorn(BOX_ADORN, S_X_NEG, {red, 0}, {darkBlue, 0}, Vector3.new(.1,.1,.1), Vector3.new(.1,.1,.1), Vector3.new(-1, -1, 0))
	createAdorn(BOX_ADORN, S_Z_POS, {red, 0}, {darkBlue, 0}, Vector3.new(.1,.1,.1), Vector3.new(.1,.1,.1), Vector3.new(0, -1, 1))
	createAdorn(BOX_ADORN, S_Z_NEG, {red, 0}, {darkBlue, 0}, Vector3.new(.1,.1,.1), Vector3.new(.1,.1,.1), Vector3.new(0, -1, -1))

	--ordinal
	createAdorn(OUTLINE_BOX_ADORN, S_X_POS_Z_POS, {red, 0}, {white, 0}, Vector3.new(.15,.15,.15), Vector3.new(.1,.1,.1), Vector3.new(1, -1, 1))
	createAdorn(OUTLINE_BOX_ADORN, S_X_POS_Z_NEG, {red, 0}, {white, 0}, Vector3.new(.15,.15,.15), Vector3.new(.1,.1,.1), Vector3.new(1, -1, -1))
	createAdorn(OUTLINE_BOX_ADORN, S_X_NEG_Z_POS, {red, 0}, {white, 0}, Vector3.new(.15,.15,.15), Vector3.new(.1,.1,.1), Vector3.new(-1, -1, 1))
	createAdorn(OUTLINE_BOX_ADORN, S_X_NEG_Z_NEG, {red, 0}, {white, 0}, Vector3.new(.15,.15,.15), Vector3.new(.1,.1,.1), Vector3.new(-1, -1, -1))
	createAdorn(OUTLINE_BOX_ADORN, S_Y_POS, {red, 0}, {white, 0}, Vector3.new(.15,.15,.15), Vector3.new(.1,.1,.1), Vector3.new(0, 1, 0))
	
	--rotation
	
	createAdorn(IMAGE_ADORN, R_XY, {rbxBlue, 0}, {rbxBlue, .3}, Vector2.new(1, 1), Vector2.new(1, 1), Vector3.new(-1, 1, -1), CFrame.new(Vector3.new(0,0,0), Vector3.new(0, 0, 1)), rotationArrow)
	createAdorn(IMAGE_ADORN, R_XZ, {rbxGreen, 0}, {rbxGreen, .3}, Vector2.new(1, 1), Vector2.new(1, 1), Vector3.new(-1, 1, 1), CFrame.new(Vector3.new(0,0,0), Vector3.new(0, 1, 0)), rotationArrow)
	createAdorn(IMAGE_ADORN, R_YZ, {rbxRed, 0}, {rbxRed, .3}, Vector2.new(1, 1), Vector2.new(1, 1), Vector3.new(1, 1, 1), CFrame.new(Vector3.new(0,0,0), Vector3.new(1, 0, 0)), rotationArrow)
			
	local planeAdorn = Instance.new("ImageHandleAdornment", cg)
	planeAdorn.Image = planeImage
	planeAdorn.Visible = false
	
	local parentScreen = Instance.new("ScreenGui",  cg)
	parentScreen.Name = "PrecisionDraggerGui"
	
	local imageLabel = Instance.new("ImageLabel", parentScreen)
	--imageLabel.Visible = false
	imageLabel.Image = planeImage
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.ImageColor3 = black
	imageLabel.Size = UDim2.new(0, 80, 0, 80)
	imageLabel.Position = UDim2.new(0, 5, 0, 5)
	imageLabel.ImageTransparency = 0.5--0.9
	imageLabel.MouseEnter:connect(function() hoverEnterHandle(H_PLANE) end)
	imageLabel.MouseLeave:connect(function() hoverLeaveHandle(H_PLANE) end)
	imageLabel.InputBegan:connect(function(input) planeInputBegan(input) end)
	imageLabel.InputEnded:connect(function(input) planeInputEnded(input) end)
	
	adornKeeper[H_PLANE] = {imageLabel, imageLabel, H_PLANE, {grey, 0}, {black, 0.5}, Vector2.new(1, 1), Vector2.new(1, 1)}
	
	rotateAxisLine[1] = Instance.new("LineHandleAdornment", cg)
	rotateAxisLine[1].Visible = false
	rotateAxisLine[1].Color3 = rbxRed
	rotateAxisLine[1].Thickness = 3
	rotateAxisLine[1].ZIndex = 5
	
	rotateAxisLine[2] = rotateAxisLine[1]:Clone()
	rotateAxisLine[2].Parent = cg
	rotateAxisLine[2].Color3 = rbxGreen
	
	rotateAxisLine[3] = rotateAxisLine[1]:Clone()
	rotateAxisLine[3].Parent = cg
	rotateAxisLine[3].Color3 = rbxBlue
	
	--measure
	
	if not strayAdornee then
		measureFrame1 = Instance.new("Frame", parentScreen)
		measureFrame1.Visible = false
		measureFrame1.Name = "MeasureFrame"
		measureFrame1.BackgroundTransparency = 0.45
		measureFrame1.BorderSizePixel = 0
		measureFrame1.BackgroundColor3 = white
		
		measureFrame2 = measureFrame1:Clone()
		measureFrame2.Parent = parentScreen
		
		measureLabel1 = Instance.new("TextLabel", measureFrame1)
		measureLabel1.Name = "MeasureLabel"
		measureLabel1.Font = Enum.Font.ArialBold
		measureLabel1.FontSize = Enum.FontSize.Size24
		measureLabel1.BackgroundTransparency = 1.0
		measureLabel1.BorderSizePixel = 0
		
		measureLabel2 = measureLabel1:Clone()
		measureLabel2.Parent = measureFrame2
		
		unitLabel1 = Instance.new("TextLabel", measureFrame1)
		unitLabel1.Name = "UnitLabel"
		unitLabel1.Font = Enum.Font.ArialBold
		unitLabel1.FontSize = Enum.FontSize.Size14
		unitLabel1.BackgroundTransparency = 1.0
		unitLabel1.BorderSizePixel = 0
		
		unitLabel2 = unitLabel1:Clone()
		unitLabel2.Parent = measureFrame2
		
		strayAdornee = Instance.new("Part", game.CoreGui)
		strayAdornee.Anchored = true
		strayAdornee.CFrame = CFrame.new()
		
		measureLine[1] = Instance.new("LineHandleAdornment", cg)
		measureLine[1].Visible = false
		measureLine[1].Color3 = black
		measureLine[1].Adornee = strayAdornee
		measureLine[1].AlwaysOnTop = true
		measureLine[1].ZIndex = 5
		
		measureLine[2] = measureLine[1]:Clone()
		measureLine[2].Parent = cg
		
		measureLine[3] = measureLine[1]:Clone()
		measureLine[3].Parent = cg
		
		measureLine[4] = measureLine[1]:Clone()
		measureLine[4].Parent = cg
		
		measureLine[5] = measureLine[1]:Clone()
		measureLine[5].Parent = cg
		
		measureLine[6] = measureLine[1]:Clone()
		measureLine[6].Parent = cg
		
		planeOriginLines[1] = measureLine[1]:Clone()
		planeOriginLines[1].Color3 = yellow
		planeOriginLines[1].Parent = cg
		planeOriginLines[1].Thickness = 2
		planeOriginLines[1].Length = 0.6
		
		for i = 2, 6 do
			planeOriginLines[i] = planeOriginLines[1]:Clone()
			planeOriginLines[i].Parent = cg
		end
				
		measureCone[1] = Instance.new("ConeHandleAdornment", cg)
		measureCone[1].Visible = false
		measureCone[1].Color3 = black
		measureCone[1].Adornee = strayAdornee
		measureCone[1].Height = 0.5
		measureCone[1].Radius = 0.1
		measureCone[1].AlwaysOnTop = true
		measureCone[1].ZIndex = 5
		
		measureCone[2] = measureCone[1]:Clone()
		measureCone[2].Parent = cg
		
		measureCone[3] = measureCone[1]:Clone()
		measureCone[3].Parent = cg
		
		measureCone[4] = measureCone[1]:Clone()
		measureCone[4].Parent = cg
		
		-- mini plane		
		miniPlaneLines[1] = Instance.new("ImageLabel", parentScreen)
		miniPlaneLines[1].Visible = false
		miniPlaneLines[1].BackgroundTransparency = 1
		miniPlaneLines[1].BorderSizePixel = 0
		miniPlaneLines[1].Image = gradient
		
		for i = 2, 8 do
			miniPlaneLines[i] = miniPlaneLines[1]:Clone()
			miniPlaneLines[i].Parent = parentScreen
		end
		
	end
		
	---measure rotate lines
	
	for i = 1, 88 do
		local rotateLine = Instance.new("LineHandleAdornment", cg)
		rotateLine.Visible = false
		rotateLine.Adornee = strayAdornee
		rotateLine.AlwaysOnTop = true
		rotateLine.ZIndex = 2
		rotateLine.Color3 = black
		rotateLine.Thickness = 2
		table.insert(rotateLines, rotateLine)
	end
	
	--------
	local line1 = Instance.new("LineHandleAdornment", cg)
	line1.Length = 2
	line1.Color3 = black
	line1.SizeRelativeOffset = Vector3.new(0, 1, 0)
	line1.CFrame = CFrame.new(Vector3.new(0, -1, 0), Vector3.new(0, -1, 0))
	line1.Thickness = 2

	planeKeeper[1] = line1
	planeKeeper[2] = line1:Clone()
	planeKeeper[2].Parent = cg
	planeKeeper[3] = line1:Clone()
	planeKeeper[3].Parent = cg
	planeKeeper[4] = line1:Clone()
	planeKeeper[4].Parent = cg
		
	initialized = true
end

local function setAdornVisibility(adorn, value)
	adornKeeper[adorn][1].Visible = value
	adornKeeper[adorn][2].Visible = value
	if shadowKeeper[adorn] then
		shadowKeeper[adorn].Visible = value
	end
end

local function setTextLocation(measureFrame, location)
	if location then
		measureFrame.Position = UDim2.new(0, location.X, 0, location.Y)
	end
end

local function setTextVisible(measureFrame, value, location)
	setTextLocation(measureFrame, location)	
	measureFrame.Visible = value
end

local function setSizeLineVisible1(value)
	measureLine[1].Visible = value
	measureLine[2].Visible = value
	measureLine[3].Visible = value
	measureCone[1].Visible = value
	measureCone[2].Visible = value
end

local function setSizeLineVisible2(value)
	measureLine[4].Visible = value
	measureLine[5].Visible = value
	measureLine[6].Visible = value
	measureCone[3].Visible = value
	measureCone[4].Visible = value
end

local function setRotateVisible(value)
	for i, v in ipairs(rotateLines) do
		v.Visible = value
	end
end

local function setPlaneCFrameVisible(value)
	for i = 1, 6 do
		planeOriginLines[i].Visible = value
	end
end

local function adornInstance(adorn, adornee)
	adornKeeper[adorn][1].Adornee = adornee
	adornKeeper[adorn][2].Adornee = adornee
	if shadowKeeper[adorn] then
		shadowKeeper[adorn].Adornee = adornee
	end
end

local function setPlaneVisibility(value)
	for i, v in ipairs(planeKeeper) do
		v.Visible = value
	end
	setAdornVisibility(H_PLANE, value)
	
	for i = 1, #miniPlaneLines do
		miniPlaneLines[i].Visible = value
	end
end

local function adornInstanceWithPlane(adornee)
	for i, v in ipairs(planeKeeper) do
		v.Adornee = adornee
	end
end

local function setTranslateAdornVisibility(value)
	setAdornVisibility(T_Y_POS, value)
end

local function adornInstanceWithTranslate(adornee)
	adornInstance(T_Y_POS, adornee)
end

local function setScaleAdornVisibility(value)
	setAdornVisibility(S_X_POS, value)
	setAdornVisibility(S_X_NEG, value)
	setAdornVisibility(S_Z_POS, value)
	setAdornVisibility(S_Z_NEG, value)
	setAdornVisibility(S_Y_POS, value)
	setAdornVisibility(S_X_POS_Z_POS, value)
	setAdornVisibility(S_X_POS_Z_NEG, value)
	setAdornVisibility(S_X_NEG_Z_POS, value)
	setAdornVisibility(S_X_NEG_Z_NEG, value)
end

local function adornInstanceWithScale(adornee)
	adornInstance(S_X_POS, adornee)
	adornInstance(S_X_NEG, adornee)
	adornInstance(S_Z_POS, adornee)
	adornInstance(S_Z_NEG, adornee)
	adornInstance(S_Y_POS, adornee)
	adornInstance(S_X_POS_Z_POS, adornee)
	adornInstance(S_X_POS_Z_NEG, adornee)
	adornInstance(S_X_NEG_Z_POS, adornee)
	adornInstance(S_X_NEG_Z_NEG, adornee)
end

local function setRotateAdornVisibility(value)
	setAdornVisibility(R_XY, value)
	setAdornVisibility(R_XZ, value)
	setAdornVisibility(R_YZ, value)
end

local function adornInstanceWithRotate(adornee)
	adornInstance(R_XY, adornee)
	adornInstance(R_XZ, adornee)
	adornInstance(R_YZ, adornee)
end

local pendingLines = {}
local lineAlloc = Instance.new("Folder",tempAdorns)
lineAlloc.Name = "LineGrid"

local function clearTemporaryLines()
	local lines = lineAlloc:GetChildren()
	if #lines > 0 then
		RecyclingBin:RecycleObjects(lines)
	end
end

local function appendTemporaryLine(startPoint, endPoint, transparency, thickness, adornee)
	if adornee then
		local params = {startPoint, endPoint, transparency, thickness, adornee}
		table.insert(pendingLines,params)
	end
end

local function drawTemporaryLines()
	local expected = #pendingLines
	local lines = RecyclingBin:Allocate("LineHandleAdornment",expected,lineAlloc)
	for i = expected,1,-1 do
		local params = pendingLines[i]
		pendingLines[i] = nil
		
		local startPoint, endPoint, transparency, thickness, adornee = unpack(params)
		local tmp = lines[i]
		
		local objectStartPoint = adornee.CFrame:pointToObjectSpace(startPoint)
		local objectEndPoint = adornee.CFrame:pointToObjectSpace(endPoint)
		
		local direction = (objectEndPoint - objectStartPoint)
		tmp.Length = direction.Magnitude
		
		tmp.CFrame = CFrame.new(objectStartPoint, objectEndPoint)
		local transition = Utility.smoothstep(0, 1, currentPlaneHoverTransitionLevel)
			
		tmp.Color3 = Utility.colorAdd(Utility.colorMultiply(grey, transition), Utility.colorMultiply(black, 1-transition))
		tmp.Transparency = transparency
		tmp.Thickness = (thickness * 1.2 * (transition)) + (thickness * (1-transition))
		tmp.ZIndex = 1
		tmp.Adornee = adornee
	end
end

local function setFrameLine(index, point1, point2)
	local length = (point2 - point1).magnitude + 1
	local midPoint = (point1 + point2) * 0.5
	miniPlaneLines[index].Rotation = math.deg(math.atan2(point2.Y - point1.Y, point2.X - point1.X))
	miniPlaneLines[index].Size = UDim2.new(0, length, 0, 3)
	miniPlaneLines[index].Position = UDim2.new(0, midPoint.X - length * 0.5, 0, midPoint.Y)
	miniPlaneLines[index].Visible = true
end

local function updateMiniPlane(planeFrame)
	local camera = game.Workspace.Camera
	
	local size = camera.ViewportSize
	
	local sizeMultiplier = 10
	local screenDiff =  -planeFrame.p + camera.CoordinateFrame.p + (camera:ScreenPointToRay(size.x * 0.5, size.y * 0.5).Direction * 60* sizeMultiplier * 0.5)
	
	local point1 = planeFrame:pointToWorldSpace(Vector3.new(-sizeMultiplier, 0, -sizeMultiplier)) + screenDiff
	local point2 = planeFrame:pointToWorldSpace(Vector3.new(sizeMultiplier, 0, -sizeMultiplier)) + screenDiff
	local point3 = planeFrame:pointToWorldSpace(Vector3.new(-sizeMultiplier, 0, sizeMultiplier)) + screenDiff
	local point4 = planeFrame:pointToWorldSpace(Vector3.new(sizeMultiplier, 0, sizeMultiplier)) + screenDiff
	
	local p1ss = camera:WorldToScreenPoint(point1)
	local p2ss = camera:WorldToScreenPoint(point2)
	local p3ss = camera:WorldToScreenPoint(point3)
	local p4ss = camera:WorldToScreenPoint(point4)
	
	local maxSize = 65
	local highestDiff = math.max((p1ss - p4ss).Magnitude, (p2ss - p3ss).Magnitude)
	local difference = maxSize / highestDiff
		
	local midpoint = size * 0.5
	local centerv3 = Vector3.new(midpoint.x, midpoint.y, 0)
	local midpointDiff = Vector2.new(45, 45) - Vector2.new(midpoint.x, midpoint.y) 
	
	p1ss = centerv3 + ((p1ss - centerv3) * difference)
	p2ss = centerv3 + ((p2ss - centerv3) * difference)
	p3ss = centerv3 + ((p3ss - centerv3) * difference)
	p4ss = centerv3 + ((p4ss - centerv3) * difference)
		
	local screenPoint1 = Vector2.new(p1ss.x + midpointDiff.X, p1ss.y + midpointDiff.Y)
	local screenPoint2 = Vector2.new(p2ss.x + midpointDiff.X, p2ss.y + midpointDiff.Y)
	local screenPoint3 = Vector2.new(p3ss.x + midpointDiff.X, p3ss.y + midpointDiff.Y)
	local screenPoint4 = Vector2.new(p4ss.x + midpointDiff.X, p4ss.y + midpointDiff.Y)
	
	local screenPoint12 = ((screenPoint1 * 2) / 3) + (screenPoint2 / 3)
	local screenPoint21 = ((screenPoint2 * 2) / 3) + (screenPoint1 / 3)
	
	local screenPoint13 = ((screenPoint1 * 2) / 3) + (screenPoint3 / 3)
	local screenPoint31 = ((screenPoint3 * 2) / 3) + (screenPoint1 / 3)
	
	local screenPoint24 = ((screenPoint2 * 2) / 3) + (screenPoint4 / 3)
	local screenPoint42 = ((screenPoint4 * 2) / 3) + (screenPoint2 / 3)
	
	local screenPoint34 = ((screenPoint3 * 2) / 3) + (screenPoint4 / 3)
	local screenPoint43 = ((screenPoint4 * 2) / 3) + (screenPoint3 / 3)
	
	setFrameLine(1, screenPoint1, screenPoint2)
	setFrameLine(2, screenPoint2, screenPoint4)
	setFrameLine(3, screenPoint4, screenPoint3)
	setFrameLine(4, screenPoint3, screenPoint1)
	
	setFrameLine(5, screenPoint12, screenPoint34)
	setFrameLine(6, screenPoint21, screenPoint43)
	
	setFrameLine(7, screenPoint13, screenPoint24)
	setFrameLine(8, screenPoint31, screenPoint42)
end

local function updatePlanePosition()
	
	local workplaneFrame, workplaneOffset = workplaneAccessor()

	if not planeKeeper[1].Visible and not renderRotation then return end
	
	local adornee = planeKeeper[1].Adornee
	local halfSize = adornee.Size / 2
	local p0 = {}
	local p1 = {}
	local camera_pos = Input.getMouseLocation()
	
	local distFromCamera = (camera_pos - adornee.CFrame:pointToWorldSpace(Vector3.new(0, -workplaneOffset, 0))).Magnitude;

	local minPosition = ((workplaneFrame:toObjectSpace(CFrame.new(adornee.CFrame:pointToWorldSpace(-halfSize)))).p) * Vector3.new(1, 0, 1);
	local maxPosition = ((workplaneFrame:toObjectSpace(CFrame.new(adornee.CFrame:pointToWorldSpace(halfSize)))).p) * Vector3.new(1, 0, 1);

	local minX = math.floor(math.min(minPosition.x, maxPosition.x));
	local maxX = math.ceil(math.max(minPosition.x, maxPosition.x));

	local minZ = math.floor(math.min(minPosition.z, maxPosition.z));
	local maxZ = math.ceil(math.max(minPosition.z, maxPosition.z));

	p0[1] = 0;
	p1[1] = 0;

	local minVisibleDist = 50;
	local maxVisibleDist = 100;

	local minFarDist = 250;
	local maxFarDist = 400;
	
	local transparencyDist = (-1 / (maxVisibleDist - minVisibleDist) * distFromCamera) + (minVisibleDist / (maxVisibleDist - minVisibleDist)) + 1;
	local farTransparency =  (-1 / (maxFarDist - minFarDist) * distFromCamera) + (minFarDist / (maxFarDist - minFarDist)) + 1;
	transparencyDist = math.max(math.min(transparencyDist, 0.9), 0.0)
	farTransparency = math.max(math.min(farTransparency, 1.0), 0.0)
		
	--local totalLines = 10
	
	if renderRotation then
		clearTemporaryLines()
		for i, v in ipairs(planeKeeper) do
			v.Visible = false
		end
		if rotationFrame then
			setRotation(rotationFrame, rotationRadius, rotationDegrees)
		end
	else
		planeKeeper[1].SizeRelativeOffset = Vector3.new(1, -1, 1)
		planeKeeper[1].CFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(-1, 0, 0))
		planeKeeper[1].Length = planeKeeper[1].Adornee.Size.X
		
		planeKeeper[2].SizeRelativeOffset = Vector3.new(1, -1, -1)
		planeKeeper[2].CFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 1))
		planeKeeper[2].Length = planeKeeper[1].Adornee.Size.Z
		
		planeKeeper[3].SizeRelativeOffset = Vector3.new(-1, -1, 1)
		planeKeeper[3].CFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, -1))
		planeKeeper[3].Length = planeKeeper[1].Adornee.Size.Z
		
		planeKeeper[4].SizeRelativeOffset = Vector3.new(-1, -1, -1)
		planeKeeper[4].CFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(1, 0, 0))
		planeKeeper[4].Length = planeKeeper[1].Adornee.Size.X
	
		for i = minZ - 4, maxZ + 4 do
	
		p0[0] = minX - 4;
		p0[2] = i;

		p1[0] = maxX + 4;
		p1[2] = i;

		local isStrongLine = i % 4 == 0;
		local isFarStrongLine = i % 16 == 0 or i == minZ - 4 or i == maxZ + 4;
		local transparency = 1.0 - (isFarStrongLine and 1.0 or (isStrongLine and farTransparency or transparencyDist))
		
		if (p0[0] <= p1[0] and p0[1] <= p1[1] and p0[2] <= p1[2] and transparency < 1.0) then
			appendTemporaryLine(workplaneFrame:pointToWorldSpace(Vector3.new(p0[0], p0[1], p0[2])), 
								workplaneFrame:pointToWorldSpace(Vector3.new(p1[0], p1[1], p1[2])), transparency, isStrongLine and 1.8 or 1.5, adornee)
		end
		end
	
		for i = minX - 4, maxX + 4 do
			p0[0] = i
			p0[2] = minZ - 4
	
			p1[0] = i
			p1[2] = maxZ + 4
	
			local isStrongLine = i % 4 == 0
			local isFarStrongLine = i % 16 == 0 or i == minX - 4 or i == maxX + 4
			local transparency = 1.0 - (isFarStrongLine and 1.0 or (isStrongLine and farTransparency or transparencyDist))
			
			if (p0[0] <= p1[0] and p0[1] <= p1[1] and p0[2] <= p1[2] and transparency < 1.0) then
				appendTemporaryLine(workplaneFrame:pointToWorldSpace(Vector3.new(p0[0],p0[1],p0[2])),
								workplaneFrame:pointToWorldSpace(Vector3.new(p1[0],p1[1],p1[2])), transparency, isStrongLine and 1.8 or 1.5, adornee)
			end
		end
		
		local v1 = workplaneFrame:pointToWorldSpace(workplaneFrame:pointToObjectSpace(adornee.CFrame:pointToWorldSpace(halfSize * Vector3.new(-1, 0, -1))) * Vector3.new(1, 0, 1))
		local v2 = workplaneFrame:pointToWorldSpace(workplaneFrame:pointToObjectSpace(adornee.CFrame:pointToWorldSpace(halfSize * Vector3.new(-1, 0, 1))) * Vector3.new(1, 0, 1))
		local v3 = workplaneFrame:pointToWorldSpace(workplaneFrame:pointToObjectSpace(adornee.CFrame:pointToWorldSpace(halfSize * Vector3.new(1, 0, -1))) * Vector3.new(1, 0, 1))
		local v4 = workplaneFrame:pointToWorldSpace(workplaneFrame:pointToObjectSpace(adornee.CFrame:pointToWorldSpace(halfSize * Vector3.new(1, 0, 1))) * Vector3.new(1, 0, 1))
		appendTemporaryLine(	v1,
							v2,
							0.0, 2.0, adornee)
		appendTemporaryLine(	v3,
							v4,
							0.0, 2.0, adornee)
		appendTemporaryLine(	v1,
							v3,
							0.0, 2.0, adornee)
		appendTemporaryLine(	v2,
							v4,
							0.0, 2.0, adornee)
		
		local tmpPlane = RecyclingBin:Allocate("BoxHandleAdornment",1,lineAlloc)[1]
		local distFromPlane = workplaneFrame:pointToObjectSpace(camera_pos).y
		
		tmpPlane.Size = (adornee.Size * Vector3.new(1, 0, 1)) + Vector3.new(0, (distFromPlane / 20) * .005, 0)
		local objectLocation = workplaneFrame:toObjectSpace(adornee.CFrame)
		tmpPlane.CFrame = adornee.CFrame:toObjectSpace(workplaneFrame:toWorldSpace(objectLocation - objectLocation.p * Vector3.new(0, 1, 0)))
		tmpPlane.Color3 = lightBlue
		tmpPlane.Transparency = 0.5
		tmpPlane.Adornee = adornee
		
		drawTemporaryLines()
	end

	updateMiniPlane(adornee.CFrame)
end

local function getAdornmentWorldCFrame(adornment)
	
	if adornment and adornment.Adornee then
		local adornee = adornment.Adornee
		if adornee:IsA("Model") and not adornee:IsA("Workspace") then
			adornee = Metapart.convertToPart(adornee)
		end
		
			local cframe = adornee.CFrame
			local worldSpaceCFrame = cframe * adornment.CFrame
			local worldSpaceOffset = cframe:pointToWorldSpace(adornment.SizeRelativeOffset * adornee.Size * 0.5) - cframe.p
			
			return worldSpaceCFrame + worldSpaceOffset;
	end
	
	return CFrame.new()
end

local function updateAdornmentPositions()
	if not initialized then return end
		
	if not adornKeeper or not adornKeeper[R_XY] then return end
		
	local mouseDown = Input.getButtonState(Input.Enum.Key.MOUSE_BUTTON1)
	
	local selection = game:GetService("Selection"):Get()
	
	if #selection <= 0 then
		setTranslateAdornVisibility(false)
		setPlaneVisibility(false)
		setRotateAdornVisibility(false)
		setScaleAdornVisibility(false)
		clearTemporaryLines()
		return
	end
	
	if not adornKeeper[R_XY][1].Adornee then return end
	
	local selectionContainsPVInstance = false
	
	for i, v in ipairs(selection) do
		if v:IsA("PVInstance") and not v:IsA("Workspace") and not v:IsA("Terrain") then
			selectionContainsPVInstance = true
			break
		end
	end
	
	if not selectionContainsPVInstance then
		setTranslateAdornVisibility(false)
		setPlaneVisibility(false)
		setRotateAdornVisibility(false)
		setScaleAdornVisibility(false)
		return
	end
		
	if mouseDown then
		if (currentHandle == R_XY or currentHandle == R_XZ or currentHandle == R_YZ) then
			setRotateAdornVisibility(false)
			setScaleAdornVisibility(false)
			setTranslateAdornVisibility(false)
		elseif (currentHandle == S_X_POS or currentHandle == S_X_NEG or currentHandle == S_Z_POS or
			currentHandle == S_Z_NEG or currentHandle == S_Y_POS or currentHandle == S_X_POS_Z_POS or
			currentHandle == S_X_POS_Z_NEG or currentHandle == S_X_NEG_Z_POS or currentHandle == S_X_NEG_Z_NEG) then
			setRotateAdornVisibility(false)
			setTranslateAdornVisibility(false)
			setScaleAdornVisibility(false)
			setAdornVisibility(currentHandle, true)
		elseif currentHandle == T_Y_POS then
			setTranslateAdornVisibility(true)
			setRotateAdornVisibility(false)
			setScaleAdornVisibility(false)
		elseif currentHandle == H_PLANE then
			setRotateAdornVisibility(false)
			setTranslateAdornVisibility(false)
			setScaleAdornVisibility(false)
		end
	elseif not planeSelectionActive then
		setRotateAdornVisibility(true)
		setTranslateAdornVisibility(true)
		if #selection == 1 and selection[1]:IsA("BasePart") then
			setScaleAdornVisibility(true)
			if (getFFlagFixTransformScalingSpheresAndCylinders()) then
				if selection[1]:IsA("Part") and selection[1].Shape == Enum.PartType.Ball then
					-- no need to rotate the sphere
					setRotateAdornVisibility(false)
					-- only enable one scale handle
					setScaleAdornVisibility(false)
					setAdornVisibility(S_Y_POS, true)
				end
			end
		end
	end

	local adornee = adornKeeper[R_XY][1].Adornee
	local cameraPos = game.Workspace.CurrentCamera.CoordinateFrame.p
	local localPosition = adornee.CFrame:pointToObjectSpace(cameraPos).Unit
	local octant = localPosition / Vector3.new(math.abs(localPosition.X), math.abs(localPosition.Y), math.abs(localPosition.Z))
	octant = Vector3.new(octant.X == octant.X and octant.X or 1, octant.Y == octant.Y and octant.Y or 1, octant.Z == octant.Z and octant.Z or 1)
	local invisLocalPos = adornKeeper[T_Y_POS][1].Adornee.CFrame:pointToObjectSpace(cameraPos).Unit
	local inisOctant = invisLocalPos / Vector3.new(math.abs(invisLocalPos.X), math.abs(invisLocalPos.Y), math.abs(invisLocalPos.Z))
		
	local positionChange = math.max(adornee.CFrame:pointToObjectSpace(cameraPos).Magnitude / 15.0, 1.0) * 0.35
	
	if not mouseDown then
		adornKeeper[T_Y_POS][1].SizeRelativeOffset = Vector3.new(0, inisOctant.Y, 0)
		adornKeeper[T_Y_POS][1].CFrame = CFrame.new(Vector3.new(0, inisOctant.Y * positionChange * 2.0 / 0.35, 0), Vector3.new(0, (inisOctant.Y * positionChange * 2.0 / 0.35) + inisOctant.Y, 0))
		adornKeeper[T_Y_POS][2].SizeRelativeOffset = Vector3.new(0, inisOctant.Y, 0)
		adornKeeper[T_Y_POS][2].CFrame = adornKeeper[T_Y_POS][1].CFrame + Vector3.new(0, (((adornKeeper[T_Y_POS][1].Height / 2) - (adornKeeper[T_Y_POS][2].Height / 1.75)) * inisOctant.Y), 0)
		
		yScale = octant.Y
		adornKeeper[S_Y_POS][1].SizeRelativeOffset = Vector3.new(0, octant.Y, 0)
		adornKeeper[S_Y_POS][2].SizeRelativeOffset = Vector3.new(0, octant.Y, 0)
		shadowKeeper[S_Y_POS].SizeRelativeOffset = Vector3.new(0, octant.Y, 0)
	end
	
	
	--blue - Z Axis
	adornKeeper[R_XY][2].SizeRelativeOffset = Vector3.new(octant.X, octant.Y, -octant.Z)
	adornKeeper[R_XY][2].CFrame = CFrame.new(Vector3.new(octant.X * positionChange , octant.Y * positionChange, 0), 
											 Vector3.new(octant.X * positionChange, octant.Y * positionChange, octant.Z))
								 
	adornKeeper[R_XY][2].CFrame = adornKeeper[R_XY][2].CFrame * CFrame.Angles(0, 0, ((octant.X > 0 and math.pi/2 or 0) + (octant.Y > 0 and 0 or math.pi/2) + (octant.Z > 0 and 0 or (octant.Y > 0 and -math.pi/2 or math.pi/2))) * (octant.X > 0 and 1 or -1))
	
	rotateAxisLine[3].Visible = false
	adornKeeper[R_XY][1].Visible = false

	if currentHandle == R_XY then
		local length = adornee.Size.Z + 2
		rotateAxisLine[3].Adornee = adornee
		rotateAxisLine[3].CFrame = CFrame.new(Vector3.new(0, 0, length * 0.5))-- * CFrame.Angles(math.rad(90),0,0)
		rotateAxisLine[3].Length = length
		rotateAxisLine[3].Visible = true
		
		if not mouseDown then
			adornKeeper[R_XY][1].SizeRelativeOffset = adornKeeper[R_XY][2].SizeRelativeOffset									 
			adornKeeper[R_XY][1].CFrame = adornKeeper[R_XY][2].CFrame
			adornKeeper[R_XY][1].Visible = true
			adornKeeper[R_XY][2].CFrame = adornKeeper[R_XY][2].CFrame + Vector3.new(0, 0, octant.Z * .075 * positionChange)
		end
	end	
	
	--green - Y Axis
	adornKeeper[R_XZ][2].SizeRelativeOffset = Vector3.new(octant.X, -octant.Y, octant.Z)
	adornKeeper[R_XZ][2].CFrame = CFrame.new(Vector3.new(octant.X * (positionChange + .2), 0, octant.Z * (positionChange + .2)), Vector3.new(octant.X * (positionChange + .2), octant.Y, octant.Z * (positionChange + .2)))
	adornKeeper[R_XZ][2].CFrame = adornKeeper[R_XZ][2].CFrame * CFrame.Angles(0, 0, (((octant.X > 0 and math.pi/2 or 0) + (octant.Z > 0 and math.pi/2 or 0) + (octant.Y > 0 and 0 or (octant.Z > 0 and -math.pi/2 or math.pi/2))) * (octant.X > 0 and 1 or -1) - (math.pi/2)))
	
	rotateAxisLine[2].Visible = false
	adornKeeper[R_XZ][1].Visible = false
		
	if currentHandle == R_XZ then
		local length = adornee.Size.Y + 2
		rotateAxisLine[2].Adornee = adornee
		rotateAxisLine[2].CFrame = CFrame.new(Vector3.new(0, -length * 0.5, 0)) * CFrame.Angles(math.rad(90),0,0)
		rotateAxisLine[2].Length = length
		rotateAxisLine[2].Visible = true
		
		if not mouseDown then
			adornKeeper[R_XZ][1].SizeRelativeOffset = adornKeeper[R_XZ][2].SizeRelativeOffset									 
			adornKeeper[R_XZ][1].CFrame = adornKeeper[R_XZ][2].CFrame
			adornKeeper[R_XZ][1].Visible = true
			adornKeeper[R_XZ][2].CFrame = adornKeeper[R_XZ][2].CFrame + Vector3.new(0, octant.Y * .075 * positionChange, 0)
		end
	end		
	
	
	--red - X Axis
	adornKeeper[R_YZ][2].SizeRelativeOffset = Vector3.new(-octant.X, octant.Y, octant.Z)
	adornKeeper[R_YZ][2].CFrame = CFrame.new(Vector3.new(0, octant.Y * positionChange, octant.Z * positionChange), Vector3.new(octant.X, octant.Y * positionChange, octant.Z * positionChange))
	adornKeeper[R_YZ][2].CFrame = adornKeeper[R_YZ][2].CFrame * CFrame.Angles(0, 0, ((octant.Z > 0 and math.pi/2 or 0) + (octant.Y > 0 and 0 or math.pi/2) + (octant.X > 0 and (octant.Y > 0 and -math.pi/2 or math.pi/2) or 0)) * (octant.Z > 0 and 1 or -1))
	
	rotateAxisLine[1].Visible = false
	adornKeeper[R_YZ][1].Visible = false
	
	if currentHandle == R_YZ then
		local length = adornee.Size.X + 2
		rotateAxisLine[1].Adornee = adornee
		rotateAxisLine[1].CFrame = CFrame.new(Vector3.new(length * 0.5, 0, 0)) * CFrame.Angles(0,math.rad(90),0)
		rotateAxisLine[1].Length = length
		rotateAxisLine[1].Visible = true
		
		if not mouseDown then
			adornKeeper[R_YZ][1].SizeRelativeOffset = adornKeeper[R_YZ][2].SizeRelativeOffset									 
			adornKeeper[R_YZ][1].CFrame = adornKeeper[R_YZ][2].CFrame
			adornKeeper[R_YZ][1].Visible = true
			adornKeeper[R_YZ][2].CFrame = adornKeeper[R_YZ][2].CFrame + Vector3.new(octant.X * 0.075 * positionChange, 0, 0)
		end
	end	
	
	--resize adorns
	for k,v in pairs(adornKeeper) do
		if k == H_PLANE then
			
		else
			local location = getAdornmentWorldCFrame(v[2]).p
			
	
			if v[1]:IsA("BoxHandleAdornment") then
				local sizeIncrease = math.max((location - cameraPos).Magnitude / 10.0, 1.0)
				v[1].Size = v[6] * sizeIncrease
				v[2].Size = v[7] * sizeIncrease
				if shadowKeeper[k] then
					shadowKeeper[k].Size = v[6] * sizeIncrease
				end
				
				local direction = (getAdornmentWorldCFrame(v[1]).p - cameraPos)
				local ray = Ray.new(cameraPos, direction)
				local part, location = game.Workspace:FindPartOnRay(ray)
				
				if (location - cameraPos).magnitude >= direction.magnitude - .2 then
					v[1].AlwaysOnTop = true
					v[2].AlwaysOnTop = true
				else
					v[1].AlwaysOnTop = false
					v[2].AlwaysOnTop = false
				end
				
			elseif v[1]:IsA("ConeHandleAdornment") then
				local sizeIncrease = math.max((location - cameraPos).Magnitude / 15.0, 1.0)
				v[1].Height = v[6].X * sizeIncrease
				v[1].Radius = v[6].Y * sizeIncrease
				v[2].Height = v[7].X * sizeIncrease
				v[2].Radius = v[7].Y * sizeIncrease
			elseif v[1]:IsA("ImageHandleAdornment") then
				local sizeIncrease = math.max(((location - cameraPos).Magnitude / 30.0) + 1, 1.0)
				v[1].Size = v[6] * sizeIncrease
				v[2].Size = v[7] * sizeIncrease
			end
		end
	end
	
	local transition = nil

	if planeHoverTransition or planeSelectionActive then
		if currentPlaneHoverTransitionLevel < 1 then
			currentPlaneHoverTransitionLevel = math.min(currentPlaneHoverTransitionLevel + planeHoverTransitionSpeed, 1)
			transition = Utility.smoothstep(0, 1, currentPlaneHoverTransitionLevel)
		end
	else
		if currentPlaneHoverTransitionLevel > 0 then
			currentPlaneHoverTransitionLevel = math.max(currentPlaneHoverTransitionLevel - planeHoverTransitionSpeed, 0)
			transition = Utility.smoothstep(0, 1, currentPlaneHoverTransitionLevel)
		end
	end
	
	if transition then
		local colorEnter = Utility.colorMultiply(adornKeeper[H_PLANE][4][1], transition) 
		local colorLeave = Utility.colorMultiply(adornKeeper[H_PLANE][5][1], 1-transition)
			
		adornKeeper[H_PLANE][2].ImageColor3 = Utility.colorAdd(colorEnter, colorLeave)
		adornKeeper[H_PLANE][2].ImageTransparency = (transition * adornKeeper[H_PLANE][4][2]) + ((1-transition) * adornKeeper[H_PLANE][5][2])
		
		for i = 1, 8 do
			miniPlaneLines[i].ImageColor3 = Utility.colorAdd(Utility.colorMultiply(black, transition), Utility.colorMultiply(white, 1-transition))
		end
	end
	
	if planeSelectionActive then
		adornKeeper[H_PLANE][2].ImageColor3 = rbxBlue
		adornKeeper[H_PLANE][2].ImageTransparency = 0
	end

	updatePlanePosition()
end

local function getCurrentAdornment()
	return adornKeeper[currentHandle]
end

local function setWorkplaneAccessor(func)
	workplaneAccessor = func
end

local function getCurrentHandle()
	return currentHandle
end

local function setCurrentHandle(value)
	currentHandle = value
end

local function scaleOne(point1, point2, direction)
	setLinePosition(measureCone[1], measureCone[2], measureLine[1], measureLine[2], measureLine[3], point1, point2, direction)
	local mag = (point1 - point2).magnitude
	
	setUnitText(measureFrame1, measureLabel1, unitLabel1, string.format("%.2f",mag), TYPE_STUDS)
	setSizeLineVisible1(true)
	local midpoint = ((point1 + point2) / 2) + direction
	setTextVisible(measureFrame1, true, game.Workspace.Camera:WorldToScreenPoint(midpoint))
end

local function scaleTwo(point1, point2, direction)
	setLinePosition(measureCone[3], measureCone[4], measureLine[4], measureLine[5], measureLine[6], point1, point2, direction)
	local mag = (point1 - point2).magnitude
	
	setUnitText(measureFrame2, measureLabel2, unitLabel2, string.format("%.2f",mag), TYPE_STUDS)
	setSizeLineVisible2(true)
	local midpoint = ((point1 + point2) / 2) + direction
	setTextVisible(measureFrame2, true, game.Workspace.Camera:WorldToScreenPoint(midpoint))
end

local function showRotate(cframe, radius, degrees, textLocation)
	
	internalRotate = (cframe.p - textLocation).magnitude < radius
	if not internalRotate then
		degrees = math.floor(degrees)
	end
	if degrees > 180 then
		degrees = degrees - 360
	elseif degrees < -180 then
		degrees = degrees + 360
	end
	
	setRotatePosition(cframe, radius, degrees)
	setRotateVisible(true)
	setUnitText(measureFrame1, measureLabel1, unitLabel1, string.format(internalRotate and "%.1f" or "%d", -degrees), TYPE_DEGREES)

	--text Location is currently at plane intersection point, not actual text location	
	local realLocation = (cframe  * CFrame.Angles(0, 0, math.rad(degrees + 180))):toWorldSpace(CFrame.new(Vector3.new(radius, 0, 0))).p
	
	setTextVisible(measureFrame1, true, game.Workspace.Camera:WorldToScreenPoint(realLocation))
end

local function drawPlaneCenter(cframe)
	setPlaneFrame(cframe)
	setPlaneCFrameVisible(true)
end

local function clearExtraAdorns()
	setTextVisible(measureFrame1, false)
	setTextVisible(measureFrame2, false)
	setSizeLineVisible1(false)
	setSizeLineVisible2(false)
	
	setRotateVisible(false)
	
	setPlaneCFrameVisible(false)
	
	clearRotation()
	renderRotation = false
end

local function setAllAdornVisibility(value)
	setRotateAdornVisibility(value)
	setTranslateAdornVisibility(value)
	setScaleAdornVisibility(value)
end

local function resetShadow(handle)
	if shadowKeeper[handle] then
		shadowKeeper[handle].Color3 = Color3.new(0, 0, 0)
		shadowKeeper[handle].Transparency = shadowTransparency
	end
end

local function isPlaneSelectingModeOn()
	return planeSelectionActive
end

local function setPlaneSelectingMode(value)
	planeSelectionActive = value
	planeHoverTransition = value
end

local function destroyAdorns()
	initialized = false
	
    for _, adorn in pairs(adornKeeper) do
        adorn[1]:Destroy()
        if adorn[2] then
            adorn[2]:Destroy()
        end
    end
    adornKeeper = {}

    for _, shadow in pairs(shadowKeeper) do
        shadow:Destroy()
    end
    shadowKeeper = {}

    for _, plane in pairs(planeKeeper) do
        plane:Destroy()
    end
    planeKeeper = {}

    for _, miniPlaneLine in pairs(miniPlaneLines) do
        miniPlaneLine:Destroy()
    end
    miniPlaneLines = {}

    for _, rotateLine in pairs(rotateLines) do
        rotateLine:Destroy()
    end
    rotateLines = {}

    for _, ral in pairs(rotateAxisLine) do
        ral.Parent = nil
    end
	
	strayAdornee:Destroy()
	strayAdornee = nil
		
	clearTemporaryLines()
end

local function grabHandle()
	
end

local function releaseHandle()
	--called on mouse release, releases the current handle
	clearExtraAdorns()
	
	if not currentlyOverHandle and currentHandle ~= H_NONE then
		if currentHandle == H_PLANE then
			planeHoverTransition = false
		else
			adornKeeper[currentHandle][2].Color3 = adornKeeper[currentHandle][5][1]
			adornKeeper[currentHandle][2].Transparency = adornKeeper[currentHandle][5][2]
			resetShadow(currentHandle)
		end
		
		currentHandle = H_NONE
		
		for k, v in pairs(hoveredHandles) do
			currentHandle = k
			break
		end
	end	
	
	if currentHandle ~= H_PLANE then
		setPlaneSelectingMode(false)
	end
end

local function getYScale()
	return yScale
end

local function isOverPlaneSelect()
	if not hoveredHandles[H_PLANE] then return false end -- We're already sure
	-- Need to check mouse position too, as MouseLeave doesn't like us all the time
	-- (Removing the mouse (quickly) from the button doesn't fire MouseLeave)
	local label = adornKeeper[H_PLANE][1]
	local s = label.AbsolutePosition - label.AbsoluteSize/2
	local e = label.AbsolutePosition + label.AbsoluteSize/2
	local mouse = Input.getMouse()
	local x,y = mouse.X, mouse.Y
	
	if x < s.X or x > e.X then return false end
	return y > s.Y and y < e.Y
end

local function resetDragger()
	for i=1,13 do
		resetHandle(i)
	end
	releaseHandle()
	setAllAdornVisibility(false)
	hoveredHandles = {}
	currentHandle = H_NONE
	currentlyOverHandle = false
	planeSelectionActive = false
end


-----------------------------------
---------FUNCTION ACCESSORS--------
-----------------------------------

local module = {}

module.initializeAdorns = initializeAdorns
module.destroyAdorns = destroyAdorns
module.adornInstanceWithTranslate = adornInstanceWithTranslate
module.adornInstanceWithScale = adornInstanceWithScale
module.adornInstanceWithRotate = adornInstanceWithRotate
module.adornInstanceWithPlane = adornInstanceWithPlane
module.updateAdornmentPositions = updateAdornmentPositions

module.setPlaneVisibility = setPlaneVisibility

module.setAllAdornVisibility = setAllAdornVisibility
module.setRotateAdornVisibility = setRotateAdornVisibility
module.setTranslateAdornVisibility = setTranslateAdornVisibility
module.setScaleAdornVisibility = setScaleAdornVisibility

module.getCurrentAdornment = getCurrentAdornment

module.scaleOne = scaleOne
module.scaleTwo = scaleTwo
module.showRotate = showRotate
module.clearExtraAdorns = clearExtraAdorns

module.hoverLeaveHandle = hoverLeaveHandle

module.drawPlaneCenter = drawPlaneCenter

module.setWorkplaneAccessor = setWorkplaneAccessor

module.resetShadow = resetShadow

module.getCurrentHandle = getCurrentHandle
module.setCurrentHandle = setCurrentHandle

module.isPlaneSelectingModeOn = isPlaneSelectingModeOn
module.setPlaneSelectingMode = setPlaneSelectingMode

module.getAdornmentWorldCFrame = getAdornmentWorldCFrame

module.grabHandle = grabHandle
module.releaseHandle = releaseHandle

module.isOverPlaneSelect = isOverPlaneSelect

module.getYScale = getYScale

module.resetDragger = resetDragger

return module
