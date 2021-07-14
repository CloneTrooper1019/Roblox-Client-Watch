return {
	config = function(options)
		options = options or {}

		local state = options.state or {}
		return {
			dispatch = options.dispatch or function(self, thunk)
				if type(thunk) == "function" then
					thunk(self)
				end
			end,

			getState = function()
				return state
			end,

			setState = function(_, newState)
				state = newState
			end,
		}

	end,
}
