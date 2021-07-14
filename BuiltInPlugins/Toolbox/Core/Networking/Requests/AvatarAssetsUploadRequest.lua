local HttpService = game:GetService("HttpService")

local Plugin = script.Parent.Parent.Parent.Parent

local FFlagCMSUploadAccessoryMeshPartFormat2 = game:GetFastFlag("CMSUploadAccessoryMeshPartFormat2")
local FFlagUGCGroupUploads = game:GetFastFlag("UGCGroupUploads")

local SetAssetId = require(Plugin.Core.Actions.SetAssetId)
local NetworkError = require(Plugin.Core.Actions.NetworkError)
local SetCurrentScreen = require(Plugin.Core.Actions.SetCurrentScreen)
local UploadResult = require(Plugin.Core.Actions.UploadResult)

local Util = Plugin.Core.Util
local DebugFlags = require(Util.DebugFlags)
local getUserId = require(Util.getUserId)
local AssetConfigConstants = require(Util.AssetConfigConstants)
local SerializeInstances = require(Util.SerializeInstances)
local Analytics = require(Util.Analytics.Analytics)

local createMultipartFormDataBody = require(Util.createMultipartFormDataBody)

local ConfigureItemTagsRequest = require(Plugin.Core.Networking.Requests.ConfigureItemTagsRequest)
local UploadCatalogItemMeshPartFormatRequest = require(Plugin.Core.Networking.Requests.UploadCatalogItemMeshPartFormatRequest)

local function createConfigDataTable(nameWithoutExtension, assetTypeId, description, groupId)
	if FFlagUGCGroupUploads then
		return {
			name = nameWithoutExtension,
			description = description,
			creatorType = groupId ~= nil and "Group" or "User",
			creatorTargetId = groupId ~= nil and groupId or getUserId(),
		}
	else
		return {
			name = nameWithoutExtension,
			description = description,
		}
	end
end

return function(networkInterface, nameWithoutExtension, extension, description, assetTypeId, instances, tags, groupId)
	return function(store)
		nameWithoutExtension = string.sub(nameWithoutExtension or "", 1, AssetConfigConstants.NAME_CHARACTER_LIMIT)
		description = string.sub(description or "", 1, AssetConfigConstants.DESCRIPTION_CHARACTER_LIMIT)

		store:dispatch(SetCurrentScreen(AssetConfigConstants.SCREENS.UPLOADING_ASSET))

		local handlerFunc = function(response)
			local success, body = pcall(function()
				return HttpService:JSONDecode(response.Body)
			end)

			if success and body.assetId then
				store:dispatch(SetAssetId(body.assetId))
				if FFlagCMSUploadAccessoryMeshPartFormat2 then
					store:dispatch(
						UploadCatalogItemMeshPartFormatRequest(
							networkInterface,
							body.assetId,
							assetTypeId,
							nameWithoutExtension,
							description,
							instances,
							tags
						)
					)
				else
					store:dispatch(ConfigureItemTagsRequest(networkInterface, body.assetId, {}, tags))
				end

				Analytics.incrementUploadAssetSuccess(assetTypeId)
				return
			end

			warn("Unexpected AvatarAssetsUploadRequest response body:", response.Body)
			store:dispatch(NetworkError("Unknown Error"))
			store:dispatch(UploadResult(false))
		end

		local errorFunc = function(response)
			if DebugFlags.shouldDebugWarnings() then
				warn(("Lua toolbox: Could not upload catalog item"))
			end
			store:dispatch(NetworkError(response.Body))
			store:dispatch(UploadResult(false))

			Analytics.incrementUploadeAssetFailure(assetTypeId)
		end

		local fileDataString = SerializeInstances(instances)
		local configDataTable = createConfigDataTable(nameWithoutExtension, assetTypeId, description, groupId)
		local configDataBlob = networkInterface:jsonEncode(configDataTable)

		local formBodyData = createMultipartFormDataBody({
			{
				type = "application/json",
				disposition = {
					name = "config",
					filename = "config.json",
				},
				value = configDataBlob,
			},
			{
				type = "application/octet-stream",
				disposition = {
					name = nameWithoutExtension,
					filename = nameWithoutExtension .. "." .. extension,
				},
				value = fileDataString,
			}
		})

		networkInterface
			:avatarAssetsUpload(assetTypeId, formBodyData, AssetConfigConstants.MULTIPART_FORM_BOUNDARY)
			:andThen(handlerFunc, errorFunc)
	end
end
