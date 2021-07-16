--[[
	An initial stub for the withContext implementation, which currently just provides a chainable
	alternative that can be made immutable in the future.
	See https://jira.rbx.com/browse/RIDE-4509
]]

local Framework = script.Parent.Parent
local mapToProps = require(Framework.ContextServices.mapToProps)

local function withContext(contextItems)
	return function(component)
		mapToProps(component, contextItems, true)
		return component
	end
	
end

return withContext
