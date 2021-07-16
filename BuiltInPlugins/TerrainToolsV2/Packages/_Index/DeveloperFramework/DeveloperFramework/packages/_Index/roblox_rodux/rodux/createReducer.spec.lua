return function()
	local createReducer = require(script.Parent.createReducer)

	it("should handle actions", function()
		local reducer = createReducer({
			a = 0,
			b = 0,
		}, {
			a = function(state, action)
				return {
					a = state.a + 1,
					b = state.b,
				}
			end,
			b = function(state, action)
				return {
					a = state.a,
					b = state.b + 2,
				}
			end,
		})

		local newState = reducer({
			a = 0,
			b = 0,
		}, {
			type = "a",
		})

		expect(newState.a).to.equal(1)

		newState = reducer(newState, {
			type = "b",
		})

		expect(newState.b).to.equal(2)
	end)

	it("should return the initial state if the state is nil", function()
		local reducer = createReducer({
			a = 0,
			b = 0,
		-- We don't care about the actions here
		}, {})

		local newState = reducer(nil, {})
		expect(newState).to.be.ok()
		expect(newState.a).to.equal(0)
		expect(newState.b).to.equal(0)
	end)

	it("should still run action handlers if the state is nil", function()
		local callCount = 0

		local reducer = createReducer(0, {
			foo = function(state, action)
				callCount = callCount + 1
				return nil
			end
		})

		expect(callCount).to.equal(0)

		local newState = reducer(nil, {
			type = "foo",
		})

		expect(callCount).to.equal(1)
		expect(newState).to.equal(nil)

		newState = reducer(newState, {
			type = "foo",
		})

		expect(callCount).to.equal(2)
		expect(newState).to.equal(nil)
	end)

	it("should return the same state if the action is not handled", function()
		local initialState = {
			a = 0,
			b = 0,
		}

		local reducer = createReducer(initialState, {
			a = function(state, action)
				return {
					a = state.a + 1,
					b = state.b,
				}
			end,
			b = function(state, action)
				return {
					a = state.a,
					b = state.b + 2,
				}
			end,
		})

		local newState = reducer(initialState, {
			type = "c",
		})

		expect(newState).to.equal(initialState)
	end)
end
