-- Compare a packed table with a packed table of predicates.
local fmtArgs = require(script.Parent.fmtArgs)

return function(p, x)
	if p.n ~= x.n then
		local msg = "number of args in " .. fmtArgs(x) .. " does not match number of predicates"
		return false, msg
	end

	for i = 1, x.n do
		if not p[i](x[i]) then
			local msg = fmtArgs(x) .. " does not match predicates at position " .. i
			return false, msg
		end
	end
	return true
end
