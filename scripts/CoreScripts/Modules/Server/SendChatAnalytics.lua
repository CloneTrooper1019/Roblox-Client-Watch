local AnalyticsService = game:GetService("RbxAnalyticsService")

return function(eventName, eventTable)
	if not eventTable then
		eventTable = {}
	end

	eventTable["gameId"] = tostring(game.GameId)
	eventTable["placeId"] = tostring(game.PlaceId)

	AnalyticsService:SendEventDeferred("rcc", "lua_chat_system", eventName, eventTable)
end
