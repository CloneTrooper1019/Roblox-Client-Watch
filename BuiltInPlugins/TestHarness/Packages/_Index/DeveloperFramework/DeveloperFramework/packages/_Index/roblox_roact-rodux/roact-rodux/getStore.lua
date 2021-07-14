local storeKey = require(script.Parent.storeKey)

local function getStore(componentInstance)
	return componentInstance._context[storeKey]
end

return getStore