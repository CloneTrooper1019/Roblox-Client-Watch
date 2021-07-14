local symbols = require(script.Parent.symbols)
local Spy = require(script.Parent.Spy)

return function(mock)
	-- To support the usecase of invoking getCalls on a function
	-- wrapped with a spy
	if type(mock) == "function" then
		local spy = Spy.lookup(mock)
		if spy then
			return spy[symbols.Calls]
		end
		error("Calling getCalls on a non-spy function")
	end

	-- To support the usecase of invoking getCalls on spy itself
	local argsList = rawget(mock, symbols.Calls)

	-- To support the usecase of invoking getCalls on MagicMock
	if argsList == nil then
		local meta = getmetatable(mock)
		argsList = meta[symbols.Calls]
	end

	if argsList == nil then
		error("Calling getCalls on a non-mock")
	end

	return argsList
end
