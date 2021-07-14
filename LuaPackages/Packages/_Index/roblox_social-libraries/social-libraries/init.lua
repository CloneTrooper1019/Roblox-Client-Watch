local Packages = script.Parent
local UIBlox = require(Packages.UIBlox)

return {
	config = function(config)
		if config.UIBloxConfig then
			UIBlox.init(config.UIBloxConfig)
		end

		return {
			Analytics = require(script.Analytics),
			Components = require(script.Components),
			-- ** In the future, Conversation should become its own package.
			Conversation = require(script.Conversation),
			-- ** In the future, User should become its own package.
			User = require(script.User),
			Utils = require(script.Utils),
			RoactLayout = require(script.RoactLayout),
			RoactPaginator = require(script.RoactPaginator),
			RoduxTools = require(script.RoduxTools),
			populate = require(script.populate),

			StoryMiddleware = require(script.StoryMiddleware)
		}
	end,
}
