local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)

local middlewares = {
	Rodux.thunkMiddleware,
}

return middlewares