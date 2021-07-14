return function()
	local combineReducers = require(script.Parent.combineReducers)

	it("should invoke each sub-reducer for every action", function()
		local aCount = 0
		local bCount = 0

		local reducer = combineReducers({
			a = function(state, action)
				aCount = aCount + 1
			end,
			b = function(state, action)
				bCount = bCount + 1
			end,
		})

		-- Mock reducer invocation
		reducer({}, {})
		expect(aCount).to.equal(1)
		expect(bCount).to.equal(1)
	end)

	it("should assign each sub-reducer's value to the new state", function()
		local reducer = combineReducers({
			a = function(state, action)
				return (state or 0) + 1
			end,
			b = function(state, action)
				return (state or 0) + 3
			end,
		})

		local newState = reducer({}, {})
		expect(newState.a).to.equal(1)
		expect(newState.b).to.equal(3)
	end)

	it("should not throw when state is nil", function()
		local reducer = combineReducers({
			a = function(state, action)
				return (state or 0) + 1
			end,
			b = function(state, action)
				return (state or 0) + 3
			end,
		})

		expect(function()
			reducer(nil, {})
		end).to.never.throw()
	end)
end
