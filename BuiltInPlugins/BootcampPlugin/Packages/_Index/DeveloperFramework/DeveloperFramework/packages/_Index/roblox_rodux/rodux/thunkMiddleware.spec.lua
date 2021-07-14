return function()
	local Store = require(script.Parent.Store)
	local thunkMiddleware = require(script.Parent.thunkMiddleware)

	it("should dispatch thunks", function()
		local function reducer(state, action)
			return state
		end

		local store = Store.new(reducer, {}, { thunkMiddleware })
		local thunkCount = 0

		local function thunk(store)
			thunkCount = thunkCount + 1
		end

		store:dispatch(thunk)

		expect(thunkCount).to.equal(1)
	end)

	it("should allow normal actions to pass through", function()
		local reducerCount = 0

		local function reducer(state, action)
			reducerCount = reducerCount + 1
			return state
		end

		local store = Store.new(reducer, {}, { thunkMiddleware })

		store:dispatch({
			type = "test",
		})

		-- Reducer will be invoked twice:
		-- Once when creating the store (@@INIT action)
		-- Once when the test action is dispatched
		expect(reducerCount).to.equal(2)
	end)

	it("should return the value from the thunk", function()
		local function reducer(state, action)
			return state
		end

		local store = Store.new(reducer, {}, { thunkMiddleware })
		local thunkValue = "test"

		local function thunk(store)
			return thunkValue
		end

		local result = store:dispatch(thunk)

		expect(result).to.equal(thunkValue)
	end)
end
