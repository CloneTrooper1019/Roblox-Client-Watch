local ContentProvider = game:GetService("ContentProvider")

-- helper functions
local function parseBaseUrlInformation()
	-- get the current base url from the current configuration
	local baseUrl = ContentProvider.BaseUrl
	-- keep a copy of the base url
	-- append a trailing slash if there isn't one
	if baseUrl:sub(#baseUrl) ~= "/" then
		baseUrl = baseUrl .. "/"
	end
	-- parse out scheme (http, https)
	local _, schemeEnd = baseUrl:find("://")
	-- parse out the prefix (www, kyle, ying, etc.)
	local prefixIndex, prefixEnd = baseUrl:find("%.", schemeEnd + 1)
	local basePrefix = baseUrl:sub(schemeEnd + 1, prefixIndex - 1)
	-- parse out the domain
	local baseDomain = baseUrl:sub(prefixEnd + 1)
	return baseUrl, basePrefix, baseDomain
end

-- url construction building blocks
local baseUrl, basePrefix, baseDomain = parseBaseUrlInformation()

local BASE_GAMEASSET_URL = "https://assetgame.%sasset/?id=%d&#assetTypeId=%d&isPackage=%s"
local RBXTHUMB_BASE_URL = "rbxthumb://type=%s&id=%d&w=%d&h=%d"
local ASSET_ID_STRING = "rbxassetid://%d"

local Urls = {}

function Urls.constructAssetThumbnailUrl(assetId, width, height)
    return RBXTHUMB_BASE_URL:format("Asset", tonumber(assetId) or 0, width, height)
end

function Urls.constructAssetIdString(assetId)
	return ASSET_ID_STRING:format(assetId)
end

function Urls.constructAssetGameAssetIdUrl(assetId, assetTypeId, isPackage)
    return BASE_GAMEASSET_URL:format(baseDomain, assetId, assetTypeId, isPackage)
end

return Urls