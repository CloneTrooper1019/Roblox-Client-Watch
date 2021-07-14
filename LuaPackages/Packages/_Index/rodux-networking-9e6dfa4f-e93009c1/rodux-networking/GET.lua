local root = script.Parent
local makeRequestApi = require(root.makeRequestApi)

return function(options)
	return makeRequestApi(options, "GET")
end
