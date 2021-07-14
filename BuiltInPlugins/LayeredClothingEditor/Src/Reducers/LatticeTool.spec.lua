return function()
	local Plugin = script.Parent.Parent.Parent

	local SetLatticeData = require(Plugin.Src.Actions.SetLatticeData)
	local SetSubdivisions = require(Plugin.Src.Actions.SetSubdivisions)
	local SetLatticeBoundsData = require(Plugin.Src.Actions.SetLatticeBoundsData)
	local SetSelectedLattice = require(Plugin.Src.Actions.SetSelectedLattice)
	local GetRbfPoints = require(Plugin.Src.Thunks.GetRbfPoints)
	local MakeLattices = require(Plugin.Src.Thunks.MakeLattices)

	local LatticeTool = require(Plugin.Src.Reducers.LatticeTool)

	local Constants = require(Plugin.Src.Util.Constants)
	local TestHelper = require(Plugin.Src.Util.TestHelper)
	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runTestMinimal = TestRunner.runTestMinimal

	local function createDefaultState()
		return LatticeTool(nil, {})
	end

	local bodyParts = {"LeftHand", "LeftLowerArm", "LeftUpperArm", "RightHand", "RightLowerArm", "RightUpperArm",
						"LeftFoot", "LeftLowerLeg", "LeftLowerArm", "RightFoot", "RightLowerLeg", "RightUpperLeg",
						"UpperTorso", "LowerTorso", "Head"}

	it("should return a table", function()
		local state = createDefaultState()

		expect(type(state)).to.equal("table")
		expect(state.latticeData).to.be.a("table")
		expect(state.subdivisions).to.be.a("table")
		expect(state.latticeBoundsData).to.be.a("table")
	end)

	describe("MakeLattices", function()
		it("should make lattice for each R15 part for both inner and outer cage", function()
			runTestMinimal(function()
				local store = TestHelper.createTestStore()
				local root = TestHelper.createClothesWithFullCages()

				store:dispatch(GetRbfPoints(root))
				store:dispatch(MakeLattices())

				local state = store:getState()
				local latticeData = state.latticeTool.latticeData
				expect(latticeData[Enum.CageType.Inner]).to.be.ok()
				expect(latticeData[Enum.CageType.Outer]).to.be.ok()

				expect(latticeData[Enum.CageType.Inner][TestHelper.DefaultClothesName]).to.be.a("table")
				expect(latticeData[Enum.CageType.Outer][TestHelper.DefaultClothesName]).to.be.a("table")
			end)
		end)

		it("should subdivide properly", function()
			runTestMinimal(function()
				local store = TestHelper.createTestStore()
				local root = TestHelper.createClothesWithFullCages()

				store:dispatch(GetRbfPoints(root))
				store:dispatch(MakeLattices())

				local state = store:getState()
				local latticeData = state.latticeTool.latticeData
				local defaultSubdivisions = Constants.DEFAULT_LATTICE_SUBDIVISIONS

				expect(latticeData[Enum.CageType.Inner][TestHelper.DefaultClothesName]).to.be.ok()
				local lattice = latticeData[Enum.CageType.Inner][TestHelper.DefaultClothesName].lattice
				expect(lattice).to.be.ok()

				local height = #lattice
				local depth = #lattice[1]
				local width = #lattice[1][1]

				expect(width).to.be.equal(defaultSubdivisions.X + 1)
				expect(height).to.be.equal(defaultSubdivisions.Y + 1)
				expect(depth).to.be.equal(defaultSubdivisions.Z + 1)
			end)
		end)
	end)

	describe("SetLatticeData action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = LatticeTool(state, SetLatticeData({
				rbfPointsInCell = {},
				controlPointToCellMap = {},
				lattice = {},
			}))

			expect(state.latticeData).to.be.ok()
			expect(state.latticeData.rbfPointsInCell).to.be.ok()
			expect(state.latticeData.controlPointToCellMap).to.be.ok()
			expect(state.latticeData.lattice).to.be.ok()
		end)
	end)

	describe("SetSubdivisions action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = LatticeTool(state, SetSubdivisions({
				Inner = {
					Head = Vector3.new(1, 5, 1),
				},
			}))

			expect(state.subdivisions).to.be.ok()
			expect(state.subdivisions.Inner.Head.X).to.equal(1)
			expect(state.subdivisions.Inner.Head.Y).to.equal(5)
			expect(state.subdivisions.Inner.Head.Z).to.equal(1)
		end)
	end)

	describe("SetLatticeBoundsData action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = LatticeTool(state, SetLatticeBoundsData({
				Inner = {
					Head = {
						Center = Vector3.new(),
					}
				},
			}))

			expect(state.latticeBoundsData).to.be.ok()
			expect(state.latticeBoundsData.Inner.Head.Center).to.be.ok()
		end)
	end)

	describe("SetSelectedLattice action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = LatticeTool(state, SetSelectedLattice("Head"))

			expect(state.selectedLattice).to.be.ok()
			expect(state.selectedLattice).to.equal("Head")
		end)
	end)
end