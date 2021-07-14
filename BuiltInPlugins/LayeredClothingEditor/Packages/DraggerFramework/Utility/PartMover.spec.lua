local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent

local PartMover = require(DraggerFramework.Utility.PartMover)

return function()
	local function createPart()
		local part = Instance.new("Part", Workspace)
		part.Anchored = true
		part.CFrame = CFrame.new()
		part.Size = Vector3.new(1, 1, 1)
		return part
	end

	local function mapCFrames(parts)
		local cframeMap = {}
		for _, part in ipairs(parts) do
			cframeMap[part] = part.CFrame
		end
		return cframeMap
	end

	local function createTestParts(count)
		local parts = {}
		for i = 1, count or 1 do
			table.insert(parts, createPart())
		end
		return parts, mapCFrames(parts)
	end

	local function createTestJoint()
		local parts, originalCFrameMap = createTestParts(2)
		local joint = Instance.new("Weld")
		joint.Archivable = false
		joint.Part0 = parts[1]
		joint.Part1 = parts[2]
		joint.C0 = parts[1].CFrame:Inverse() * parts[2].CFrame
		joint.Parent = parts[1]

		return parts, originalCFrameMap, joint
	end

	local function createTestWeldConstraint()
		local parts, originalCFrameMap = createTestParts(2)
		local weld = Instance.new("WeldConstraint", parts[1])
		weld.Part0 = parts[1]
		weld.Part1 = parts[2]
		weld.Enabled = true

		return parts, originalCFrameMap, weld
	end

	beforeEach(function()
		for _, child in pairs(Workspace:GetChildren()) do
			if not child:IsA("Terrain") then
				child:Destroy()
			end
		end
	end)

	it("should create main part", function()
		local partMover = PartMover.new()
		local mainPart = partMover:getIgnorePart()

		expect(mainPart).to.be.ok()
		expect(mainPart.Archivable).to.equal(false)
		expect(mainPart.Transparency).to.equal(1)
	end)

	describe("setDragged", function()
		it("should not changed part anchoredness", function()
			local parts, originalCFrameMap = createTestParts(2)
			parts[1].Anchored = true
			parts[2].Anchored = false

			local partMover = PartMover.new()
			partMover:setDragged(parts, originalCFrameMap, false, Vector3.new(), {})
			expect(parts[1].Anchored).to.equal(true)
			expect(parts[2].Anchored).to.equal(false)
			partMover:commit()

			expect(parts[1].Anchored).to.equal(true)
			expect(parts[2].Anchored).to.equal(false)
		end)

		it("should disable welds to outside parts", function()
			local parts, originalCFrameMap, weld = createTestWeldConstraint()

			local partMover = PartMover.new()
			partMover:setDragged({parts[1]}, originalCFrameMap, true, Vector3.new(), {})
			local welded = weld.Enabled
			partMover:commit()

			expect(welded).to.equal(false)
		end)

		it("should not disable welds to inside parts", function()
			local parts, originalCFrameMap, weld = createTestWeldConstraint()

			local partMover = PartMover.new()
			partMover:setDragged(parts, originalCFrameMap, false, Vector3.new(), {})
			partMover:commit()

			expect(weld.Enabled).to.equal(true)
		end)

		it("should not break joints to inside parts", function()
			local parts, originalCFrameMap, joint = createTestJoint()

			local partMover = PartMover.new()
			partMover:setDragged(parts, originalCFrameMap, true, Vector3.new(), {})
			partMover:commit()

			expect(joint.Parent).to.be.ok()
		end)

		it("should break joints to outside parts", function()
			local parts, originalCFrameMap, joint = createTestJoint()

			local partMover = PartMover.new()
			partMover:setDragged({parts[1]}, originalCFrameMap, true, Vector3.new(), {})
			partMover:commit()

			expect(joint.Parent).to.equal(nil)
		end)

		it("should not fail if part has incomplete joint", function()
			expect(function()
				local parts, originalCFrameMap, joint = createTestJoint()
				joint.Part1 = nil

				local partMover = PartMover.new()
				partMover:setDragged(parts, originalCFrameMap, true, Vector3.new(), {})
				partMover:commit()
			end).never.to.throw()
		end)

		it("should not fail if part is not a descendant of Workspace", function()
			expect(function()
				local parts, originalCFrameMap = createTestParts(3)
				local viewportFrame = Instance.new("ViewportFrame", script.Parent)
				parts[1].Parent = nil
				parts[2].Parent = ServerStorage
				parts[3].Parent = viewportFrame

				local partMover = PartMover.new()
				partMover:setDragged(parts, originalCFrameMap, false, Vector3.new(), {})
				partMover:commit()
			end).never.to.throw()
		end)
	end)

	describe("commit", function()
		it("should restore anchored state", function()
			local parts, originalCFrameMap = createTestParts(2)
			parts[2].Anchored = false

			local partMover = PartMover.new()
			partMover:setDragged(parts, originalCFrameMap, false, Vector3.new(), {})
			partMover:commit()

			expect(parts[1].Anchored).to.equal(true)
			expect(parts[2].Anchored).to.equal(false)
		end)

		it("should restore welds to outside parts", function()
			local parts, originalCFrameMap, weld = createTestWeldConstraint()

			local partMover = PartMover.new()
			partMover:setDragged({parts[1]}, originalCFrameMap, false, Vector3.new(), {})
			partMover:commit()

			expect(weld.Enabled).to.equal(true)
		end)

		it("should error if parts not set", function()
			expect(function()
				local partMover = PartMover.new()
				partMover:commit()
			end).to.throw()
		end)
	end)

	describe("transformTo", function()
		it("should transform parts", function()
			local parts, originalCFrameMap = createTestParts(2)

			local partMover = PartMover.new()
			partMover:setDragged(parts, originalCFrameMap, false, Vector3.new(), {})
			local transform = CFrame.new(10, 0, 0)
			partMover:transformTo(transform)
			partMover:commit()

			for _, part in ipairs(parts) do
				local originalCFrame = originalCFrameMap[part]
				local appliedTransform = part.CFrame * originalCFrame:Inverse()

				expect(appliedTransform == transform).to.equal(true)
			end
		end)

		it("should error if parts not set", function()
			expect(function()
				local partMover = PartMover.new()
				partMover:transformTo(CFrame.new(10, 0, 0))
			end).to.throw()
		end)
	end)

	describe("computeJointPairs", function()
		it("should return correct joint pairs", function()
			local parts, originalCFrameMap = createTestParts(2)

			local partMover = PartMover.new()
			partMover:setDragged({parts[1]}, originalCFrameMap, false, Vector3.new(), {})
			local transform = CFrame.new(1, 0, 0)
			local jointPairs = partMover:computeJointPairs(transform)
			partMover:commit()

			expect(jointPairs).to.be.ok()
		end)

		it("should error if parts not set", function()
			expect(function()
				local partMover = PartMover.new()
				partMover:computeJointPairs(CFrame.new())
			end).to.throw()
		end)
	end)

	describe("isIntersectingOthers", function()
		it("should return true", function()
			local parts, originalCFrameMap = createTestParts(2)
			parts[1].CFrame = CFrame.new(0.2, 0.2, 0.2)

			local partMover = PartMover.new()
			partMover:setDragged({parts[1]}, originalCFrameMap, false, Vector3.new(), {})
			local result = partMover:isIntersectingOthers()
			partMover:commit()

			expect(result).to.equal(true)
		end)

		it("should return false", function()
			local parts, originalCFrameMap = createTestParts(2)
			parts[1].CFrame = CFrame.new(10000, 0, 0)

			local partMover = PartMover.new()
			partMover:setDragged({parts[1]}, originalCFrameMap, false, Vector3.new(), {})
			local result = partMover:isIntersectingOthers()
			partMover:commit()

			expect(result).to.equal(false)
		end)

		it("should error if parts not set", function()
			expect(function()
				local partMover = PartMover.new()
				partMover:isIntersectingOthers()
			end).to.throw()
		end)
	end)
end
