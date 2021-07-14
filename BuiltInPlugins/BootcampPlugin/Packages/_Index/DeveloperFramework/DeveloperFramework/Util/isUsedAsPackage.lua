--[[
	This is a wrapper to either load a package from the Framework Parent, or from DeveloperFramework's
	own packages directory. Once all plugins have been migrated to use DeveloperFramework as a package,
	this can be deleted and Framework.Parent always used within DeveloperFramework.

	This lets us achieve a flag-style change for DeveloperFramework while using finer-grained flags
	for each consumer of DeveloperFramework.

	TODO DEVTOOLS-4443
]]

local Framework = script.Parent.Parent

return function()
	local ok, result = pcall(function()
		return Framework.Parent.Parent.Name == "_Index"
	end)

	if not ok then
		return false
	end

	return result
end