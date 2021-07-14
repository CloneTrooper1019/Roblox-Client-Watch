return function()
	local Plugin = script.Parent.Parent.Parent

	local SetPointData = require(Plugin.Src.Actions.SetPointData)
	local SetBoundsData = require(Plugin.Src.Actions.SetBoundsData)
	local SetSeamData = require(Plugin.Src.Actions.SetSeamData)
	local SetOriginalPointData = require(Plugin.Src.Actions.SetOriginalPointData)
	local SetPolyData = require(Plugin.Src.Actions.SetPolyData)
	local GetRbfPoints = require(Plugin.Src.Thunks.GetRbfPoints)

	local CageData = require(Plugin.Src.Reducers.CageData)

	local Constants = require(Plugin.Src.Util.Constants)
	local MathUtil = require(Plugin.Src.Util.MathUtil)
	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runTestMinimal = TestRunner.runTestMinimal

	local function createDefaultState()
		return CageData(nil,{})
	end

	local bodyParts = {"LeftHand", "LeftLowerArm", "LeftUpperArm", "RightHand", "RightLowerArm", "RightUpperArm",
						"LeftFoot", "LeftLowerLeg", "LeftLowerArm", "RightFoot", "RightLowerLeg", "RightUpperLeg",
						"UpperTorso", "LowerTorso", "Head"}

	it("should return a table", function()
		local state = createDefaultState()

		expect(type(state)).to.equal("table")
		expect(state.pointData).to.be.a("table")
	end)

	describe("GetRbfPoints", function()
		it("should have bounds for each R15 part for inner/outer cage", function()
			runTestMinimal(function()
				local store = TestHelper.createTestStore()
				local root = TestHelper.createAvatarWithFullCages()

				store:dispatch(GetRbfPoints(root))

				local boundsData = store:getState().cageData.boundsData
				expect(boundsData[Enum.CageType.Outer]).to.be.ok()

				for _, part in ipairs(bodyParts) do
					expect(boundsData[Enum.CageType.Outer][part]).to.be.a("table")
				end
			end)
		end)

		it("should have proper seams between each R15 part", function()
			runTestMinimal(function()
				local store = TestHelper.createTestStore()
				local root = TestHelper.createAvatarWithFullCages()

				store:dispatch(GetRbfPoints(root))

				local pointData = store:getState().cageData.pointData
				local seamData = store:getState().cageData.seamData
				expect(seamData[Enum.CageType.Outer]).to.be.ok()

				for _, part in ipairs(bodyParts) do
					local outerDeformerSeams = seamData[Enum.CageType.Outer][part]
					for pointIndex, linkPoints in pairs(outerDeformerSeams) do
						for _, linkPoint in pairs(linkPoints) do
							local position = pointData[Enum.CageType.Outer][part][pointIndex].Position
							local linkedPosition = pointData[Enum.CageType.Outer][linkPoint.Deformer][linkPoint.Index].Position
							expect(MathUtil:fuzzyEq_Vector3(position, linkedPosition)).to.equal(true)
						end
					end
				end
			end)
		end)

		it("should handle single deformer/part with no seams", function()
			runTestMinimal(function()
				local store = TestHelper.createTestStore()
				local root = TestHelper.createClothesWithFullCages()

				store:dispatch(GetRbfPoints(root))

				local state = store:getState().cageData
				expect(state.pointData).to.be.ok()
				expect(state.boundsData).to.be.ok()
				expect(state.seamData).to.be.ok()
				expect(state.polyData).to.be.ok()
				expect(state.originalPointData).to.be.ok()
			end)
		end)
	end)

	describe("SetPointData action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			local pointData = {
				Inner = {
					Head = {
						Position = Vector3.new(1, 1, 1),
					}
				}
			}
			state = CageData(state, SetPointData(pointData))

			expect(state.pointData).to.be.ok()
			expect(state.pointData.Inner.Head.Position).to.equal(pointData.Inner.Head.Position)
		end)
	end)

	describe("SetBoundsData action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			local boundsData = {
				Inner = {
					Head = {
						Center = Vector3.new(1, 1, 1),
					}
				}
			}
			state = CageData(state, SetBoundsData(boundsData))

			expect(state.boundsData).to.be.ok()
			expect(state.boundsData.Inner.Head.Center).to.equal(boundsData.Inner.Head.Center)
		end)
	end)

	describe("SetSeamData action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			local seamData = {
				Inner = {
					Head = {
						{
							Deformer = "UpperTorso",
							Index = 12,
						},
					},
				}
			}
			state = CageData(state, SetSeamData(seamData))

			expect(state.seamData).to.be.ok()
			expect(state.seamData.Inner.Head[1].Deformer).to.equal("UpperTorso")
			expect(state.seamData.Inner.Head[1].Index).to.equal(12)
		end)
	end)

	describe("SetOriginalPointData action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			local pointData = {
				Inner = {
					Head = {
						Position = Vector3.new(1, 1, 1),
					}
				}
			}
			state = CageData(state, SetOriginalPointData(pointData))

			expect(state.originalPointData).to.be.ok()
			expect(state.originalPointData.Inner.Head.Position).to.equal(pointData.Inner.Head.Position)
		end)
	end)

	describe("SetPolyData action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			local polyData = {
				Inner = {
					Head = {1, 2, 3, 4, 5, 6},
				}
			}
			state = CageData(state, SetPolyData(polyData))

			expect(state.polyData).to.be.ok()
			expect(#state.polyData.Inner.Head).to.equal(6)
		end)
	end)
end