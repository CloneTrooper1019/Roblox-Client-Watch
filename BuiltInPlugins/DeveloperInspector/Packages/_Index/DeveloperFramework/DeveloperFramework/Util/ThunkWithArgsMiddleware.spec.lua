return function()
	local ThunkWithArgsMiddleware = require(script.Parent.ThunkWithArgsMiddleware)

	it("should pass args for thunk", function()
		local arg1 = "foo"
		local arg2 = "bar"
		local thunkWithArgsMiddleware = ThunkWithArgsMiddleware(arg1, arg2)

		local passedArgs = thunkWithArgsMiddleware(nil, nil)(function(_, ...)
			return {...}
		end)

		expect(#passedArgs).to.equal(2)
		expect(passedArgs[1]).to.equal(arg1)
		expect(passedArgs[2]).to.equal(arg2)
	end)

	it("should only pass args to thunks", function()
		local arg1 = "foo"
		local arg2 = "bar"
		local thunkWithArgsMiddleware = ThunkWithArgsMiddleware(arg1, arg2)

		local action = {}
		local function nextDispatch(action, ...)
			return action,{...}
		end

		local passedAction,passedArgs = thunkWithArgsMiddleware(nextDispatch, nil)(action)

		expect(passedAction).to.equal(action)
		expect(#passedArgs).to.equal(0)
	end)
end
