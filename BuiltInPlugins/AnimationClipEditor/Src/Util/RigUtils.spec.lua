return function()
	local Plugin = script.Parent.Parent.Parent
	local RigUtils = require(script.Parent.RigUtils)
	local Constants = require(script.Parent.Constants)
	local isEmpty = require(script.Parent.isEmpty)
	local deepCopy = require(script.Parent.deepCopy)

	local GetFFlagFacialAnimationSupport = require(Plugin.LuaFlags.GetFFlagFacialAnimationSupport)

	local testRigAnimationData = {
		Metadata = {
			Name = "Test Rig Animation",
			StartFrame = 0,
			EndFrame = 0,
			FrameRate = 30,
			Looping = true,
			Priority = Enum.AnimationPriority.Idle,
		},
		Events = {
			NamedKeyframes = {},
			Keyframes = {0},
			Data = {
				[0] = {
					TestEvent = "TestValue",
				},
			},
		},
		Instances = {
			Root = {
				Type = "Rig",
				Tracks = {
					["Head"] = {
						Type = GetFFlagFacialAnimationSupport() and Constants.TRACK_TYPES.CFrame or nil,
						Keyframes = {0},
						Data = {
							[0] = {
								Value = CFrame.new(0, 1, 0),
								EasingStyle = Enum.PoseEasingStyle.Linear,
								EasingDirection = Enum.PoseEasingDirection.In,
							},
						}
					},
					["UpperTorso"] = {
						Type = GetFFlagFacialAnimationSupport() and Constants.TRACK_TYPES.CFrame or nil,
						Keyframes = {0},
						Data = {
							[0] = {
								Value = CFrame.new(1, 0, 0),
								EasingStyle = Enum.PoseEasingStyle.Linear,
								EasingDirection = Enum.PoseEasingDirection.In,
							},
						}
					},
				},
			},
		},
	}

	local function buildTestKeyframeSequence()
		local keyframeSequence = Instance.new("KeyframeSequence")
		local keyframe = Instance.new("Keyframe", keyframeSequence)
		keyframe.Time = 0
		local rootPose = Instance.new("Pose", keyframe)
		rootPose.Name = "HumanoidRootPart"
		rootPose.Weight = 0
		local torsoPose = Instance.new("Pose", rootPose)
		torsoPose.Name = "UpperTorso"
		local headPose = Instance.new("Pose", torsoPose)
		headPose.Name = "Head"
		headPose.CFrame = CFrame.new(1, 0, 0)
		keyframeSequence.Name = "KeyframeSequence"
		keyframeSequence.Loop = false
		keyframeSequence.Priority = Enum.AnimationPriority.Idle
		local marker = Instance.new("KeyframeMarker", keyframe)
		marker.Name = "TestEvent"
		marker.Value = "TestValue"
		return keyframeSequence
	end

	-- A KeyframeSequence with a frame set at a weird time.
	local function buildTestBadKeyframeSequence()
		local keyframeSequence = Instance.new("KeyframeSequence")
		local keyframe = Instance.new("Keyframe", keyframeSequence)
		keyframe.Time = 0.00001
		local pose = Instance.new("Pose", keyframe)
		pose.Name = "UpperTorso"
		keyframeSequence.Name = "KeyframeSequence"
		keyframeSequence.Loop = false
		keyframeSequence.Priority = Enum.AnimationPriority.Idle
		return keyframeSequence
	end

	local function buildTestRig()
		local model = Instance.new("Model")
		local root = Instance.new("Part", model)
		root.Name = "HumanoidRootPart"
		local torso = Instance.new("Part", model)
		torso.Name = "UpperTorso"
		local head = Instance.new("Part", model)
		head.Name = "Head"
		local torsoJoint = Instance.new("Motor6D", torso)
		torsoJoint.Part0 = root
		torsoJoint.Part1 = torso
		local headJoint = Instance.new("Motor6D", head)
		headJoint.Part0 = torso
		headJoint.Part1 = head

		local rootToUpperTorsoAttach = Instance.new("Attachment", root)
		rootToUpperTorsoAttach.Name = "RootAttachment"

		local upperTorsoToRootAttach = Instance.new("Attachment", torso)
		upperTorsoToRootAttach.Name = "RootAttachment"

		local upperTorsoToHeadAttach = Instance.new("Attachment", torso)
		upperTorsoToHeadAttach.Name = "NeckAttachment"

		local headToUpperTorsoAttach = Instance.new("Attachment", head)
		headToUpperTorsoAttach.Name = "NeckAttachment"

		local constraint = Instance.new("BallSocketConstraint", model)
		constraint.Enabled = false
		constraint.Attachment0 = upperTorsoToHeadAttach
		constraint.Attachment1 = headToUpperTorsoAttach

		Instance.new("AnimationController", model)
		local bone = Instance.new("Bone", head)
		bone.Name = "Jaw"

		return model
	end

	describe("buildRigHierarchy", function()
		it("should build a rig hierarchy table", function()
			local testRig = buildTestRig()
			local hierarchy = RigUtils.buildRigHierarchy(testRig)

			expect(hierarchy).to.be.ok()
			expect(hierarchy.HumanoidRootPart).to.be.ok()
			expect(hierarchy.HumanoidRootPart.UpperTorso).to.be.ok()
			expect(hierarchy.HumanoidRootPart.UpperTorso.Head).to.be.ok()
		end)
	end)

	describe("getUnusedRigTracks", function()
		it("should return a list of tracks which are unused", function()
			local testRig = buildTestRig()
			local tracks = {{Name = "HumanoidRootPart"}}
			local unused = RigUtils.getUnusedRigTracks(testRig, tracks)

			expect(unused).to.be.ok()
			expect(#unused).to.equal(3)
			expect(unused[1].Name).to.equal("Head")
			expect(unused[2].Name).to.equal("Jaw")
			expect(unused[3].Name).to.equal("UpperTorso")
		end)
	end)

	describe("fromRigAnimation", function()
		it("should create a new AnimationData", function()
			local keyframeSequence = buildTestKeyframeSequence()
			local animationData = RigUtils.fromRigAnimation(keyframeSequence, 30)
			expect(animationData).to.be.ok()
			expect(animationData.Instances).to.be.ok()
			expect(animationData.Instances.Root).to.be.ok()
			expect(animationData.Instances.Root.Tracks).to.be.ok()
			local tracks = animationData.Instances.Root.Tracks
			expect(tracks.Head).to.be.ok()
			expect(tracks.Head.Keyframes).to.be.ok()
			expect(tracks.Head.Data).to.be.ok()
			expect(tracks.UpperTorso).to.be.ok()
			expect(tracks.UpperTorso.Keyframes).to.be.ok()
			expect(tracks.UpperTorso.Data).to.be.ok()
		end)

		it("should ignore tracks with 0 weight", function()
			local keyframeSequence = buildTestKeyframeSequence()
			local animationData = RigUtils.fromRigAnimation(keyframeSequence, 30)
			local tracks = animationData.Instances.Root.Tracks
			expect(tracks.HumanoidRootPart).never.to.be.ok()
		end)

		it("should set the correct values", function()
			local keyframeSequence = buildTestKeyframeSequence()
			local animationData = RigUtils.fromRigAnimation(keyframeSequence, 30)
			local tracks = animationData.Instances.Root.Tracks
			expect(#tracks.Head.Keyframes).to.equal(1)
			expect(#tracks.UpperTorso.Keyframes).to.equal(1)
			expect(tracks.Head.Data[0]).to.be.ok()
			expect(tracks.UpperTorso.Data[0]).to.be.ok()
			expect(tracks.Head.Data[0].Value).to.equal(CFrame.new(1, 0, 0))
			expect(tracks.UpperTorso.Data[0].Value).to.equal(CFrame.new())
		end)

		it("should set the metadata", function()
			local keyframeSequence = buildTestKeyframeSequence()
			local animationData = RigUtils.fromRigAnimation(keyframeSequence, 30)
			local metadata = animationData.Metadata
			expect(metadata).to.be.ok()
			expect(metadata.Name).to.equal("KeyframeSequence")
			expect(metadata.Looping).to.equal(false)
			expect(metadata.Priority).to.equal(Enum.AnimationPriority.Idle)
		end)

		it("should snap keyframes to the nearest frame within an epsilon tolerance", function()
			local keyframeSequence = buildTestBadKeyframeSequence()
			local animationData = RigUtils.fromRigAnimation(keyframeSequence, 30, 0.1)
			local tracks = animationData.Instances.Root.Tracks
			expect(#tracks.UpperTorso.Keyframes).to.equal(1)
			expect(tracks.UpperTorso.Keyframes[1]).to.equal(0)
		end)

		it("should create an event for every KeyframeMarker", function()
			local keyframeSequence = buildTestKeyframeSequence()
			local animationData = RigUtils.fromRigAnimation(keyframeSequence, 30)
			expect(#animationData.Events.Keyframes).to.equal(1)
			expect(animationData.Events.Data[0]).to.be.ok()
			expect(animationData.Events.Data[0].TestEvent).to.be.ok()
			expect(animationData.Events.Data[0].TestEvent).to.equal("TestValue")
		end)

		it("should throw if the expected KeyframeSequence is not correct", function()
			expect(function()
				RigUtils.fromRigAnimation(nil, 30)
			end).to.throw()

			expect(function()
				RigUtils.fromRigAnimation({}, 30)
			end).to.throw()

			expect(function()
				RigUtils.fromRigAnimation(Instance.new("Folder"), 30)
			end).to.throw()
		end)

		it("should throw if the expected frame rate is not correct", function()
			expect(function()
				RigUtils.fromRigAnimation(buildTestKeyframeSequence())
			end).to.throw()

			expect(function()
				RigUtils.fromRigAnimation(buildTestKeyframeSequence(), 0)
			end).to.throw()
		end)

		it("should not set a keyframe's name if it was the default name", function()
			local keyframeSequence = buildTestKeyframeSequence()
			local animationData = RigUtils.fromRigAnimation(keyframeSequence, 30)
			local namedKeyframes = animationData.Events.NamedKeyframes
			expect(isEmpty(namedKeyframes)).to.equal(true)
		end)

		it("should import keyframe names", function()
			local keyframeSequence = buildTestKeyframeSequence()
			keyframeSequence.Keyframe.Name = "TestName"
			local animationData = RigUtils.fromRigAnimation(keyframeSequence, 30)
			local namedKeyframes = animationData.Events.NamedKeyframes
			expect(namedKeyframes[0]).to.equal("TestName")
		end)
	end)

	describe("toRigAnimation", function()
		it("should create a new KeyframeSequence", function()
			local rig = buildTestRig()
			local keyframeSequence = RigUtils.toRigAnimation(testRigAnimationData, rig)
			expect(keyframeSequence).to.be.ok()
			expect(typeof(keyframeSequence)).to.equal("Instance")
			expect(keyframeSequence.ClassName).to.equal("KeyframeSequence")
			expect(#keyframeSequence:GetKeyframes()).to.equal(1)
		end)

		it("should set the correct values", function()
			local rig = buildTestRig()
			local keyframeSequence = RigUtils.toRigAnimation(testRigAnimationData, rig)
			expect(keyframeSequence.Keyframe.Time).to.equal(0)
			local root = keyframeSequence.Keyframe:FindFirstChild("HumanoidRootPart")
			expect(root).to.be.ok()
			expect(root.Weight).to.equal(0)
			expect(root:FindFirstChild("UpperTorso")).to.be.ok()
			expect(root.UpperTorso.Weight).to.equal(1)
			expect(root.UpperTorso.CFrame).to.equal(CFrame.new(1, 0, 0))
			expect(root.UpperTorso:FindFirstChild("Head")).to.be.ok()
			expect(root.UpperTorso.Head.Weight).to.equal(1)
			expect(root.UpperTorso.Head.CFrame).to.equal(CFrame.new(0, 1, 0))
		end)

		it("should set the metadata", function()
			local rig = buildTestRig()
			local keyframeSequence = RigUtils.toRigAnimation(testRigAnimationData, rig)
			expect(keyframeSequence.Loop).to.equal(true)
			expect(keyframeSequence.Priority).to.equal(Enum.AnimationPriority.Idle)
			expect(keyframeSequence.Name).to.equal("Test Rig Animation")
		end)

		it("should add KeyframeMarkers for events", function()
			local rig = buildTestRig()
			local keyframeSequence = RigUtils.toRigAnimation(testRigAnimationData, rig)
			local marker = keyframeSequence.Keyframe:FindFirstChildOfClass("KeyframeMarker")
			expect(marker).to.be.ok()
			expect(marker.Name).to.equal("TestEvent")
			expect(marker.Value).to.equal("TestValue")
		end)

		it("should set keyframe names", function()
			local rig = buildTestRig()
			local testData = deepCopy(testRigAnimationData)
			testData.Events.NamedKeyframes[0] = "TestName"
			local keyframeSequence = RigUtils.toRigAnimation(testData, rig)
			local keyframe = keyframeSequence:FindFirstChild("TestName")
			expect(keyframe).to.be.ok()
		end)

		it("should import keyframe names", function()
			local keyframeSequence = buildTestKeyframeSequence()
			keyframeSequence.Keyframe.Name = "TestName"
			local animationData = RigUtils.fromRigAnimation(keyframeSequence, 30)
			local namedKeyframes = animationData.Events.NamedKeyframes
			expect(namedKeyframes[0]).to.equal("TestName")
		end)

		it("should throw if the expected AnimationData is not correct", function()
			local rig = buildTestRig()
			expect(function()
				RigUtils.toRigAnimation(nil, rig)
			end).to.throw()

			expect(function()
				RigUtils.toRigAnimation("String", rig)
			end).to.throw()
		end)

		it("should throw if no rig was provided", function()
			expect(function()
				RigUtils.toRigAnimation(testRigAnimationData)
			end).to.throw()
		end)
	end)

	describe("getRigInfo", function()
		it("should return a list of parts which are animated", function()
			local testRig = buildTestRig()
			local parts = RigUtils.getRigInfo(testRig)

			expect(parts).to.be.ok()
			expect(#parts).to.equal(3)
			table.sort(parts, function(p1, p2)
				return p1.Name < p2.Name
			end)

			expect(parts[1].Name).to.equal("Head")
			expect(parts[2].Name).to.equal("Jaw")
			expect(parts[3].Name).to.equal("UpperTorso")
		end)

		it("should return a map of part names to Motor6Ds", function()
			local testRig = buildTestRig()
			local _, motors = RigUtils.getRigInfo(testRig)
			expect(motors.UpperTorso).to.be.ok()
			expect(motors.UpperTorso.ClassName).to.equal("Motor6D")
			expect(motors.Head).to.be.ok()
			expect(motors.Head.ClassName).to.equal("Motor6D")
		end)
	end)

	describe("canUseIK", function()
		it("a rig with constraints should be able to use IK", function()
			local testRig = buildTestRig()
			local canUseIK, emptyR15 = RigUtils.canUseIK(testRig)
			expect(canUseIK).to.be.equal(true)
			expect(emptyR15).to.be.equal(false)

		end)
	end)

	describe("getPartByName", function()
		it("should return correct part given its name", function()
			local testRig = buildTestRig()
			local part = RigUtils.getPartByName(testRig, "UpperTorso")
			expect(part).to.be.equal(testRig.UpperTorso)
		end)
	end)

	describe("getBones", function()
		it("first bone of test rig should be the Jaw", function()
			local testRig = buildTestRig()
			local bones = RigUtils.getBones(testRig)
			expect(bones[1]).to.be.equal(testRig.Head.Jaw)
		end)
	end)

	describe("getBoneByName", function()
		it("should return correct bone given its name", function()
			local testRig = buildTestRig()
			local bone = RigUtils.getBoneByName(testRig, "Jaw")
			expect(bone).to.be.equal(testRig.Head.Jaw)
		end)
	end)

	describe("findMatchingAttachments", function()
		it("should return an attachment with a matching name on both parts", function()
			local testRig = buildTestRig()
			local att0, att1 = RigUtils.findMatchingAttachments(testRig.UpperTorso, testRig.Head)
			expect(att0.Name).to.be.equal(att1.Name)
			expect(att0.Parent).to.be.equal(testRig.UpperTorso)
			expect(att1.Parent).to.be.equal(testRig.Head)
		end)
	end)

	describe("findRootPart", function()
		it("should return the root part of the rig", function()
			local testRig = buildTestRig()
			local root = RigUtils.findRootPart(testRig)
			expect(root.Name).to.equal("HumanoidRootPart")
		end)
	end)

	describe("rigHasErrors", function()
		it("should error if there are no motors", function()
			local testRig = buildTestRig()
			testRig.UpperTorso.Motor6D:Destroy()
			testRig.Head.Motor6D:Destroy()
			testRig.Head.Jaw:Destroy()

			local result, errorList = RigUtils.rigHasErrors(testRig)
			expect(result).to.equal(true)
			expect(errorList[1].ID).to.equal(Constants.RIG_ERRORS.NoMotors)
		end)

		it("should error if any part0's are missing", function()
			local testRig = buildTestRig()
			testRig.UpperTorso.Motor6D.Part0 = nil

			local result, errorList = RigUtils.rigHasErrors(testRig)
			expect(result).to.equal(true)
			expect(errorList[1].ID).to.equal(Constants.RIG_ERRORS.MissingPart0_Migrated)
			expect(errorList[1].Data[1]).to.equal(testRig.UpperTorso.Motor6D)
		end)

		it("should error if any part1's are missing", function()
			local testRig = buildTestRig()
			testRig.UpperTorso.Motor6D.Part1 = nil

			local result, errorList = RigUtils.rigHasErrors(testRig)
			expect(result).to.equal(true)
			expect(errorList[1].ID).to.equal(Constants.RIG_ERRORS.MissingPart1_Migrated)
			expect(errorList[1].Data[1]).to.equal(testRig.UpperTorso.Motor6D)
		end)

		it("should error if any parts have multiple parents", function()
			local testRig = buildTestRig()
			testRig.UpperTorso.Motor6D.Part0 = testRig.HumanoidRootPart
			testRig.UpperTorso.Motor6D.Part1 = testRig.Head

			local result, errorList = RigUtils.rigHasErrors(testRig)
			expect(result).to.equal(true)
			expect(errorList[1].ID).to.equal(Constants.RIG_ERRORS.MultipleParents_Migrated)
			expect(errorList[1].Data[1]).to.equal(testRig.Head)
		end)

		it("should error if any parts have a circular relationship", function()
			local testRig = buildTestRig()
			local newMotor = Instance.new("Motor6D", testRig.HumanoidRootPart)
			newMotor.Part0 = testRig.Head
			newMotor.Part1 = testRig.HumanoidRootPart

			local result, errorList = RigUtils.rigHasErrors(testRig)
			expect(result).to.equal(true)
			expect(errorList[1].ID).to.equal(Constants.RIG_ERRORS.CircularRig)
		end)

		it("should error if all parts are anchored", function()
			local testRig = buildTestRig()
			local result, errorList
			testRig.Head.Jaw:Destroy()
			result = RigUtils.rigHasErrors(testRig)
			expect(result).to.equal(false)

			testRig.HumanoidRootPart.Anchored = true
			testRig.Head.Anchored = true
			testRig.UpperTorso.Anchored = true
			result, errorList = RigUtils.rigHasErrors(testRig)
			expect(result).to.equal(true)
			expect(errorList[1].ID).to.equal(Constants.RIG_ERRORS.PartsAnchored)
		end)

		it("should error if multiple animated parts have the same name", function()
			local testRig = buildTestRig()
			testRig.Head.Name = "Part"
			testRig.UpperTorso.Name = "Part"
			local result, errorList = RigUtils.rigHasErrors(testRig)
			expect(result).to.equal(true)
			expect(errorList[1].ID).to.equal(Constants.RIG_ERRORS.NameCollision)
		end)
	end)

	describe("getAnimSavesFolder", function()
		it("should return nil if no AnimSaves folder exists and create is false", function()
			local testRig = buildTestRig()
			local animSaves = RigUtils.getAnimSavesFolder(testRig)
			expect(animSaves).never.to.be.ok()
			expect(testRig:FindFirstChild("AnimSaves")).never.to.be.ok()
		end)

		it("should make a new AnimSaves folder if none exists and Create is true", function()
			local testRig = buildTestRig()
			local animSaves = RigUtils.getAnimSavesFolder(testRig, true)
			expect(animSaves).to.be.ok()
			expect(testRig:FindFirstChild("AnimSaves")).to.be.ok()
		end)

		it("should return the AnimSaves folder if it exists", function()
			local testRig = buildTestRig()
			local animSaves = RigUtils.getAnimSavesFolder(testRig, true)
			local foundFolder = RigUtils.getAnimSavesFolder(testRig)
			expect(foundFolder).to.equal(animSaves)
		end)
	end)

	describe("getAnimSaves", function()
		it("should return an empty table if no AnimSaves folder exists", function()
			local testRig = buildTestRig()
			local animSaves = RigUtils.getAnimSaves(testRig)
			expect(animSaves).to.be.ok()
			expect(#animSaves).to.equal(0)
		end)

		it("should return an empty table if AnimSaves exists but is empty", function()
			local testRig = buildTestRig()
			RigUtils.getAnimSavesFolder(testRig, true)
			local animSaves = RigUtils.getAnimSaves(testRig)
			expect(animSaves).to.be.ok()
			expect(#animSaves).to.equal(0)
		end)

		it("should return a list of KeyframeSequences in AnimSaves", function()
			local testRig = buildTestRig()
			local folder = RigUtils.getAnimSavesFolder(testRig, true)
			Instance.new("KeyframeSequence", folder)
			Instance.new("KeyframeSequence", folder)
			local animSaves = RigUtils.getAnimSaves(testRig)
			expect(animSaves).to.be.ok()
			expect(#animSaves).to.equal(2)
		end)

		it("should only include KeyframeSequences in the list", function()
			local testRig = buildTestRig()
			local folder = RigUtils.getAnimSavesFolder(testRig, true)
			Instance.new("KeyframeSequence", folder)
			Instance.new("Animation", folder)
			local animSaves = RigUtils.getAnimSaves(testRig)
			expect(animSaves).to.be.ok()
			expect(#animSaves).to.equal(1)
		end)
	end)

	describe("calculateFrameRate", function()
		it("should still work if no keyframe at time 0", function()
			local kfs = Instance.new("KeyframeSequence")
			local kf1 = Instance.new("Keyframe", kfs)
			local kf2 = Instance.new("Keyframe", kfs)
			kf1.Time = 0.011111
			kf2.Time = 0.22222
			local fps = RigUtils.calculateFrameRate(kfs)
			expect(fps).to.equal(90)
		end)

		it("should check for 30 fps first", function()
			local kfs = Instance.new("KeyframeSequence")
			local kf1 = Instance.new("Keyframe", kfs)
			local kf2 = Instance.new("Keyframe", kfs)
			local kf3 = Instance.new("Keyframe", kfs)
			kf1.Time = 0
			kf2.Time = 0.5
			kf3.Time = 1
			local fps = RigUtils.calculateFrameRate(kfs)
			expect(fps).to.equal(30)
		end)

		it("should check for 24 fps next", function()
			local kfs = Instance.new("KeyframeSequence")
			local kf1 = Instance.new("Keyframe", kfs)
			local kf2 = Instance.new("Keyframe", kfs)
			local kf3 = Instance.new("Keyframe", kfs)
			kf1.Time = 0
			kf2.Time = 0.125
			kf3.Time = 1
			local fps = RigUtils.calculateFrameRate(kfs)
			expect(fps).to.equal(24)
		end)

		it("should check for 60 fps next", function()
			local kfs = Instance.new("KeyframeSequence")
			local kf1 = Instance.new("Keyframe", kfs)
			local kf2 = Instance.new("Keyframe", kfs)
			local kf3 = Instance.new("Keyframe", kfs)
			kf1.Time = 0
			kf2.Time = 0.05
			kf3.Time = 1
			local fps = RigUtils.calculateFrameRate(kfs)
			expect(fps).to.equal(60)
		end)

		it("should return correct fps", function()
			local kfs = Instance.new("KeyframeSequence")
			local kf1 = Instance.new("Keyframe", kfs)
			local kf2 = Instance.new("Keyframe", kfs)
			local kf3 = Instance.new("Keyframe", kfs)
			kf1.Time = 0
			kf2.Time = 0.01111
			kf3.Time = 1
			local fps = RigUtils.calculateFrameRate(kfs)
			expect(fps).to.equal(90)
		end)

		it("should not exceed 120 fps", function()
			local kfs = Instance.new("KeyframeSequence")
			local kf1 = Instance.new("Keyframe", kfs)
			local kf2 = Instance.new("Keyframe", kfs)
			local kf3 = Instance.new("Keyframe", kfs)
			kf1.Time = 0
			kf2.Time = 0.00001
			kf3.Time = 0.00002
			local fps = RigUtils.calculateFrameRate(kfs)
			expect(fps).to.equal(120)
		end)
	end)
end