
--[[
	A utility used to assert that two values are equal, recursively. It can accept
	any value, including tables and nil.

	Based on assertDeepEqual from Roact's test utils.
]]
local function deepEqual(a, b)
	if typeof(a) ~= typeof(b) then
		return false
	end

	if typeof(a) == "table" then
		local visitedKeys = {}

		for key, value in pairs(a) do
			visitedKeys[key] = true

			local childEqual = deepEqual(value, b[key])
			if not childEqual then
				return false
			end
		end

		for key, value in pairs(b) do
			if not visitedKeys[key] then
				local childEqual = deepEqual(value, a[key])
				if not childEqual then
					return false
				end
			end
		end

		return true
	end

	if a == b then
		return true
	end

	return false
end

return deepEqual