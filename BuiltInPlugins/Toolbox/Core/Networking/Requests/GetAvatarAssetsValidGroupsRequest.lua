local Plugin = script.Parent.Parent.Parent.Parent

local SetAssetConfigAvatarAssetsValidGroups = require(Plugin.Core.Actions.SetAssetConfigAvatarAssetsValidGroups)
local NetworkError = require(Plugin.Core.Actions.NetworkError)

return function(networkInterface, assetType)
	return function(store)
		return networkInterface:getAvatarAssetsValidGroups(assetType):andThen(function(result)
			local groups = result.responseBody.groups

			-- convert to be compatible with AssetConfigUtil.getOwnerDropDownContent()
			for key, value in ipairs(groups) do
				groups[key] = {
					id = value.groupId,
					name = value.groupName,
				}
			end

			store:dispatch(SetAssetConfigAvatarAssetsValidGroups(groups))
		end, function(result)
			store:dispatch(NetworkError(result))
		end)
	end
end
