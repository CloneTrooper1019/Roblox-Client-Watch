local FFlagTerrainTrackAcquisitionMethod = game:GetFastFlag("TerrainTrackAcquisitionMethod")

local Plugin = script.Parent.Parent.Parent.Parent

local TerrainEnums = require(Plugin.Src.Util.TerrainEnums)
local ToolId = TerrainEnums.ToolId

local TerrainRegionEditor = {}

local coreGui = game:GetService('CoreGui')
local changeHistory = game:GetService('ChangeHistoryService')

local getTerrain = require(Plugin.Src.Util.getTerrain)

local on = false
local mouse

local kCurrentTool
local kFillMaterial	-- kMergeEmpty used to be known as fillAir in the script while displayed as
local kMergeEmpty 	-- "Merge Empty" to the player. This has been changed because it was silly.

local terrain

local selectionPart = nil
local selectionObject = nil
local selectionHandles = nil
local selectionArcHandles = nil

--SUB SETTINGS--
local resolution = 4			--This is the size of voxels on Roblox. Why is this a variable? ;)
local textSelectColor = Color3.fromRGB(72, 145, 212)
local white = Color3.fromRGB(238, 238, 238)
local editColor1 = 'Institutional white'
local editColor2 = 'Light stone grey'
local rotationInterval = math.pi * .5
local regionLengthLimit = 125
----------------
--Variables--
local faceToNormal = {
	[Enum.NormalId.Top] = Vector3.new(0, 1, 0),
	[Enum.NormalId.Bottom] = Vector3.new(0, -1, 0),
	[Enum.NormalId.Left] = Vector3.new(-1, 0, 0),
	[Enum.NormalId.Right] = Vector3.new(1, 0, 0),
	[Enum.NormalId.Front] = Vector3.new(0, 0, -1),
	[Enum.NormalId.Back] = Vector3.new(0, 0, 1),
}

local undefined=0/0
local selectionStart = nil
local selectionEnd = nil
local selectionPart = nil
local selectionObject = nil
local selectionHandles = nil
local downLoop = nil
local clickStart = Vector3.new(0, 0, 0)
local dragVector = nil
local dragStart = true
local lockedMaterials, lockedOccupancies = nil, nil
local lockedRegion = nil
local behindThis = nil
local axis = 'X'
local materialAir = Enum.Material.Air
local materialWater = Enum.Material.Water
local floor = math.floor		--Scaling linear resize
local ceil = math.ceil

local screenGui

local selectionEffect, copyRegion, toolSelect, mode, tool, updateRotateOperation, updateDragOperation, setButton, dragAngle, mouseDown

local function getOrCreateScreenGui()
	if not screenGui or not screenGui.Parent then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "TerrainRegionEditor"
		screenGui.Parent = coreGui
	end

	return screenGui
end

local function make3DTable(size,fill)
	local size = size or Vector3.new(1,1,1)
	local newTable = {}
	for x = 1, size.x do
		local xt = {}
		for y = 1, size.y do
			local yt = {}
			for z = 1, size.z do
				yt[z] = fill
			end
			xt[y] = yt
		end
		newTable[x] = xt
	end
	return newTable
end

function setButton(newButtonId)
	lockInMap()

	renderSelection()
end

function lockInMap()	--Should call this every time the terrain under your selection changes. Don't for resize though, it uses the original lockin for rescaling.
	if selectionStart and selectionEnd then
		local region = Region3.new((selectionStart - Vector3.new(1,1,1)) * resolution, selectionEnd * resolution)
		lockedRegion = region
		lockedMaterials, lockedOccupancies = terrain:ReadVoxels(region, resolution)
	end
end

function renderSelection(temporaryStart,temporaryEnd,rotation)
	local temporaryStart = temporaryStart or selectionStart
	local temporaryEnd = temporaryEnd or selectionEnd
	local seeable = false
	if temporaryStart and temporaryEnd and selectionPart then
		seeable = true
		local temporarySize = ((temporaryEnd - temporaryStart + Vector3.new(1,1,1)) * resolution + Vector3.new(.2,.2,.2))
		if rotation then
			local rotatedSize = rotation * temporarySize
			temporarySize = Vector3.new(math.abs(rotatedSize.x), math.abs(rotatedSize.y), math.abs(rotatedSize.z))
		end
		selectionPart.Size = temporarySize
		selectionPart.CFrame = CFrame.new((temporaryStart + temporaryEnd - Vector3.new(1, 1, 1)) * .5 * resolution) * (rotation or CFrame.new(0,0,0))
	end

	if selectionObject then
		selectionObject.Visible = seeable
		selectionObject.Color = BrickColor.new(mode == ToolId.Select and 'Toothpaste' or editColor1)
		selectionObject.SurfaceColor = BrickColor.new(mode == ToolId.Select and 'Toothpaste' or editColor1)
	end
	if selectionHandles then
		selectionHandles.Visible = seeable and (tool == ToolId.Move or tool == ToolId.Resize)
		selectionHandles.Color = BrickColor.new(mode == ToolId.Select and 'Cyan' or editColor2)
		selectionHandles.Style = tool == ToolId.Move and Enum.HandlesStyle.Movement or Enum.HandlesStyle.Resize
	end
	if selectionArcHandles then
		selectionArcHandles.Visible = seeable and tool == ToolId.Rotate
		selectionArcHandles.Color = BrickColor.new(mode == ToolId.Select and 'Cyan' or editColor2)
	end
end

local function round(n)
	return n + .5 - ((n + .5)%1)
end

function FirstTimeSetup()

	local function positionWorldToVoxel(pos)
		return Vector3.new(ceil(pos.x / resolution), ceil(pos.y / resolution), ceil(pos.z / resolution))
	end

	local function make3DTable(size,fill)
		local size = size or Vector3.new(1,1,1)
		local newTable = {}
		for x = 1, size.x do
			local xt = {}
			for y = 1, size.y do
				local yt = {}
				for z = 1, size.z do
					yt[z] = fill
				end
				xt[y] = yt
			end
			newTable[x] = xt
		end
		return newTable
	end

	local function linInterp(a,b,p)
		return a+(b-a)*p
	end

	local function exaggerate(n,exaggeration)
		return (n-.5)*exaggeration + .5		--optimized
		--return n*exaggeration - exaggeration*.5 + .5
	end
	local function exaggeratedLinInterp(a,b,p,exaggeration)
		local unclamped = (a+(b-a)*p-.5)*exaggeration+.5
		return (unclamped < 0 and 0) or (unclamped > 1 and 1) or unclamped

		--At first I thought this didn't need to be clamped because the terrain clamps that anways.
		--But I then realized I am using this number a bit more before handing it to terrain.
		--After doing some tests. Clamping is necessary for artificial structures being streched. If unclamped, rounding of artificial edges occurs.
		--return (a+(b-a)*p-.5)*exaggeration+.5
		--Maybe this extra dimension of unclamping might be desired for natural terrain, but not artificuial?
	end

	function updateDragOperation()
		local dragVector = dragVector or Vector3.new(0,0,0)
		local temporaryStart = selectionStart
		local temporaryEnd = selectionEnd
		if tool == ToolId.Resize then
			if dragStart then
				temporaryStart = Vector3.new(
					math.min(
						math.max(temporaryStart.x+dragVector.x,temporaryEnd.x-regionLengthLimit),
						temporaryEnd.x),
					math.min(
						math.max(temporaryStart.y+dragVector.y,temporaryEnd.y-regionLengthLimit),
						temporaryEnd.y),
					math.min(
						math.max(temporaryStart.z+dragVector.z,temporaryEnd.z-regionLengthLimit),
						temporaryEnd.z)
				)
			else
				temporaryEnd = Vector3.new(
					math.max(
						math.min(temporaryEnd.x+dragVector.x,temporaryStart.x+regionLengthLimit),
						temporaryStart.x),
					math.max(
						math.min(temporaryEnd.y+dragVector.y,temporaryStart.y+regionLengthLimit),
						temporaryStart.y),
					math.max(
						math.min(temporaryEnd.z+dragVector.z,temporaryStart.z+regionLengthLimit),
						temporaryStart.z)
				)
			end
			if mode == 'Edit' then
				local region = Region3.new((temporaryStart - Vector3.new(1,1,1)) * resolution, temporaryEnd * resolution)
				if behindThis then
					terrain:WriteVoxels(behindThis.region, resolution, behindThis.materials, behindThis.occupancies)
				else
					if selectionStart and selectionEnd then
						local region = Region3.new((selectionStart - Vector3.new(1,1,1)) * resolution, selectionEnd * resolution)
						local regionSize = region.Size / resolution
						terrain:WriteVoxels(region, resolution, make3DTable(regionSize,materialAir), make3DTable(regionSize,0))
					end
				end
				behindThis = {}
				behindThis.region = region
				behindThis.materials, behindThis.occupancies = terrain:ReadVoxels(region, resolution)

				local behindMaterials, behindOccupancies = behindThis.materials, behindThis.occupancies

				local loopx = #lockedMaterials - 1
				local loopy = #lockedMaterials[1] - 1
				local loopz = #lockedMaterials[1][1] - 1
				local tempRegionSize = Vector3.new(1,1,1) + temporaryEnd - temporaryStart
				local tempSizeX = tempRegionSize.x
				local tempSizeY = tempRegionSize.y
				local tempSizeZ = tempRegionSize.z
				local newMat = {}
				local newOcc = {}
				for x=1, tempSizeX do
					local scalex = (x-1)/(tempSizeX-1)*loopx
					if scalex ~= scalex then
						scalex = 0
					end
					local startx = floor(scalex)+1
					local endx = startx+1
					local interpScalex = scalex-startx+1
					if startx > loopx then
						endx = startx
					end

					local xtm = {}
					local xto = {}
					for y=1, tempSizeY do
						local scaley = (y-1)/(tempSizeY-1)*loopy
						if scaley ~= scaley then
							scaley = 0
						end
						local starty = floor(scaley)+1
						local endy = starty+1
						local interpScaley = scaley-starty+1
						if starty > loopy then
							endy = starty
						end

						local ytm = {}
						local yto = {}
						for z=1, tempSizeZ do
							local oldMaterial = behindMaterials[x][y][z]
							local oldOccupancy = behindOccupancies[x][y][z]

							if not kMergeEmpty or oldMaterial == materialAir or oldOccupancy == 0 then
								local scalez = (z - 1) / (tempSizeZ - 1) * loopz	--consider adding 1 here and removing +1's elsewhere
								if scalez ~= scalez then		--undefined check
									scalez = 0
								end
								local startz = floor(scalez) + 1
								local endz = startz + 1
								local interpScalez = scalez - startz + 1
								if startz > loopz then
									endz = startz
								end

								local exaggerationX = tempSizeX / (loopx+1)
								local exaggerationY = tempSizeY/  (loopy+1)
								local exaggerationZ = tempSizeZ / (loopz+1)

								local interpz1 = exaggeratedLinInterp(
									lockedOccupancies[startx][starty][startz],
									lockedOccupancies[startx][starty][endz],
									interpScalez, exaggerationZ)
								local interpz2 = exaggeratedLinInterp(
									lockedOccupancies[startx][endy][startz],
									lockedOccupancies[startx][endy][endz],
									interpScalez, exaggerationZ)
								local interpz3 = exaggeratedLinInterp(
									lockedOccupancies[endx][starty][startz],
									lockedOccupancies[endx][starty][endz],
									interpScalez, exaggerationZ)
								local interpz4 = exaggeratedLinInterp(
									lockedOccupancies[endx][endy][startz],
									lockedOccupancies[endx][endy][endz],
									interpScalez, exaggerationZ)

								local interpy1 = exaggeratedLinInterp(interpz1, interpz2, interpScaley, exaggerationY)
								local interpy2 = exaggeratedLinInterp(interpz3, interpz4, interpScaley, exaggerationY)

								local interpx1 = exaggeratedLinInterp(interpy1, interpy2, interpScalex, exaggerationX)

								local newMaterial = lockedMaterials[round(scalex) + 1][round(scaley) + 1][round(scalez) + 1]

								ytm[z] = newMaterial
								yto[z] = interpx1
							else
								ytm[z] = oldMaterial
								yto[z] = oldOccupancy
							end
						end
						xtm[y] = ytm
						xto[y] = yto
					end
					newMat[x] = xtm
					newOcc[x] = xto
				end

				terrain:WriteVoxels(region, resolution, newMat, newOcc)
			else
				behindThis = nil
			end
		elseif tool == ToolId.Move then
			temporaryStart = temporaryStart + dragVector
			temporaryEnd = temporaryEnd + dragVector
			if mode == 'Edit' then
				local region = Region3.new((temporaryStart - Vector3.new(1,1,1)) * resolution, temporaryEnd * resolution)
				if behindThis then
					terrain:WriteVoxels(behindThis.region, resolution, behindThis.materials, behindThis.occupancies)
				else
					if selectionStart and selectionEnd then
						local region = Region3.new((selectionStart - Vector3.new(1,1,1)) * resolution, selectionEnd * resolution)
						local regionSize = region.Size / resolution
						terrain:WriteVoxels(region, resolution, make3DTable(regionSize,materialAir), make3DTable(regionSize,0))
					end
				end
				behindThis = {}
				behindThis.region = region
				behindThis.materials, behindThis.occupancies = terrain:ReadVoxels(region, resolution)

				local behindMaterials, behindOccupancies = behindThis.materials, behindThis.occupancies

				-- If merge empty is not on, then just overwrite the existing terrain
				-- When it is on, then only fill the empty voxels in the existing terrain
				if not kMergeEmpty then
					terrain:WriteVoxels(region, resolution, lockedMaterials, lockedOccupancies)
				else
					local newMat = {}
					local newOcc = {}

					for x, xv in ipairs(lockedMaterials) do
						local xtm = {}
						local xto = {}
						for y, yv in ipairs(xv) do
							local ytm = {}
							local yto = {}
							for z, _ in ipairs(yv) do
								local oldMaterial = behindMaterials[x][y][z]
								local oldOccupancy = behindOccupancies[x][y][z]

								if oldMaterial == materialAir or oldOccupancy == 0 then
									ytm[z] = lockedMaterials[x][y][z]
									yto[z] = lockedOccupancies[x][y][z]
								else
									ytm[z] = oldMaterial
									yto[z] = oldOccupancy
								end
							end
							xtm[y] = ytm
							xto[y] = yto
						end
						newMat[x] = xtm
						newOcc[x] = xto
					end
					terrain:WriteVoxels(region, resolution, newMat, newOcc)
				end
			end
		end
		renderSelection(temporaryStart,temporaryEnd)
	end



	local function rotate(mx,x,my,y,rotation)
		if rotation == 1 then
			return my + 1 - y, x
		elseif rotation == 2 then
			return mx + 1 - x, my + 1 - y
		elseif rotation == 3 then
			return y, mx + 1 - x
		end
		return x,y
	end

	function updateRotateOperation()
		local dragAngle = dragAngle or 0
		local rotationCFrame = CFrame.Angles(
			axis ~= 'X' and 0 or dragAngle * rotationInterval,
			axis ~= 'Y' and 0 or dragAngle * rotationInterval,
			axis ~= 'Z' and 0 or dragAngle * rotationInterval
		)

		local temporarySize = Vector3.new(1,1,1) + selectionEnd - selectionStart
		local centerOffset = Vector3.new(ceil(temporarySize.x * .5),
			ceil(temporarySize.y * .5),
			ceil(temporarySize.z * .5))

		temporarySize = rotationCFrame * temporarySize
		local temporarySizeX = round(math.abs(temporarySize.x))	--I need to round these because of floating point imprecision
		local temporarySizeY = round(math.abs(temporarySize.y))
		local temporarySizeZ = round(math.abs(temporarySize.z))
		centerOffset = centerOffset - Vector3.new(ceil(temporarySizeX * .5), ceil(temporarySizeY * .5), ceil(temporarySizeZ * .5))

		local temporaryEnd = selectionStart + centerOffset + Vector3.new(temporarySizeX, temporarySizeY, temporarySizeZ) - Vector3.new(1, 1, 1)
		local temporaryStart = selectionStart + centerOffset

		if mode == 'Edit' then
			local region = Region3.new((temporaryStart - Vector3.new(1,1,1)) * resolution, temporaryEnd * resolution)
			if behindThis then
				terrain:WriteVoxels(behindThis.region, resolution, behindThis.materials, behindThis.occupancies)
			else
				if selectionStart and selectionEnd then
					local region = Region3.new((selectionStart - Vector3.new(1,1,1)) * resolution, selectionEnd * resolution)
					local regionSize = region.Size / resolution
					terrain:WriteVoxels(region, resolution, make3DTable(regionSize,materialAir), make3DTable(regionSize,0))
				end
				--local regionSize = lockedRegion.Size / resolution
				--terrain:WriteVoxels(lockedRegion, resolution, make3DTable(regionSize,materialAir), make3DTable(regionSize,0))
			end
			behindThis = {}
			behindThis.region = region
			behindThis.materials, behindThis.occupancies = terrain:ReadVoxels(region, resolution)

			local newMat = {}
			local newOcc = {}

			for x=1, temporarySizeX do
				local xtm = {}
				local xto = {}
				for y=1, temporarySizeY do
					local ytm = {}
					local yto = {}
					for z=1, temporarySizeZ do
						local oldMaterial = behindThis.materials[x][y][z]
						local oldOccupancy = behindThis.occupancies[x][y][z]

						if not kMergeEmpty or oldMaterial == materialAir or oldOccupancy == 0 then
							local targetx = x
							local targety = y
							local targetz = z
							if axis == "Y" then	-- Prioritize y because I know this is the primary rotation axis
								targetx, targetz = rotate(temporarySizeX, x, temporarySizeZ, z, dragAngle)
							elseif axis == "X" then
								targetz, targety = rotate(temporarySizeZ, z, temporarySizeY, y, dragAngle)
							elseif axis == "Z" then
								targety, targetx = rotate(temporarySizeY, y, temporarySizeX, x, dragAngle)
							end
							local newMaterial = lockedMaterials[targetx][targety][targetz]

							ytm[z] = newMaterial
							yto[z] = lockedOccupancies[targetx][targety][targetz]

						else
							ytm[z] = oldMaterial
							yto[z] = oldOccupancy
						end
					end
					xtm[y] = ytm
					xto[y] = yto
				end
				newMat[x] = xtm
				newOcc[x] = xto
			end

			terrain:WriteVoxels(region, resolution, newMat, newOcc)
		end
		renderSelection(temporaryStart,temporaryEnd,rotationCFrame)
	end

	function selectionEffect(temporaryStart, temporaryEnd, color, sizeFrom, sizeTo, effectTime)
		local temporaryStart = temporaryStart or selectionStart
		local temporaryEnd = temporaryEnd or selectionEnd

		local effectPart = Instance.new('Part')
		effectPart.Name = 'EffectPart'
		effectPart.Transparency = 1
		effectPart.TopSurface = 'Smooth'
		effectPart.BottomSurface = 'Smooth'
		effectPart.Anchored = true
		effectPart.CanCollide = false
		effectPart.Parent = getOrCreateScreenGui()

		local selectionEffectObject = Instance.new('SelectionBox')
		selectionEffectObject.Name = 'SelectionObject'
		selectionEffectObject.Transparency = 1
		selectionEffectObject.SurfaceTransparency = .75
		selectionEffectObject.SurfaceColor = BrickColor.new(color)
		selectionEffectObject.Adornee = effectPart
		selectionEffectObject.Parent = effectPart

		local baseSize = ((temporaryEnd - temporaryStart + Vector3.new(1,1,1)) * resolution + Vector3.new(.21,.21,.21))
		effectPart.CFrame = CFrame.new((temporaryStart + temporaryEnd - Vector3.new(1, 1, 1)) * .5 * resolution)
		effectPart.Size = baseSize * sizeFrom
		local endTick=tick()+effectTime
		while endTick>tick() do
			local percent=1-(endTick-tick())/effectTime
			selectionEffectObject.SurfaceTransparency = .75 + percent*.25
			effectPart.Size = baseSize * (sizeFrom+(sizeTo-sizeFrom)*percent)
			wait()
		end
		effectPart:Destroy()
	end

	mouse.Button1Down:connect(function()
		if on and mode == ToolId.Select then
			mouseDown = true
			behindThis = nil
			local mousePos = mouse.Hit.p + mouse.UnitRay.Direction * .05
			if mouse.Target == nil then	--cage the cursor so that it does not fly away
				mousePos = game.Workspace.CurrentCamera.CoordinateFrame.p + mouse.UnitRay.Direction * 100
			end
			clickStart = positionWorldToVoxel(mousePos)
			local thisDownLoop = {}
			downLoop = thisDownLoop
			while thisDownLoop == downLoop and mouseDown and on and mode == 'Select' do
				local mousePos = mouse.Hit.p + mouse.UnitRay.Direction * .05
				if mouse.Target == nil then	--cage the cursor so that it does not fly away
					mousePos = game.Workspace.CurrentCamera.CoordinateFrame.p + mouse.UnitRay.Direction * 100
				end
				local voxelCurrent = positionWorldToVoxel(mousePos)
				voxelCurrent = Vector3.new(
					math.max(math.min(voxelCurrent.x,clickStart.x+regionLengthLimit),clickStart.x-regionLengthLimit),
					math.max(math.min(voxelCurrent.y,clickStart.y+regionLengthLimit),clickStart.y-regionLengthLimit),
					math.max(math.min(voxelCurrent.z,clickStart.z+regionLengthLimit),clickStart.z-regionLengthLimit))
				selectionStart = Vector3.new(math.min(clickStart.x, voxelCurrent.x), math.min(clickStart.y, voxelCurrent.y), math.min(clickStart.z, voxelCurrent.z))
				selectionEnd = Vector3.new(math.max(clickStart.x, voxelCurrent.x), math.max(clickStart.y, voxelCurrent.y), math.max(clickStart.z, voxelCurrent.z))
				renderSelection()
				game:GetService('RunService').RenderStepped:wait()
			end
		end
	end)

	mouse.Button1Up:connect(function()
		mouseDown = false
		if dragVector and dragVector.magnitude > 0 then
			if tool == ToolId.Resize then
				--[[if dragStart then
					selectionStart = Vector3.new(math.min(selectionStart.x+dragVector.x,selectionEnd.x),math.min(selectionStart.y+dragVector.y,selectionEnd.y),math.min(selectionStart.z+dragVector.z,selectionEnd.z))
				else
					selectionEnd = Vector3.new(math.max(selectionEnd.x+dragVector.x,selectionStart.x),math.max(selectionEnd.y+dragVector.y,selectionStart.y),math.max(selectionEnd.z+dragVector.z,selectionStart.z))
				end]]

				if dragStart then
					selectionStart = Vector3.new(
						math.min(
							math.max(selectionStart.x+dragVector.x,selectionEnd.x-regionLengthLimit),
							selectionEnd.x),
						math.min(
							math.max(selectionStart.y+dragVector.y,selectionEnd.y-regionLengthLimit),
							selectionEnd.y),
						math.min(
							math.max(selectionStart.z+dragVector.z,selectionEnd.z-regionLengthLimit),
							selectionEnd.z)
					)
				else
					selectionEnd = Vector3.new(
						math.max(
							math.min(selectionEnd.x+dragVector.x,selectionStart.x+regionLengthLimit),
							selectionStart.x),
						math.max(
							math.min(selectionEnd.y+dragVector.y,selectionStart.y+regionLengthLimit),
							selectionStart.y),
						math.max(
							math.min(selectionEnd.z+dragVector.z,selectionStart.z+regionLengthLimit),
							selectionStart.z)
					)
				end
			elseif tool == ToolId.Move then
				selectionStart = selectionStart + dragVector
				selectionEnd = selectionEnd + dragVector
			end

			changeHistory:SetWaypoint('Terrain '..kCurrentTool)
		end
		if dragAngle and dragAngle ~= 0 then
			local rotationCFrame = CFrame.Angles(
				axis ~= 'X' and 0 or dragAngle * rotationInterval,
				axis ~= 'Y' and 0 or dragAngle * rotationInterval,
				axis ~= 'Z' and 0 or dragAngle * rotationInterval
			)

			local temporarySize = Vector3.new(1,1,1) + selectionEnd - selectionStart
			local centerOffset = Vector3.new(ceil(temporarySize.x * .5), ceil(temporarySize.y * .5), ceil(temporarySize.z * .5))
			temporarySize = rotationCFrame * temporarySize
			local temporarySizeX = round(math.abs(temporarySize.x))	--I need to round these because of floating point imprecision
			local temporarySizeY = round(math.abs(temporarySize.y))
			local temporarySizeZ = round(math.abs(temporarySize.z))
			centerOffset = centerOffset - Vector3.new(ceil(temporarySizeX * .5), ceil(temporarySizeY * .5), ceil(temporarySizeZ * .5))

			selectionEnd = selectionStart + centerOffset + Vector3.new(temporarySizeX, temporarySizeY, temporarySizeZ) - Vector3.new(1, 1, 1)
			selectionStart = selectionStart + centerOffset
			lockInMap()
			changeHistory:SetWaypoint('Terrain '..kCurrentTool)
		end

		dragVector = nil
		dragAngle = nil
		renderSelection()
		--lockInMap()
	end)

	local function historyChanged()
		selectionStart = nil
		selectionEnd = nil
		lockedMaterials = nil
		lockedOccupancies = nil
		setButton(ToolId.Select)
	end

	changeHistory.OnUndo:connect(historyChanged)
	changeHistory.OnRedo:connect(historyChanged)
end

function createSelectionPart()
	if not selectionPart then
		selectionPart = Instance.new('Part')
		selectionPart.Name = 'SelectionPart'
		selectionPart.Transparency = 1
		selectionPart.TopSurface = 'Smooth'
		selectionPart.BottomSurface = 'Smooth'
		selectionPart.Anchored = true
		selectionPart.CanCollide = false
		selectionPart.Parent = getOrCreateScreenGui()
	end
	if not selectionObject then
		selectionObject = Instance.new('SelectionBox')
		selectionObject.Name = 'SelectionObject'
		selectionObject.Color = BrickColor.new(kCurrentTool == 'Select' and 'Toothpaste' or editColor1)
		selectionObject.SurfaceTransparency = .85
		selectionObject.SurfaceColor = BrickColor.new(kCurrentTool == 'Select' and 'Toothpaste' or editColor1)
		selectionObject.Adornee = selectionPart
		selectionObject.Visible = false
		selectionObject.Parent = selectionPart
	end
	if not selectionHandles then
		selectionHandles = Instance.new('Handles')
		selectionHandles.Name = 'SelectionHandles'
		selectionHandles.Color = BrickColor.new(kCurrentTool == 'Select' and 'Toothpaste' or editColor2)
		selectionHandles.Adornee = selectionPart
		selectionHandles.Visible = false
		selectionHandles.Parent = selectionObject--coreGui--game.Workspace--terrainRegionFrame--selectionPart
		selectionHandles.MouseDrag:connect(function (face, delta)
			local normal = faceToNormal[face]
			local delta = delta
			local newDragVector = normal * floor((delta + .5) / resolution)
			dragStart = normal.x < 0 or normal.y < 0 or normal.z < 0	--This determines if we are dragging a side on the min or max bounds
			if newDragVector ~= dragVector then
				dragVector = newDragVector
				updateDragOperation()
			end
		end)
	end
	if not selectionArcHandles then
		selectionArcHandles = Instance.new('ArcHandles')
		selectionArcHandles.Name = 'SelectionArcHandles'
		selectionArcHandles.Color = BrickColor.new(kCurrentTool == 'Select' and 'Toothpaste' or editColor2)
		selectionArcHandles.Adornee = selectionPart
		selectionArcHandles.Visible = false
		selectionArcHandles.Parent = selectionHandles--coreGui--game.Workspace--terrainRegionFrame--selectionPart
		selectionArcHandles.MouseDrag:connect(function (rotationAxis,relativeAngle,deltaRadius)
			axis = rotationAxis.Name
			local newDragAngle = round(relativeAngle / rotationInterval) % 4
			if newDragAngle ~= dragAngle then
				dragAngle = newDragAngle
				updateRotateOperation()
			end
		end)
	end
end

function clearSelection()
	if selectionArcHandles then
		selectionArcHandles:Destroy()
		selectionArcHandles = nil
	end
	if selectionHandles then
		selectionHandles:Destroy()
		selectionHandles = nil
	end
	if selectionObject then
		selectionObject:Destroy()
		selectionObject = nil
	end
	if selectionPart then
		selectionPart:Destroy()
		selectionPart = nil
	end

	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
end

toolSelect = {
	[ToolId.Select] = function ()
		setButton(ToolId.Select)
	end,
	[ToolId.Move] = function ()
		setButton(ToolId.Move)
	end,
	[ToolId.Resize] = function ()
		setButton(ToolId.Resize)
	end,
	[ToolId.Rotate] = function ()
		setButton(ToolId.Rotate)
	end,
	[ToolId.Delete] = function ()
		if selectionStart and selectionEnd then
			local region = Region3.new((selectionStart - Vector3.new(1,1,1)) * resolution, selectionEnd * resolution)
			local regionSize = region.Size / resolution
			local emptyMaterialMap = make3DTable(regionSize,materialAir)
			local emptyOccupancyMap = make3DTable(regionSize,0)

			--[[behindThis = {}
			behindThis.region = region
			behindThis.materials, behindThis.occupancies = emptyMaterialMap, emptyOccupancyMap

			terrain:WriteVoxels(region, resolution, emptyMaterialMap, emptyOccupancyMap)]]
			if behindThis then
				terrain:WriteVoxels(behindThis.region, resolution, behindThis.materials, behindThis.occupancies)
			else
				if selectionStart and selectionEnd then
					terrain:WriteVoxels(region, resolution, emptyMaterialMap, emptyOccupancyMap)
				end
			end
			behindThis = {}
			behindThis.region = region
			behindThis.materials, behindThis.occupancies = terrain:ReadVoxels(region, resolution)

			--[[lockedRegion = region
			lockedMaterials, lockedOccupancies = emptyMaterialMap, emptyOccupancyMap]]
			local oldStart, oldEnd = selectionStart, selectionEnd
			setButton(ToolId.Select)

			changeHistory:SetWaypoint('Terrain Delete')
			selectionEffect(oldStart,oldEnd,'Really red',1,1.2,.5)
		end
	end,
	[ToolId.Paste] = function ()
		if copyRegion then
			selectionEnd=selectionStart+copyRegion.SizeInCells-Vector3.new(1,1,1)

			local region = Region3.new((selectionStart - Vector3.new(1,1,1)) * resolution, selectionEnd * resolution)
			behindThis = {}
			behindThis.region = region
			behindThis.materials, behindThis.occupancies = terrain:ReadVoxels(region, resolution)

			if FFlagTerrainTrackAcquisitionMethod then
				terrain.LastUsedModificationMethod = Enum.TerrainAcquisitionMethod.RegionPasteTool
			end

			terrain:PasteRegion(copyRegion,Vector3int16.new(selectionStart.x-1,selectionStart.y-1,selectionStart.z-1),true)
			setButton(ToolId.Move)
			changeHistory:SetWaypoint('Terrain Paste')
			selectionEffect(nil,nil,'Lime green',1.2,1,.5)
		end
	end,
	[ToolId.Copy] = function ()
		if selectionStart and selectionEnd then
			local selectionStartInt16=Vector3int16.new(selectionStart.x-1,selectionStart.y-1,selectionStart.z-1)
			local selectionEndInt16=Vector3int16.new(selectionEnd.x-1,selectionEnd.y-1,selectionEnd.z-1)
			local region = Region3int16.new(selectionStartInt16,selectionEndInt16)
			copyRegion = terrain:CopyRegion(region)
			selectionEffect(nil,nil,'New Yeller',1,1.2,.5)
		end
	end,
	[ToolId.Fill] = function ()
		setButton(ToolId.Fill)
	end,
}

function TerrainRegionEditor.Init (toolName, theMouse)
	terrain = getTerrain()
	mouse = theMouse
	kCurrentTool = toolName

	if toolName == ToolId.Select then
		mode = "Select"
		tool = ToolId.Resize
	elseif toolName == ToolId.Move or toolName == ToolId.Resize or toolName == ToolId.Rotate then
		mode = "Edit"
		tool = toolName
	end

	FirstTimeSetup()
	on = true

	getOrCreateScreenGui()

	createSelectionPart()

	renderSelection()
	if terrain or kCurrentTool == ToolId.Select then
		toolSelect[kCurrentTool]()
	end
end

function TerrainRegionEditor.ChangeProperties(vals)
	kFillMaterial = vals.material
	kMergeEmpty = vals.mergeEmpty

	if (tool == ToolId.Move or tool == ToolId.Resize)
		and mode == "Edit" and selectionStart ~= nil then
		updateDragOperation()
	end
end

function TerrainRegionEditor.OnButtonClick ()
	if kCurrentTool == ToolId.Fill then
		if selectionStart and selectionEnd then
			local region = Region3.new((selectionStart - Vector3.new(1,1,1)) * resolution, selectionEnd * resolution)
			local regionSize = region.Size / resolution
			local emptyMaterialMap = make3DTable(regionSize,materialAir)
			local emptyOccupancyMap = make3DTable(regionSize,0)

			local beforeMaterialMap, beforeOccupancyMap = terrain:ReadVoxels(region, resolution)
			local newMaterialMap = {}
			local newOccupancyMap = {}
			for x = 1, regionSize.x do
				local xtm = {}
				local xto = {}
				for y = 1, regionSize.y do
					local ytm = {}
					local yto = {}
					for z = 1, regionSize.z do
						local beforeMaterial = beforeMaterialMap[x][y][z]

						if beforeMaterial == materialAir or beforeOccupancyMap[x][y][z] == 0 or not kMergeEmpty then	--'fillAir' variable is actually 'Merge Empty' to the user
							ytm[z] = kFillMaterial
						else
							ytm[z] = beforeMaterial
						end

						yto[z] = 1
					end
					xtm[y] = ytm
					xto[y] = yto
				end
				newMaterialMap[x] = xtm
				newOccupancyMap[x] = xto
			end

			if FFlagTerrainTrackAcquisitionMethod then
				terrain.LastUsedModificationMethod = Enum.TerrainAcquisitionMethod.RegionFillTool
			end
			
			terrain:WriteVoxels(region, resolution, newMaterialMap, newOccupancyMap)

			behindThis = {}
			behindThis.region = region
			behindThis.materials, behindThis.occupancies = emptyMaterialMap, emptyOccupancyMap

			lockInMap()
			changeHistory:SetWaypoint('Terrain Fill')
			selectionEffect(nil,nil,'Lime green',1.2,1,.5)
		end
	end
end

function TerrainRegionEditor.Close()
	clearSelection()
	behindThis = nil
	on = false
	kCurrentTool = nil
	mouse = nil
	tool = nil
	mode = "Select"
end

return TerrainRegionEditor
