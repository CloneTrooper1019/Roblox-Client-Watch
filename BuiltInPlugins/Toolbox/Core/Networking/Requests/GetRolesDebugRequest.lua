local Plugin = script.Parent.Parent.Parent.Parent

local Promise = require(Plugin.Libs.Framework.Util.Promise)

local NetworkError = require(Plugin.Core.Actions.NetworkError)
local SetAllowedAssetTypes =  require(Plugin.Core.Actions.SetAllowedAssetTypes)

local SetTagsMetadata = require(Plugin.Core.Actions.SetTagsMetadata)

local DebugFlags = require(Plugin.Core.Util.DebugFlags)

--[[

UGC asset categories for the Creations tab are calculated on the fly based on the user's roles.

It is a multi-step process to be granted the role of UGC creator.

To make this process easy the debug flag FFlagDebugToolboxGetRolesRequest can be enabled which
uses this dummy data to provide the user with the UGC creator roles.

]]
return function(networkInterface)
	return function(store)

		local allowedAssetTypesForUpload = {
			Image = { allowedFileExtensions = { ".jpg", ".png", ".bmp" } },
			Mesh = { allowedFileExtensions = { ".mesh" } },
			Hat = { allowedFileExtensions = { ".rbxm" } },
			HairAccessory = { allowedFileExtensions = { ".rbxm" } },
			FaceAccessory = { allowedFileExtensions = { ".rbxm" } },
			NeckAccessory = { allowedFileExtensions = { ".rbxm" } },
			ShoulderAccessory = { allowedFileExtensions = { ".rbxm" } },
			FrontAccessory = { allowedFileExtensions = { ".rbxm" } },
			BackAccessory = { allowedFileExtensions = { ".rbxm" } },
			WaistAccessory = { allowedFileExtensions = { ".rbxm" } },
			Plugin = { allowedFileExtensions = { ".rbxm" } }
		}
		local allowedAssetTypesForRelease = {
			Hat = {
				allowedPriceRange = { minRobux = 50, maxRobux = 5000 },
				marketplaceFeesPercentage = 70,
				premiumPricing = {
					allowedDiscountPercentages = { 25, 50, 75 },
					allowedPriceRange = { minRobux = 50, maxRobux = 5000 }
				}
			},
			HairAccessory = {
				allowedPriceRange = { minRobux = 50, maxRobux = 5000 },
				marketplaceFeesPercentage = 70,
				premiumPricing = {
					allowedDiscountPercentages = { 25, 50, 75 },
					allowedPriceRange = { minRobux = 50, maxRobux = 5000 }
				}
			},
			FaceAccessory = {
				allowedPriceRange = { minRobux = 15, maxRobux = 5000 },
				marketplaceFeesPercentage = 70,
				premiumPricing = {
					allowedDiscountPercentages = { 25, 50, 75 },
					allowedPriceRange = { minRobux = 15, maxRobux = 5000 }
				}
			},
			NeckAccessory = {
				allowedPriceRange = { minRobux = 20, maxRobux = 5000 },
				marketplaceFeesPercentage = 70,
				premiumPricing = {
					allowedDiscountPercentages = { 25, 50, 75 },
					allowedPriceRange = { minRobux = 20, maxRobux = 5000 }
				}
			},
			ShoulderAccessory = {
				allowedPriceRange = { minRobux = 15, maxRobux = 5000 },
				marketplaceFeesPercentage = 70,
				premiumPricing = {
					allowedDiscountPercentages = { 25, 50, 75 },
					allowedPriceRange = { minRobux = 15, maxRobux = 5000 }
				}
			},
			FrontAccessory = {
				allowedPriceRange = { minRobux = 20, maxRobux = 5000 },
				marketplaceFeesPercentage = 70,
				premiumPricing = {
					allowedDiscountPercentages = { 25, 50, 75 },
					allowedPriceRange = { minRobux = 20, maxRobux = 5000 }
				}
			},
			BackAccessory = {
				allowedPriceRange = { minRobux = 100, maxRobux = 10000 },
				marketplaceFeesPercentage = 70,
				premiumPricing = {
					allowedDiscountPercentages = { 25, 50, 75 },
					allowedPriceRange = { minRobux = 100, maxRobux = 10000 }
				}
			},
			WaistAccessory = {
				allowedPriceRange = { minRobux = 50, maxRobux = 5000 },
				marketplaceFeesPercentage = 70,
				premiumPricing = {
					allowedDiscountPercentages = { 25, 50, 75 },
					allowedPriceRange = { minRobux = 50, maxRobux = 5000 }
				}
			},
			Shirt = {
				allowedPriceRange = { minRobux = 5, maxRobux = 999999999 },
				marketplaceFeesPercentage = 30,
			},
			Pants = {
				allowedPriceRange = { minRobux = 5, maxRobux = 999999999 },
				marketplaceFeesPercentage = 30,
			},
			TShirt = {
				allowedPriceRange = { minRobux = 2, maxRobux = 999999999 },
				marketplaceFeesPercentage = 30,
			}
		}
		store:dispatch(SetAllowedAssetTypes(allowedAssetTypesForRelease, allowedAssetTypesForUpload))
	end
end
