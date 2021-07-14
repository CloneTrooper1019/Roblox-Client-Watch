local Workspace = game:GetService("Workspace")

local DraggerFramework = script.Parent.Parent
local Library = DraggerFramework.Parent.Parent
local Roact = require(Library.Packages.Roact)

local JointMaker = require(DraggerFramework.Utility.JointMaker)

return function()
	local function createTestParts(count)
		local parts = {}
		for _ = 1, count or 1 do
			local part = Instance.new("Part", Workspace)
			part.Anchored = true
			part.CFrame = CFrame.new()
			part.Size = Vector3.new(1, 1, 1)
			table.insert(parts, part)
		end
		return parts
	end

	local function createTestJointPairs(parts)
		local jointMaker = JointMaker.new()
		jointMaker:pickUpParts(parts)
		local jointPairs = jointMaker:computeJointPairs()
		jointMaker:putDownParts()
		return jointPairs
	end

	beforeEach(function()
		for _, child in pairs(Workspace:GetChildren()) do
			if not child:IsA("Terrain") then
				child:Destroy()
			end
		end
	end)

	describe("renderJoints", function()
		it("should render joints for touching parts", function()
			local parts = createTestParts(3)
			parts[1].CFrame = CFrame.new(-1, 0, 0)
			parts[2].CFrame = CFrame.new(0, 0, 0)
			parts[3].CFrame = CFrame.new(1, 0, 0)

			local jointPairs = createTestJointPairs({parts[2]})
			local jointDisplay = jointPairs:renderJoints(1)

			local container = Instance.new("Folder")
			local handle = Roact.mount(jointDisplay, container)

			expect(jointDisplay).to.be.ok()
			expect(#container:GetChildren()).to.equal(4)

			Roact.unmount(handle)
		end)

		it("should not render if there are no touching parts", function()
			local parts = createTestParts(2)
			parts[1].CFrame = CFrame.new(1000, 0, 0)

			local jointPairs = createTestJointPairs(parts)
			local jointDisplay = jointPairs:renderJoints(1)

			local container = Instance.new("Folder")
			local handle = Roact.mount(jointDisplay, container)

			expect(jointDisplay).to.be.ok()
			expect(#container:GetChildren()).to.equal(0)

			Roact.unmount(handle)
		end)
	end)

	local function getWorkspaceJointsSet()
		local joints = {}
		for _, object in ipairs(Workspace:GetDescendants()) do
			if object:IsA("JointInstance") then
				joints[object] = true
			end
		end
		return joints
	end

	local function getNewWorkspaceJoints(originalJointsSet)
		local currentJointsSet = getWorkspaceJointsSet()
		local newJoints = {}
		for joint, _ in pairs(currentJointsSet) do
			if not originalJointsSet[joint] then
				table.insert(newJoints, joint)
			end
		end
		return newJoints
	end

	describe("createJoints", function()
		it("should create joints for touching parts", function()
			local parts = createTestParts(3)
			parts[1].Position = Vector3.new(1, 0, 0)
			parts[2].Position = Vector3.new(0, 0, 0)
			parts[3].Position = Vector3.new(-1, 0, 0)

			local jointPairs = createTestJointPairs({parts[2]})
			local originalJointsSet = getWorkspaceJointsSet()
			jointPairs:createJoints()

			local newJoints = getNewWorkspaceJoints(originalJointsSet)
			expect(#newJoints).to.equal(2)
		end)

		it("should do nothing if parts not set", function()
			createTestJointPairs({})
			local originalJointsSet = getWorkspaceJointsSet()

			local newJoints = getNewWorkspaceJoints(originalJointsSet)
			expect(#newJoints).to.equal(0)
		end)
	end)
end
