--[[
	A helper function to define a Rodux action creator with an associated name.

	Normally when creating a Rodux action, you can just create a function:

		return function(value)
			return {
				type = "MyAction",
				value = value,
			}
		end

	And then when you check for it in your reducer, you either use a constant,
	or type out the string name:

		if action.type == "MyAction" then
			-- change some state
		end

	Typos here are a remarkably common bug. We also have the issue that there's
	no link between reducers and the actions that they respond to!

	`Action` (this helper) provides a utility that makes this a bit cleaner.

	Instead, define your Rodux action like this:

		return Action("MyAction", function(value)
			return {
				value = value,
			}
		end)

	We no longer need to add the `type` field manually.

	Additionally, the returned action creator now has a 'name' property that can
	be checked by your reducer:

		local MyAction = require(Reducers.MyAction)

		...

		if action.type == MyAction.name then
			-- change some state!
		end

	Now we have a clear link between our reducers and the actions they use, and
	if we ever typo a name, we'll get a warning in LuaCheck as well as an error
	at runtime!
]]

return function(name, fn)
	assert(type(name) == "string", "A name must be provided to create an Action")
	assert(type(fn) == "function", "A function must be provided to create an Action")

	return setmetatable({
		name = name,
	}, {
		__call = function(self, ...)
			local result = fn(...)

			assert(type(result) == "table", "An action must return a table")

			result.type = name

			return result
		end
	})
end
