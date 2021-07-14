--[[
	Calls a function and throws an error if it attempts to yield.

	Pass any number of arguments to the function after the callback.

	This function supports multiple return; all results returned from the
	given function will be returned.
]]

local function resultHandler(co, ok, ...)
	if not ok then
		local message = (...)
		error(debug.traceback(co, message), 2)
	end

	if coroutine.status(co) ~= "dead" then
		error(debug.traceback(co, "Attempted to yield inside changed event!"), 2)
	end

	return ...
end

local function NoYield(callback, ...)
	local co = coroutine.create(callback)

	return resultHandler(co, coroutine.resume(co, ...))
end

return NoYield