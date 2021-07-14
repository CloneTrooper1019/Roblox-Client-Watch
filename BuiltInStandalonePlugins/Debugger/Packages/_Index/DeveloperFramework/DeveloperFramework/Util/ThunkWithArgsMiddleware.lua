--[[
	This is a slightly modified version of Rodux.thunkMiddleware that allows you
	to pass args other than the store to thunks.

	Using the default Rodux.thunkMiddleware, the only way to get context items
	like Networking into thunks is to provide it to the Roact element and then pass
	it through muliple layers of the Roact tree / Rodux mapping	that don't even use
	them until you finally invoke the thunk. This has to be done for every thunk,
	that uses a context item like Networking, and all of the Roact components / Rodux mappings
	that invoke the thunk.

	Using ThunkWithArgsMiddleware, you can generate a middleware that provides additional args
	to thunks (more than likely, context items) without routing them through the Roact tree
	and its Rodux mappings. And since this middleware lives in the store, it can be properly
	mocked in tests and is not affected by some global state in the plugin

	----------------------------------------------------
	-- Example Usage:								  --
	----------------------------------------------------
	local contextServices = {
		networking = ...,
		...
	}
	local thunkWithArgsMiddleware = ThunkWithArgsMiddleware(contextServices, randomThing, ...)
	local settingsStore = Rodux.Store.new(..., ..., { thunkWithArgsMiddleware })

	-- in thunk
	return function(thunkInvokeArg1, thunkInvokeArg2, ...)
		return function(store, contextServices, randomThing, ...)
            contextServices.networking:get(...)
		end
	end
--]]

return function(...)
	local args = {...}

	return function(nextDispatch, store)
		return function(action)
			if typeof(action) == "function" then
				return action(store, unpack(args))
			else
				return nextDispatch(action)
			end
		end
	end
end