local HttpService = game:GetService("HttpService")

local Plugin = script.Parent.Parent.Parent

local SetUserAddedAssets = require(Plugin.Src.Actions.SetUserAddedAssets)

local Framework = require(Plugin.Packages.Framework)
local deepJoin = Framework.Util.deepJoin

return function(tab, asset)
	return function(store)
		local state = store:getState()

		local userAddedAssets = state.previewStatus.userAddedAssets
		local index = 1
		if userAddedAssets[tab] then
			index = #userAddedAssets[tab] + 1
		end
		local newAssets = deepJoin(userAddedAssets, {
			[tab] = {
				[index] = {
					instance = asset,
					uniqueId = HttpService:GenerateGUID()
				}
			}
		})

		store:dispatch(SetUserAddedAssets(newAssets))
	end
end