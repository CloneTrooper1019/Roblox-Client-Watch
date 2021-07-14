--[[
	Returns HTML, use this function to open an external browser.

	Example :
	https://www.roblox.com/develop/library?CatalogContext=2&SortType=0&SortAggregation=3&SortCurrency=0&Category=7
]]

local CATALOG_CONTEXT = {
	[0] = "FullCatalog",
	[1] = "AvatarOnly",
	[2] = "DevelopOnly",
}

local SORT_TYPE = {
	[0] = "Relevance",
	[1] = "Favorited",
	[2] = "Sales",
	[3] = "Updated",
	[4] = "PriceAsc",
	[5] = "PriceDesc",
}

local SORT_AGGREGATION = {
	[0] = "Past12Hours",
	[1] = "PastDay",
	[2] = "Past3Days",
	[3] = "PastWeek",
	[4] = "PastMonth",
	[5] = "AllTime",
}

local SORT_CURRENCY = {
	[0] = "Robux"
}

local CATEGORY = {
	[0] = "Featured",
	[1] = "All",
	[2] = "Collectibles",
	[3] = "Clothing",
	[4] = "BodyParts",
	[5] = "Gear",
	[6] = "Models",
	[7] = "Plugins",
	[8] = "Decals",
	[9] = "Audio",
	[10]= "Meshes",
	[11]= "Accessories",
	[12]= "AvatarAnimations",
}

local function assertInEnum(valueName, value, enum)
	if type(value) ~= "number" then
		error(string.format("Expected %s to be a number", valueName), 1)
	end

	if enum[value] ~= nil then
		error(string.format("Expected %s to be a valid enum value.", valueName), 1)
	end
end

-- _ : (Http.Networking) supplied by RobloxAPI.init.lua, a Networking object that makes the network requests
-- baseUrl : (RobloxAPI.Url) supplied by RobloxAPI.init.lua, an object for constructing urls
return function(_, baseUrl)
	-- catalogContext : (number) which subset of the catalog you are searching in
	-- sortType : (number) how results are ordered
	-- sortAggregation : (number) the timeframe of the results to show
	-- sortCurrency : (number) Robux or some other currency
	-- category : (number) which type of item you are searching for
	return function(catalogContext, sortType, sortAggregation, sortCurrency, category)
		assertInEnum("catalogContext", catalogContext, CATALOG_CONTEXT)
		assertInEnum("sortType", sortType, SORT_TYPE)
		assertInEnum("sortAggregation", sortAggregation, SORT_AGGREGATION)
		assertInEnum("sortCurrency", sortCurrency, SORT_CURRENCY)
		assertInEnum("category", category, CATEGORY)

		local url = baseUrl.composeUrl(baseUrl.BASE_URL, "develop/library", {
			CatalogContext = catalogContext,
			SortType = sortType,
			SortAggregation = sortAggregation,
			SortCurrency = sortCurrency,
			Category = category,
		})

		return {
			getUrl = function()
				return url
			end,
		}
	end
end
