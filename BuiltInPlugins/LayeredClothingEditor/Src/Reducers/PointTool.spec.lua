return function()
	local Plugin = script.Parent.Parent.Parent

	local SetSelectedPoints = require(Plugin.Src.Actions.SetSelectedPoints)
	local SetClickedPoints = require(Plugin.Src.Actions.SetClickedPoints)
	local SetFalloff = require(Plugin.Src.Actions.SetFalloff)
	local SelectRbfPoint = require(Plugin.Src.Thunks.SelectRbfPoint)
	local SetEditingCage = require(Plugin.Src.Actions.SetEditingCage)
	local GetRbfPoints = require(Plugin.Src.Thunks.GetRbfPoints)

	local PointTool = require(Plugin.Src.Reducers.PointTool)

	local Constants = require(Plugin.Src.Util.Constants)
	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runTestMinimal = TestRunner.runTestMinimal

	local function createDefaultState()
		return PointTool(nil, {})
	end

	it("should return a table", function()
		local state = createDefaultState()

		expect(type(state)).to.equal("table")
		expect(state.selectedPoints).to.be.a("table")
		expect(state.clickedPoints).to.be.a("table")
	end)

	describe("SelectRbfPoint", function()
		it("clickedPoints should transfer to selectedPoints", function()
			runTestMinimal(function()
				local store = TestHelper.createTestStore()
				local root = TestHelper.createClothesWithFullCages()

				store:dispatch(SetFalloff(0))
				store:dispatch(SetEditingCage(Enum.CageType.Outer))
				store:dispatch(GetRbfPoints())

				store:dispatch(SelectRbfPoint({
					{
						Deformer = TestHelper.DefaultClothesName,
						Index = 2,
					},
					{
						Deformer = TestHelper.DefaultClothesName,
						Index = 4,
					},
					{
						Deformer = TestHelper.DefaultClothesName,
						Index = 6,
					},
				}))

				local state = store:getState().pointTool
				expect(state.clickedPoints[1].Deformer).to.equal(TestHelper.DefaultClothesName)
				expect(state.clickedPoints[1].Index).to.equal(2)
				expect(state.clickedPoints[2].Deformer).to.equal(TestHelper.DefaultClothesName)
				expect(state.clickedPoints[2].Index).to.equal(4)
				expect(state.clickedPoints[3].Deformer).to.equal(TestHelper.DefaultClothesName)
				expect(state.clickedPoints[3].Index).to.equal(6)

				expect(state.selectedPoints[TestHelper.DefaultClothesName][2]).to.equal(1)
				expect(state.selectedPoints[TestHelper.DefaultClothesName][4]).to.equal(1)
				expect(state.selectedPoints[TestHelper.DefaultClothesName][6]).to.equal(1)
			end)
		end)
	end)

	describe("SetSelectedPoints action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = PointTool(state, SetSelectedPoints({
				Inner = {
					Head = {
						[1] = 0,
					},
				},
			}))

			expect(state.selectedPoints).to.be.ok()
			expect(state.selectedPoints["Inner"]["Head"][1]).to.equal(0)
		end)
	end)

	describe("SetClickedPoints action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = PointTool(state, SetClickedPoints({
				{
					ID = 1,
				}
			}))

			expect(state.clickedPoints).to.be.ok()
			expect(state.clickedPoints).to.be.a("table")
			expect(state.clickedPoints[1].ID).to.equal(1)
		end)
	end)

	describe("SetFalloff action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = PointTool(state, SetFalloff(1))

			expect(state.falloff).to.be.ok()
			expect(state.falloff).to.equal(1)
		end)
	end)
end