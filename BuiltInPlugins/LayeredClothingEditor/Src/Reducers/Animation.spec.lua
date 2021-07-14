return function()
	local Plugin = script.Parent.Parent.Parent

	local SetPlayhead = require(Plugin.Src.Actions.SetPlayhead)
	local SetIsPlaying = require(Plugin.Src.Actions.SetIsPlaying)
	local SetTrackLength = require(Plugin.Src.Actions.SetTrackLength)
	local Animation = require(Plugin.Src.Reducers.Animation)

	local function createDefaultState()
		return Animation(nil,{})
	end

	it("should return a table", function()
		local state = createDefaultState()

		expect(type(state)).to.equal("table")
		expect(state.Playhead).to.equal(0)
		expect(state.IsPlaying).to.equal(false)
		expect(state.TrackLengh).to.equal(0)
	end)

	describe("SetPlayhead action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = Animation(state, SetPlayhead(1))

			expect(state.Playhead).to.equal(1)
		end)
	end)

	describe("SetIsPlaying action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = Animation(state, SetIsPlaying(true))

			expect(state.IsPlaying).to.equal(true)
		end)
	end)

	describe("SetTrackLength action", function()
		it("should get copied to state correctly", function()
			local state = createDefaultState()
			state = Animation(state, SetTrackLength(1))

			expect(state.TrackLength).to.equal(1)
		end)
	end)
end