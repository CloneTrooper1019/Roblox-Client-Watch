--[[
	This function constructs an asset url that you can supply to a ImageLabel.Image

	Example:
	https://assetgame.roblox.com/asset-thumbnail/image?assetId=373389090&width=100&height=100
]]
local DEFAULT_ASSET_SIZE = 100
local ASSET_SIZE = {
	[50] = "50",
	[75] = "75",
	[100]= "100",
	[150]= "150",
	[250]= "250",
	[420]= "420",
}

local function assertIsValidSize(argName, value)
	if type(value) ~= "number" then
		error(string.format("Expected %s to be a number.", argName), 1)
	end

	if ASSET_SIZE[argName] ~= nil then
		error(string.format("Expected %s to be a valid ASSET_SIZE enum value.", argName), 1)
	end
end

-- _ : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(_, baseUrl)
	-- assetId : (number/string)
	-- height : (number, optional) the desired height of the image
	-- width : (number, optional) the desired width of the image
	return function(assetId, height, width)
		-- The URL only accepts certain sizes for thumbnails. This includes 50, 75, 100, 150, 250, 420 etc.
		width = width or DEFAULT_ASSET_SIZE
		height = height or DEFAULT_ASSET_SIZE

		assert(tonumber(assetId) > 0, "Expected assetId to be a valid number")
		assertIsValidSize("width", width)
		assertIsValidSize("height", height)

		local url = baseUrl.composeUrl(baseUrl.ASSET_GAME_URL, "asset-thumbnail/image", {
			assetId = assetId,
			width = width,
			height = height,
		})

		return {
			getUrl = function()
				return url
			end,
		}
	end
end