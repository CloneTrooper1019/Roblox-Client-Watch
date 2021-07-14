-- Compare two packed tables for shallow equality.
local fmtArgs = require(script.Parent.fmtArgs)

return function(e, a)
	if e.n ~= a.n then
		local msg = "number of literals in " .. fmtArgs(e) .. " does not match number of args in " .. fmtArgs(a)
		return false, msg
	end

	for i = 1, e.n do
		if e[i] ~= a[i] then
			local msg = "expected " .. fmtArgs(e) .. ", got " .. fmtArgs(a)
			return false, msg
		end
	end
	return true
end
