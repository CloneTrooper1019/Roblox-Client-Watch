local Workspace = game:GetService("Workspace")

local DraggerSchemaCore = script.Parent
local Packages = DraggerSchemaCore.Parent
local DraggerFramework = Packages.DraggerFramework

local shouldDragAsFace = require(DraggerFramework.Utility.shouldDragAsFace)

local getFFlagMultiSelectionPivot = require(DraggerFramework.Flags.getFFlagMultiSelectionPivot)
local FFlagMultiSelectionPivot = getFFlagMultiSelectionPivot()

local function computeBoundingBox(basisCFrame, allParts, allAttachments)
	local inverseBasis = basisCFrame:Inverse()
	local xmin, xmax = math.huge, -math.huge
	local ymin, ymax = math.huge, -math.huge
	local zmin, zmax = math.huge, -math.huge

	local terrain = Workspace.Terrain

	for _, part in ipairs(allParts) do
		if part ~= terrain then
			local cframe = part.CFrame
			local size = part.Size
			local sx, sy, sz = size.X, size.Y, size.Z

			-- Calculation for bounding box in the space of basisCFrame1
			local localCFrame1 = inverseBasis * cframe -- put cframe in our local basis
			local _, _, _,
				t00, t01, t02,
				t10, t11, t12,
				t20, t21, t22 = localCFrame1:components()
			local hw = 0.5 * (math.abs(sx * t00) + math.abs(sy * t01) + math.abs(sz * t02))
			local hh = 0.5 * (math.abs(sx * t10) + math.abs(sy * t11) + math.abs(sz * t12))
			local hd = 0.5 * (math.abs(sx * t20) + math.abs(sy * t21) + math.abs(sz * t22))
			local x, y, z = localCFrame1.X, localCFrame1.Y, localCFrame1.Z
			xmin = math.min(xmin, x - hw)
			xmax = math.max(xmax, x + hw)
			ymin = math.min(ymin, y - hh)
			ymax = math.max(ymax, y + hh)
			zmin = math.min(zmin, z - hd)
			zmax = math.max(zmax, z + hd)
		end
	end
	for _, attachment in ipairs(allAttachments) do
		local localPosition = basisCFrame:PointToObjectSpace(attachment.WorldPosition)
		local x, y, z = localPosition.X, localPosition.Y, localPosition.Z
		xmin = math.min(xmin, x)
		xmax = math.max(xmax, x)
		ymin = math.min(ymin, y)
		ymax = math.max(ymax, y)
		zmin = math.min(zmin, z)
		zmax = math.max(zmax, z)
	end

	local boundingBoxOffset = Vector3.new(
		0.5 * (xmin + xmax),
		0.5 * (ymin + ymax),
		0.5 * (zmin + zmax)
	)
	local boundingBoxSize = Vector3.new(
		xmax - xmin,
		ymax - ymin,
		zmax - zmin
	)

	return boundingBoxOffset, boundingBoxSize
end

--[[
	Micro-optimized code for computing a local space and the global space
	bounding box for a set of parts and attachments as fast as possible.
]]
local function computeTwoBoundingBoxes(basisCFrame1, allParts, allAttachments)
	local basisX, basisY, basisZ = basisCFrame1.X, basisCFrame1.Y, basisCFrame1.Z
	local inverseBasis1 = basisCFrame1:Inverse()
	local xmin1, xmax1 = math.huge, -math.huge
	local ymin1, ymax1 = math.huge, -math.huge
	local zmin1, zmax1 = math.huge, -math.huge
	local xmin2, xmax2 = math.huge, -math.huge
	local ymin2, ymax2 = math.huge, -math.huge
	local zmin2, zmax2 = math.huge, -math.huge

	local terrain = Workspace.Terrain

	for _, part in ipairs(allParts) do
		if part ~= terrain then
			local cframe = part.CFrame
			local size = part.Size
			local sx, sy, sz = size.X, size.Y, size.Z

			-- Calculation for bounding box in the space of basisCFrame1
			local localCFrame1 = inverseBasis1 * cframe -- put cframe in our local basis
			local _, _, _,
				t00, t01, t02,
				t10, t11, t12,
				t20, t21, t22 = localCFrame1:components()
			local hw1 = 0.5 * (math.abs(sx * t00) + math.abs(sy * t01) + math.abs(sz * t02))
			local hh1 = 0.5 * (math.abs(sx * t10) + math.abs(sy * t11) + math.abs(sz * t12))
			local hd1 = 0.5 * (math.abs(sx * t20) + math.abs(sy * t21) + math.abs(sz * t22))
			local x1, y1, z1 = localCFrame1.X, localCFrame1.Y, localCFrame1.Z
			xmin1 = math.min(xmin1, x1 - hw1)
			xmax1 = math.max(xmax1, x1 + hw1)
			ymin1 = math.min(ymin1, y1 - hh1)
			ymax1 = math.max(ymax1, y1 + hh1)
			zmin1 = math.min(zmin1, z1 - hd1)
			zmax1 = math.max(zmax1, z1 + hd1)

			-- Calculation for the bounding box in the global coordinate space
			_, _, _,
				t00, t01, t02,
				t10, t11, t12,
				t20, t21, t22 = cframe:components()
			local hw2 = 0.5 * (math.abs(sx * t00) + math.abs(sy * t01) + math.abs(sz * t02))
			local hh2 = 0.5 * (math.abs(sx * t10) + math.abs(sy * t11) + math.abs(sz * t12))
			local hd2 = 0.5 * (math.abs(sx * t20) + math.abs(sy * t21) + math.abs(sz * t22))
			local x2, y2, z2 = cframe.X, cframe.Y, cframe.Z
			xmin2 = math.min(xmin2, x2 - hw2)
			xmax2 = math.max(xmax2, x2 + hw2)
			ymin2 = math.min(ymin2, y2 - hh2)
			ymax2 = math.max(ymax2, y2 + hh2)
			zmin2 = math.min(zmin2, z2 - hd2)
			zmax2 = math.max(zmax2, z2 + hd2)
		end
	end
	for _, attachment in ipairs(allAttachments) do
		local worldPosition = attachment.WorldPosition

		local localPosition = inverseBasis1 * worldPosition
		local localX, localY, localZ = localPosition.X, localPosition.Y, localPosition.Z
		xmin1 = math.min(xmin1, localX)
		xmax1 = math.max(xmax1, localX)
		ymin1 = math.min(ymin1, localY)
		ymax1 = math.max(ymax1, localY)
		zmin1 = math.min(zmin1, localZ)
		zmax1 = math.max(zmax1, localZ)

		local globalX, globalY, globalZ = worldPosition.X, worldPosition.Y, worldPosition.Z
		xmin2 = math.min(xmin2, globalX)
		xmax2 = math.max(xmax2, globalX)
		ymin2 = math.min(ymin2, globalY)
		ymax2 = math.max(ymax2, globalY)
		zmin2 = math.min(zmin2, globalZ)
		zmax2 = math.max(zmax2, globalZ)
	end

	local localBoundingBoxOffset = Vector3.new(
		0.5 * (xmin1 + xmax1),
		0.5 * (ymin1 + ymax1),
		0.5 * (zmin1 + zmax1)
	)
	local localBoundingBoxSize = Vector3.new(
		xmax1 - xmin1,
		ymax1 - ymin1,
		zmax1 - zmin1
	)

	local globalBoundingBoxOffset = Vector3.new(
		0.5 * (xmin2 + xmax2) - basisX,
		0.5 * (ymin2 + ymax2) - basisY,
		0.5 * (zmin2 + zmax2) - basisZ
	)
	local globalBoundingBoxSize = Vector3.new(
		xmax2 - xmin2,
		ymax2 - ymin2,
		zmax2 - zmin2
	)

	return localBoundingBoxOffset, localBoundingBoxSize,
		globalBoundingBoxOffset, globalBoundingBoxSize
end

--[[
	Find all of the "roots" bones in a list of Bones. One of the bones in the
	list is a root iff it is not a descendant of any of the other root bones.
]]
local function markBoneRecursive(bone, movedSet, rootBoneMap)
	if movedSet[bone] then
		rootBoneMap[bone] = nil
	else
		movedSet[bone] = true
		for _, ch in ipairs(bone:GetChildren()) do
			markBoneRecursive(ch, movedSet, rootBoneMap)
		end
	end
end
local function findRootBoneMap(boneList)
	local rootBoneMap = {}
	local movedSet = {}
	for _, bone in ipairs(boneList) do
		if not movedSet[bone] then
			rootBoneMap[bone] = bone:FindFirstAncestorWhichIsA("BasePart")
			markBoneRecursive(bone, movedSet, rootBoneMap)
		end
	end
	return rootBoneMap
end

local function computeInfo(draggerContext, selectedObjects)
	local isSimulating = draggerContext:isSimulating()
	local useLocalSpace = draggerContext:shouldUseLocalSpace()

	local allParts = table.create(64)
	local allPartSet = {}
	local allAttachments = {}
	local allBones = {}
	local allModels = {}
	local allInstancesWithConfigurableFace = {}
	local basisObject = nil
	local terrain = Workspace.Terrain
	local selectedPVInstanceCount = 0

	for _, instance in ipairs(selectedObjects) do
		if instance:IsA("Model") then
			selectedPVInstanceCount += 1
			table.insert(allModels, instance)
			basisObject = instance
		elseif instance:IsA("BasePart") then
			selectedPVInstanceCount += 1
			if not allPartSet[instance] and instance ~= terrain then
				table.insert(allParts, instance)
				allPartSet[instance] = true
				basisObject = instance
			end
		elseif shouldDragAsFace(instance) then
			table.insert(allInstancesWithConfigurableFace, instance)
		elseif instance:IsA("Attachment") then
			if instance:IsA("Bone") then
				table.insert(allBones, instance)
			else
				table.insert(allAttachments, instance)
			end
		end
		-- It is possible to place parts inside of other parts, so this isn't an else on the prior if.
		for _, descendant in ipairs(instance:GetDescendants()) do
			if descendant:IsA("BasePart") and not allPartSet[descendant] and descendant ~= terrain then
				table.insert(allParts, descendant)
				allPartSet[descendant] = true
				-- Note: This is a helpful feature to still allow people to drag
				-- non-Model objects that still typically have parts inside of
				-- them like Folders and Tools.
				basisObject = basisObject or descendant
			elseif descendant:IsA("Model") then
				if FFlagMultiSelectionPivot then
					basisObject = basisObject or descendant
				end
				table.insert(allModels, descendant)
			end
		end
	end

	-- Build a table of only the "interesting" attachments, that is, those
	-- which aren't underneath one of the selected parts.
	local interestingAttachments = {}
	for _, attachment in ipairs(allAttachments) do
		if not allPartSet[attachment.Parent] then
			table.insert(interestingAttachments, attachment)
		end
	end

	-- Figure out what bones in the list of bones are "roots" that are not
	-- relative to another bone we are already moving. Then add those bones to
	-- the above list of "interesting"a attachments.
	local rootBoneMap = findRootBoneMap(allBones)
	for attachment, ancestorPart in pairs(rootBoneMap) do
		if not allPartSet[ancestorPart] then
			table.insert(interestingAttachments, attachment)
		end
	end
	
	-- Look for a pivot:
	-- * If there are any PVInstances in the selection, use the pivot of the
	--   last one in the selection (the most recently selected one)
	-- * As a fallback when no PVInstances are selected, try to use the 
	--   WorldCFrame of an Attachment in the selection.
	local isMultiSelection
	local basisCFrame = nil
	if basisObject then
		local specialIgnore =
			draggerContext.ScaleToolSpecialCaseIgnorePivotWithSinglePartSelected and
			#selectedObjects == 1 and
			selectedObjects[1]:IsA("BasePart")
		if specialIgnore then
			basisCFrame = basisObject.CFrame
		else
			basisCFrame = basisObject:GetPivot()
		end
		if FFlagMultiSelectionPivot then
			-- If the selected instance count is:
			-- * Greater than 1, then we naturally have a multiselection
			-- * Equal to zero, then we should still treat it like a multi
			--   selection for the purposes of moving any descendant objects.
			isMultiSelection = selectedPVInstanceCount ~= 1
		end
	elseif FFlagMultiSelectionPivot and #interestingAttachments > 0 then
		basisCFrame = interestingAttachments[1].WorldCFrame

		-- We use interestingAttachments here because if you box selected
		-- to select multiple bones here, if there's only one effective
		-- root bone to be moved, you still want to use that bone as the
		-- pivot, but if multiple root bones were selected then we have to
		-- fall back to pivoting around the center of the bounding box.
		-- (Setting isMultiSelection = true causes the pivot to be the
		-- center of the bounding box)
		if #interestingAttachments > 1 then
			isMultiSelection = true
		end
	elseif FFlagMultiSelectionPivot then
		basisCFrame = CFrame.new()
		isMultiSelection = false
	end

	-- Use attachment CFrame as a backup if there weren't any parts in the
	-- selection to set the basisCFrame with. Attachment CFrames should ONLY
	-- be used as a basis if there aren't any parts to go off of.
	if not FFlagMultiSelectionPivot and not basisCFrame then
		if #allAttachments > 0 then
			basisCFrame = allAttachments[#allAttachments].WorldCFrame
		elseif #allBones > 0 then
			basisCFrame = allBones[#allBones].WorldCFrame
		else
			basisCFrame = CFrame.new()
		end
	end

	-- Store original CFrames so while moving parts we don't run into floating
	-- point error problems by using relative moves.
	local originalCFrameMap = {}
	for _, part in ipairs(allParts) do
		originalCFrameMap[part] = part.CFrame
	end

	-- Figure out if any of the objects in the selection are physically free
	-- moving parts. If there are, we will need to update the selection info
	-- every frame because those parts may have moved.
	local selectionHasPhysics = false
	if isSimulating then
		for _, part in ipairs(allParts) do
			if not part:IsGrounded() then
				selectionHasPhysics = true
				break
			end
		end
		if not selectionHasPhysics then
			for _, attachment in ipairs(allAttachments) do
				local parentPart = attachment.Parent
				if parentPart and not parentPart:IsGrounded() then
					selectionHasPhysics = true
					break
				end
			end
			for attachment, ancestorPart in pairs(rootBoneMap) do
				if not ancestorPart:IsGrounded() then
					selectionHasPhysics = true
				end
			end
		end
	end

	-- Finally add all the bones to the list of all attachments, because we want
	-- to pass back a list of all the selected things that inherit Attachment.
	-- We don't do this earlier because for the preceeding code we want to
	-- treat Bones and non-Bone Attachments slightily differently.
	-- We re-use the allAttachments table for this purpose to avoid allocating
	-- another table of both attachments and bones.
	for _, bone in ipairs(allBones) do
		table.insert(allAttachments, bone)
	end

	-- Build the basisCFrame aligned bounding box.
	-- Local = always the local space. Needed because freeform dragging always
	-- uses the local space bounding box.
	local localBasisCFrame = basisCFrame
	local localBoundingBoxOffset, localBoundingBoxSize

	-- Chosen = local or global depending on the UseLocalSpace setting
	local chosenBasisCFrame
	local chosenBoundingBoxOffset, chosenBoundingBoxSize

	if useLocalSpace then
		localBoundingBoxOffset, localBoundingBoxSize =
			computeBoundingBox(localBasisCFrame, allParts, allAttachments)

		chosenBasisCFrame = localBasisCFrame
		chosenBoundingBoxOffset, chosenBoundingBoxSize =
			localBoundingBoxOffset, localBoundingBoxSize
	else
		localBoundingBoxOffset, localBoundingBoxSize,
			chosenBoundingBoxOffset, chosenBoundingBoxSize =
			computeTwoBoundingBoxes(localBasisCFrame, allParts, allAttachments)

		chosenBasisCFrame = CFrame.new(basisCFrame.Position)
	end

	-- If we have a multi-selection, the pivot should be moved to the center
	-- of the bounding box.
	if FFlagMultiSelectionPivot and isMultiSelection then
		localBasisCFrame *= CFrame.new(localBoundingBoxOffset)
		localBoundingBoxOffset = Vector3.new()
		chosenBasisCFrame *= CFrame.new(chosenBoundingBoxOffset)
		chosenBoundingBoxOffset = Vector3.new()
	end

	return {
		-- basisCFrame is the CFrame which the selection will be transformed
		-- relative to when transforming it.
		basisCFrame = chosenBasisCFrame,

		-- If a PVInstance is selected, the PVInstance that the pivot was
		-- read from.
		basisObject = basisObject,

		-- boundingBoxSize is the size of the bounding box, as oriented around
		-- the basisCFrame.
		boundingBoxSize = chosenBoundingBoxSize,

		-- boundingBoxOffset is the offset of the center of the bounding box
		-- from the basisCFrame's position. basisCFrame will always be
		-- somewhere in the bounding box, but not necessarily at the center.
		boundingBoxOffset = chosenBoundingBoxOffset,

		-- This is a local space variant of the above set of properties. If the
		-- user is working in local space, then basisCFrame = localBasisCFrame,
		-- but they will differ if they have chosen a different frame of
		-- reference to work in.
		localBasisCFrame = localBasisCFrame,
		localBoundingBoxSize = localBoundingBoxSize,
		localBoundingBoxOffset = localBoundingBoxOffset,

		-- Parts and Attachments are the arrays of parts and attachments that
		-- need to be updated when transforming the selection.
		parts = allParts,
		partSet = allPartSet,
		attachments = interestingAttachments,
		models = allModels,

		-- All the attachments, including ones under parts in the list of parts
		-- to move. We still need these for some edge case behavior.
		allAttachments = allAttachments,

		-- OriginalCFrameMap stores the cframes of the parts before any
		-- transformation was applied to the selection.
		originalCFrameMap = originalCFrameMap,

		-- Are any of the parts in the selection physically free moving
		hasPhysics = selectionHasPhysics,

		-- Instances with configurable faces
		instancesWithConfigurableFace = allInstancesWithConfigurableFace,
	}
end

local SelectionInfo = {}
SelectionInfo.__index = SelectionInfo

function SelectionInfo.new(draggerContext, selection)
	return setmetatable(computeInfo(draggerContext, selection), SelectionInfo)
end

--[[
	Core schema specific
	Used to optimize dragger performance, returns a new SelectionInfo which
	is the same as this SelectionInfo, but transformed by a world transform.
]]
function SelectionInfo:getTransformedCopy(globalTransform)
	local copy = {}
	for k, v in pairs(self) do
		copy[k] = v
	end
	copy.basisCFrame = globalTransform * copy.basisCFrame
	copy.localBasisCFrame = globalTransform * copy.localBasisCFrame
	local transformedOriginalCFrames = {}
	for k, cframe in pairs(copy.originalCFrameMap) do
		transformedOriginalCFrames[k] = globalTransform * cframe
	end
	copy.originalCFrameMap = transformedOriginalCFrames
	return setmetatable(copy, SelectionInfo)
end

function SelectionInfo:isEmpty()
	return #self.parts == 0 and #self.attachments == 0
end

function SelectionInfo:getBoundingBox()
	return self.basisCFrame, self.boundingBoxOffset, self.boundingBoxSize
end

function SelectionInfo:doesContainItem(item)
	return self.partSet[item] ~= nil
end

function SelectionInfo:isDynamic()
	return self.hasPhysics
end

--[[
	Core schema specific
	Returns: A map of where selected parts originally were before we started
	moving them.
]]
function SelectionInfo:getOriginalCFrameMap()
	return self.originalCFrameMap
end

--[[
	Core schema specific
	Returns: The local space bounding box even when Use Local Space is false.
]]
function SelectionInfo:getLocalBoundingBox()
	return self.localBasisCFrame, self.localBoundingBoxOffset, self.localBoundingBoxSize
end

-- Core schema specific
function SelectionInfo:getObjectsToTransform()
	return self.parts, self.attachments, self.models
end

-- Core schema specific
function SelectionInfo:getBasisObject()
	return self.basisObject
end

--[[
	Core schema specific
	The attachments returned by getObjectsToTransform only includes the
	attachments which are not underneath one of the parts to transform. This
	method on the other hand, returns all of the selected attachments regardless
	of parent.
]]
function SelectionInfo:getAllAttachments()
	return self.allAttachments
end

return SelectionInfo