
--[[
	isProtectedInstance( instance ): Return true for instances which are
	"protected" by Roblox. Accessing any method or property on these instances
	will raise an error.

	Internally use a weak hash map to cache the protection status of the
	instances, as determining the protection status is somewhat expensive.
]]

local WeakIsProtectedCache = setmetatable({}, {__mode = "k"})

local function emptyErrorHandler()
end
local function safetyCheckerFunction(instance)
	return instance.Name
end

local function isProtectedInstance(instance)
	local isProtected = WeakIsProtectedCache[instance]
	if isProtected == nil then
		-- Use xpcall even though we don't need the error handler because
		-- xpcall is much faster than pcall on Roblox.
		isProtected = not xpcall(safetyCheckerFunction, emptyErrorHandler, instance)
		WeakIsProtectedCache[instance] = isProtected
	end
	return isProtected
end

return isProtectedInstance