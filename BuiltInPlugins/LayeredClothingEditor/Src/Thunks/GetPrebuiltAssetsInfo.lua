--[[
	do a web request for info about the prebuilt assets were using, then send that info to the rodox store

	Params:
		table robloxApi: the ContextServices.API
		table assetIds: a table of assetIds
]]

local Plugin = script.Parent.Parent.Parent
local SetPrebuiltAssetsInfo = require(Plugin.Src.Actions.SetPrebuiltAssetsInfo)

local isProductionEnvironment = require(Plugin.Src.Util.isProductionEnvironment)

local function convertArrayToIdIndexedTable(table)
	local result = {}
	for _, subTable in pairs(table) do
		result[subTable.id] = subTable
	end
	return result
end

return function(robloxApi, assetIds)
	return function(store)
		if not isProductionEnvironment() then
			return
		end

		local responseFunc = function(response)
			local responseBody = response.responseBody
			local assetsInfo = convertArrayToIdIndexedTable(responseBody.data)
			store:dispatch(SetPrebuiltAssetsInfo(assetsInfo))
		end

		local errFunc = function(err)
			local errorsTable = err and err.responseBody and err.responseBody.errors
			if not errorsTable then
				warn("Could not fetch information for assets")
				return
			end

			for _,errorSubTable in ipairs(errorsTable) do
				warn("Could not fetch information for assets: " .. tostring(errorSubTable.message))
			end
		end

		local fetchPromise = robloxApi.api.Develop.V1.Assets.assets(assetIds):makeRequest()
		fetchPromise:andThen(responseFunc, errFunc)
	end
end