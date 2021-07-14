-- given a string from an error stack, returns the name of the file from that line
local function findFileNameFromPath(pathStr)
	assert(type(pathStr) == "string", "pathStr must be a string")

	return string.match(pathStr, "([^.]*)$")
end

return findFileNameFromPath