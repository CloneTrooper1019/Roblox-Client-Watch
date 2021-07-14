-- given a string, splits a string in half and excludes the matched pattern
local function splitStringWithMarks(str, matches)
	assert(type(str) == "string", "Expected the string to split to be a string")
	assert(type(matches) == "table" and #matches > 0, "Expected matches to be an array")

	for _, match in ipairs(matches) do
		local start, stop = string.find(str, match, nil, true)

		if start ~= nil then
			local first = string.sub(str, 1, start - 1)
			local rest = string.sub(str, stop + 1)
			return first, rest
		end
	end

	return str, ""
end

return splitStringWithMarks