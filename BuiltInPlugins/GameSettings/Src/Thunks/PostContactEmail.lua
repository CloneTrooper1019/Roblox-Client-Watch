--[[
	Submit a contact email for Luobu moderators to send the developer remediation
]]
return function(contactEmail)
	return function(store, contextItems)
        local policyInfoController = contextItems.policyInfoController

        local universeId = game.GameId

        return policyInfoController:postContactEmail(universeId, contactEmail)
	end
end
