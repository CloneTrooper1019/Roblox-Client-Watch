local MonetizationController = {}

local Plugin = script.Parent.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)

MonetizationController.__index = MonetizationController

function MonetizationController.new(networking)
    local self = {}

    self.__networking = networking

    return setmetatable(self, MonetizationController)
end

function MonetizationController:economyV1GET()
    local networking = self.__networking
    return networking:get("economy", "/v1/resale-tax-rate")
end

function MonetizationController:configurationV2GET(gameId)
	local networking = self.__networking
	return networking:get("develop", "/v2/universes/"..gameId.."/configuration")
end

function MonetizationController:configurationV2PATCH(gameId, configuration)
	local networking = self.__networking
	return networking:patch("develop", "/v2/universes/"..gameId.."/configuration", {
		Body = configuration
	})
end

function MonetizationController:vipServersV1GET(gameId)
	local networking = self.__networking
	return networking:get("develop", "/v1/universes/"..gameId.."/configuration/vip-servers")
end

function MonetizationController:developerProductsV1GET(gameId, page)
    local networking = self.__networking
    return networking:get("api", "/developerproducts/list", {
        Params = {
            universeId = gameId,
            page = page,
        }
    })
end

function MonetizationController:developerProductsCreateV1POST(gameId, product)
    local networking = self.__networking
    return networking:post("develop", "/v1/universes/"..gameId.."/developerproducts", {
        Params = {
            name = product.name,
            --[[
                Description is always an empty string because the endpoint requires the field, but should not be
                configurable from Studio as a Product decision.
            ]]
            description = " ",
            priceInRobux = product.price,
        },

        Body = {},
    })
end

function MonetizationController:developerProductsUpdateV1POST(gameId, product)
    local networking = self.__networking
    return networking:post("develop", "/v1/universes/"..gameId.."/developerproducts/"..product.id.."/update", {
        Body = {
            name = product.name,
            priceInRobux = product.price,
        }
    })
end

function MonetizationController:badgesV1GET(gameId, cursor)    
    local networking = self.__networking
    return networking:get("badges", "/v1/universes/"..gameId.."/badges", {
        Params = {
            sortOrder = "Asc",
            cursor = cursor
        }
    })
end

function MonetizationController:getTaxRate()
    local response = self:economyV1GET():await()
    return response.responseBody.taxRate
end

function MonetizationController:getMinimumFee()
    local response = self:economyV1GET():await()
    return response.responseBody.minimumFee
end

function MonetizationController:getPaidAccessEnabled(gameId)
    local response = self:configurationV2GET(gameId):await()
	return response.responseBody.isForSale
end

function MonetizationController:setPaidAccessEnabled(gameId, isForSale)
    self:configurationV2PATCH(gameId, { isForSale = isForSale })
end

function MonetizationController:getPaidAccessPrice(gameId)
    local response = self:configurationV2GET(gameId):await()
	return response.responseBody.price
end

function MonetizationController:setPaidAccessPrice(gameId, price)
    self:configurationV2PATCH(gameId, { price = price })
end

function MonetizationController:getVIPServersEnabled(gameId)
    local response = self:vipServersV1GET(gameId):await()
	return response.responseBody.isEnabled
end

function MonetizationController:setVIPServersEnabled(gameId, allowPrivateServers)
    self:configurationV2PATCH(gameId, { allowPrivateServers = allowPrivateServers })
end

function MonetizationController:getVIPServersPrice(gameId)
    local response = self:vipServersV1GET(gameId):await()
	return response.responseBody.price
end

function MonetizationController:setVIPServersPrice(gameId, privateServerPrice)
    self:configurationV2PATCH(gameId, { privateServerPrice = privateServerPrice })
end

function MonetizationController:getVIPServersActiveServersCount(gameId)
    local response = self:vipServersV1GET(gameId):await()
	return response.responseBody.activeServersCount
end

function MonetizationController:getVIPServersActiveSubscriptionsCount(gameId)
    local response = self:vipServersV1GET(gameId):await()
	return response.responseBody.activeSubscriptionsCount
end

function MonetizationController:getDeveloperProducts(gameId, cursor)
    local page = (cursor and cursor.page) and cursor.page or 1
    local response = self:developerProductsV1GET(gameId, page):await()

    local isFinalPage = response.responseBody.FinalPage

    if isFinalPage then
        cursor = Cryo.None
    else
        cursor = {
            page = page + 1
        }
    end

    local responseDPs = response.responseBody.DeveloperProducts
    local resultDPs = {}

    for _,product in ipairs(responseDPs) do
        resultDPs[product.ProductId] = {
            id = product.ProductId,
            name = product.Name,
            price = product.PriceInRobux,
        }
    end

    return resultDPs, cursor
end

function MonetizationController:createDevProduct(gameId, product)
    self:developerProductsCreateV1POST(gameId, product):await()
end

function MonetizationController:updateDevProduct(gameId, product)
    self:developerProductsUpdateV1POST(gameId, product):await()
end

function MonetizationController:getBadges(gameId, cursor)
    local response = self:badgesV1GET(gameId, cursor):await()

    cursor = response.responseBody.nextPageCursor
    
    local responseBadges = response.responseBody.data
    local resultBadges = {}
    
    for _,badge in ipairs(responseBadges) do
        resultBadges[badge.id] = {
            id = badge.id,
            name = badge.name,
            description = badge.description or "",
            iconImageId = badge.iconImageId
        }
    end

    return resultBadges, cursor
end

return MonetizationController
