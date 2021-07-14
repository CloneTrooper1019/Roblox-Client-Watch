local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent
local JointMaker = require(DraggerFramework.Utility.JointMaker)

return function()
	local function createTestParts(count)
		local parts = {}
		for i = 1, count or 1 do
			local part = Instance.new("Part", Workspace)
			part.Anchored = true
			part.CFrame = CFrame.new()
			part.Size = Vector3.new(1, 1, 1)
			table.insert(parts, part)
		end
		return parts
	end

	local function createTestJoint()
		local parts = createTestParts(2)
		local joint = Instance.new("Weld", parts[1])
		joint.Archivable = false
		joint.Part0 = parts[1]
		joint.Part1 = parts[2]
		joint.C0 = parts[1].CFrame:Inverse() * parts[2].CFrame

		return parts, joint
	end

	local function createTestConstraint(className)
		local constraint = Instance.new(className)
		assert(constraint:IsA("Constraint"))

		local parts = createTestParts(2)
		parts[1].CFrame = CFrame.new(1, 0, 0)
		parts[2].CFrame = CFrame.new(-1, 0, 0)
		local attachment0 = Instance.new("Attachment", parts[1])
		local attachment1 = Instance.new("Attachment", parts[2])
		constraint.Attachment0 = attachment0
		constraint.Attachment1 = attachment1
		constraint.Parent = parts[1]

		return parts, constraint
	end

	local function createTestWeldConstraint()
		local parts = createTestParts(2)
		local weld = Instance.new("WeldConstraint", parts[1])
		weld.Part0 = parts[1]
		weld.Part1 = parts[2]
		weld.Enabled = true

		return parts, weld
	end

	beforeEach(function()
		for _, child in pairs(Workspace:GetChildren()) do
			if not child:IsA("Terrain") then
				child:Destroy()
			end
		end
	end)

	it("should anchor parts", function()
		local parts = createTestParts(2)
		parts[1].Anchored = false

		local jointMaker = JointMaker.new()
		jointMaker:pickUpParts(parts)
		jointMaker:anchorParts()

		expect(parts[1].Anchored).to.equal(true)
		expect(parts[2].Anchored).to.equal(true)

		jointMaker:restoreAnchored()

		expect(parts[1].Anchored).to.equal(false)
		expect(parts[2].Anchored).to.equal(true)
	end)

	it("should break joints to outsiders", function()
		local parts, joint = createTestJoint()

		local jointMaker = JointMaker.new()
		jointMaker:pickUpParts({parts[1]})
		jointMaker:breakJointsToOutsiders()

		expect(joint.Parent).to.equal(nil)
	end)

	it("should disconnect and reconnect internal joints", function()
		local parts, joint = createTestJoint()
		local jointPart1 = joint.Part1

		local jointMaker = JointMaker.new()
		jointMaker:pickUpParts(parts)
		jointMaker:disconnectInternalJoints()

		expect(joint.Part1).to.equal(nil)

		jointMaker:reconnectInternalJointsWithScale(1)

		expect(joint.Part1).to.equal(jointPart1)
	end)

	it("should disable and reenable WeldConstraints", function()
		local parts, weld = createTestWeldConstraint()

		local jointMaker = JointMaker.new()
		jointMaker:pickUpParts({parts[1]})

		expect(weld.Enabled).to.equal(false)

		jointMaker:putDownParts()

		expect(weld.Enabled).to.equal(true)
	end)

	it("should return correct joint pairs", function()
		local parts = createTestParts(2)
		parts[1].CFrame = CFrame.new(0, 0, 0)
		parts[2].CFrame = CFrame.new(1, 0, 0)

		local jointMaker = JointMaker.new()
		jointMaker:pickUpParts(parts)
		local jointPairs = jointMaker:computeJointPairs()

		expect(jointPairs).to.be.ok()
	end)

	describe("isColliding", function()
		it("should return true for touching parts based on option", function()
			local part = createTestParts()[1]
			local otherPart = createTestParts()[1]

			local jointMaker = JointMaker.new()
			jointMaker:pickUpParts({part})

			expect(jointMaker:isColliding(true)).to.equal(true)
			expect(jointMaker:isColliding(false)).to.equal(false)
		end)

		it("should return true for touching parts that were initially non-touching", function()
			local part = createTestParts()[1]
			local otherPart = createTestParts()[1]
			otherPart.CFrame = CFrame.new(1000, 0, 0)

			local jointMaker = JointMaker.new()
			jointMaker:pickUpParts({part})
			otherPart.CFrame = CFrame.new()

			expect(jointMaker:isColliding(true)).to.equal(true)
			expect(jointMaker:isColliding(false)).to.equal(true)
		end)

		it("should return false for non-touching parts", function()
			local part = createTestParts()[1]
			local otherPart = createTestParts()[1]
			otherPart.CFrame = CFrame.new(1000, 0, 0)

			local jointMaker = JointMaker.new()
			jointMaker:pickUpParts({part})

			expect(jointMaker:isColliding(true)).to.equal(false)
			expect(jointMaker:isColliding(false)).to.equal(false)
		end)

		it("should return false for non-touching parts that were initially touching", function()
			local part = createTestParts()[1]
			local otherPart = createTestParts()[1]

			local jointMaker = JointMaker.new()
			jointMaker:pickUpParts({part})
			otherPart.CFrame = CFrame.new(1000, 0, 0)

			expect(jointMaker:isColliding(true)).to.equal(false)
			expect(jointMaker:isColliding(false)).to.equal(false)
		end)
	end)

	it("should fix constraint lengths", function()
		local CONSTRAINT_TYPES = {"RodConstraint", "RopeConstraint", "SpringConstraint"}
		local SCALE = 2

		for _, type in ipairs(CONSTRAINT_TYPES) do
			local originalLength = 0
			local parts, constraint = createTestConstraint(type)
			if constraint:IsA("RodConstraint") or constraint:IsA("RopeConstraint") then
				originalLength = constraint.Length
			elseif constraint:IsA("SpringConstraint") then
				originalLength = constraint.FreeLength
			end
			assert(originalLength > 0)

			local direction = parts[1].Position - parts[2].Position
			local offset = direction.Unit * (direction.Magnitude * SCALE)

			local jointMaker = JointMaker.new()
			jointMaker:pickUpParts(parts)
			parts[2].Position = parts[1].Position + offset
			jointMaker:fixupConstraintLengths()

			if constraint:IsA("SpringConstraint") then
				expect(constraint.FreeLength).to.equal(originalLength * SCALE)
			end
		end
	end)
end
