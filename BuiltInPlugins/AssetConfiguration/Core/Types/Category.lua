--!nocheck
-- TODO Remove nocheck with FFlagToolboxFixCategoryUrlsCircularDependency
local FFlagFixToolboxPluginScaling = game:DefineFastFlag("FixToolboxPluginScaling", false)
local FFlagToolboxDisableMarketplaceAndRecentsForLuobu = game:GetFastFlag("ToolboxDisableMarketplaceAndRecentsForLuobu")
local FFlagToolboxShowRobloxCreatedAssetsForLuobu = game:GetFastFlag("ToolboxShowRobloxCreatedAssetsForLuobu")
local FFlagFixAudioAssetsForLuoBu = game:DefineFastFlag("FixAudioAssetsForLuoBu", false)
local FFlagStudioCreatePluginPolicyService = game:GetFastFlag("StudioCreatePluginPolicyService")
local FFlagToolboxRemoveGroupInventory2 = game:GetFastFlag("ToolboxRemoveGroupInventory2")
local FFlagToolboxFixCategoryUrlsCircularDependency = game:GetFastFlag("ToolboxFixCategoryUrlsCircularDependency")
local FFlagUGCGroupUploads = game:GetFastFlag("UGCGroupUploads")
local FFlagToolboxLegacyFetchGroupModelsAndPackages = game:GetFastFlag("ToolboxLegacyFetchGroupModelsAndPackages")

local Plugin = script.Parent.Parent.Parent
local CreatorInfoHelper = require(Plugin.Core.Util.CreatorInfoHelper)
local DebugFlags = require(Plugin.Core.Util.DebugFlags)
local AssetConfigUtil
local getAllowedAssetTypeEnums
if FFlagToolboxFixCategoryUrlsCircularDependency then
	getAllowedAssetTypeEnums = require(Plugin.Core.Util.getAllowedAssetTypeEnums)
else
	AssetConfigUtil = require(Plugin.Core.Util.AssetConfigUtil)
end

local Cryo = require(Plugin.Libs.Cryo)
local StudioService = game:GetService("StudioService")

local Rollouts = require(Plugin.Core.Rollouts)

local showRobloxCreatedAssets = require(Plugin.Core.Util.ToolboxUtilities).showRobloxCreatedAssets
local disableMarketplaceAndRecents = require(Plugin.Core.Util.ToolboxUtilities).disableMarketplaceAndRecents
local getMarketplaceDisabledCategories = require(Plugin.Core.Util.ToolboxUtilities).getMarketplaceDisabledCategories

local FStringLuobuMarketplaceDisabledCategories = game:GetFastString("LuobuMarketplaceDisabledCategories")

local Category = {}

Category.OwnershipType = {
	FREE = 0,
	MY = 1,
	RECENT = 2,
	GROUP = 3
}

Category.AssetType = {
	MODEL = 0,
	DECAL = 1,
	MESH = 2,
	MESHPART = 3,
	AUDIO = 4,
	PACKAGE = 5,
	PLUGIN = 6,
	HAT = 7,
	TEE_SHIRT = 8,
	SHIRT = 9,
	PANTS = 10,
	HAIR_ACCESSORY = 11,
	FACE_ACCESSORY = 12,
	NECK_ACCESSORY = 13,
	SHOULDER_ACCESSORY = 14,
	FRONT_ACCESSORY = 15,
	BACK_ACCESSORY = 16,
	WAIST_ACCESSORY = 17,
	VIDEO = 18
}

Category.ToolboxAssetTypeToEngine = {
	[Category.AssetType.MODEL] = Enum.AssetType.Model,
	[Category.AssetType.DECAL] = Enum.AssetType.Decal,
	[Category.AssetType.MESH] = Enum.AssetType.Mesh,
	[Category.AssetType.MESHPART] = Enum.AssetType.MeshPart,
	[Category.AssetType.AUDIO] = Enum.AssetType.Audio,
	[Category.AssetType.PACKAGE] = Enum.AssetType.Package,
	[Category.AssetType.PLUGIN] = Enum.AssetType.Plugin,
	[Category.AssetType.HAT] = Enum.AssetType.Hat,
	[Category.AssetType.TEE_SHIRT] = Enum.AssetType.TShirt,
	[Category.AssetType.SHIRT] = Enum.AssetType.Shirt,
	[Category.AssetType.PANTS] = Enum.AssetType.Pants,
	[Category.AssetType.HAIR_ACCESSORY] = Enum.AssetType.HairAccessory,
	[Category.AssetType.FACE_ACCESSORY] = Enum.AssetType.FaceAccessory,
	[Category.AssetType.NECK_ACCESSORY] = Enum.AssetType.NeckAccessory,
	[Category.AssetType.SHOULDER_ACCESSORY] = Enum.AssetType.ShoulderAccessory,
	[Category.AssetType.FRONT_ACCESSORY] = Enum.AssetType.FrontAccessory,
	[Category.AssetType.BACK_ACCESSORY] = Enum.AssetType.BackAccessory,
	[Category.AssetType.WAIST_ACCESSORY] = Enum.AssetType.WaistAccessory,
	[Category.AssetType.VIDEO] = Enum.AssetType.Video,
}

Category.FREE_MODELS = {name = "FreeModels", category = "FreeModels",
	ownershipType = Category.OwnershipType.FREE, assetType = Category.AssetType.MODEL}
Category.FREE_DECALS = {name = "FreeDecals", category = "FreeDecals",
	ownershipType = Category.OwnershipType.FREE, assetType = Category.AssetType.DECAL}
Category.FREE_MESHES = {name = "FreeMeshes", category = "FreeMeshes",
	ownershipType = Category.OwnershipType.FREE, assetType = Category.AssetType.MESH}
Category.FREE_AUDIO = {name = "FreeAudio", category = "FreeAudio",
	ownershipType = Category.OwnershipType.FREE, assetType = Category.AssetType.AUDIO}
Category.WHITELISTED_PLUGINS = {name = "PaidPlugins", category = "WhitelistedPlugins",
	ownershipType = Category.OwnershipType.FREE, assetType = Category.AssetType.PLUGIN}

Category.MY_MODELS = {name = "MyModels", category = "MyModelsExceptPackage",
	ownershipType = Category.OwnershipType.MY, assetType = Category.AssetType.MODEL}
Category.MY_DECALS = {name = "MyDecals", category = "MyDecals",
	ownershipType = Category.OwnershipType.MY, assetType = Category.AssetType.DECAL}
Category.MY_MESHES = {name = "MyMeshes", category = "MyMeshes",
	ownershipType = Category.OwnershipType.MY, assetType = Category.AssetType.MESH}
Category.MY_AUDIO = {name = "MyAudio", category = "MyAudio",
	ownershipType = Category.OwnershipType.MY, assetType = Category.AssetType.AUDIO}
Category.MY_PLUGINS = {name = "MyPlugins", category = "MyPlugins",
	ownershipType = Category.AssetType.PLUGIN, assetType = Category.AssetType.PLUGIN}

Category.MARKETPLACE_VIDEOS = {name = "FreeVideo", category = "FreeVideo",
	ownershipType = Category.OwnershipType.FREE, assetType = Category.AssetType.VIDEO}
Category.MY_VIDEOS = {name = "MyVideo", category = "MyVideo",
	ownershipType = Category.AssetType.MY, assetType = Category.AssetType.VIDEO}
Category.RECENT_VIDEO = {name = "RecentVideo", category = "RecentVideo",
	ownershipType = Category.OwnershipType.VIDEO, assetType = Category.AssetType.VIDEO}

Category.RECENT_MODELS = {name = "RecentModels", category = "RecentModels",
	ownershipType = Category.OwnershipType.RECENT, assetType = Category.AssetType.MODEL}
Category.RECENT_DECALS = {name = "RecentDecals", category = "RecentDecals",
	ownershipType = Category.OwnershipType.RECENT, assetType = Category.AssetType.DECAL}
Category.RECENT_MESHES = {name = "RecentMeshes", category = "RecentMeshes",
	ownershipType = Category.OwnershipType.RECENT, assetType = Category.AssetType.MESH}
Category.RECENT_AUDIO = {name = "RecentAudio", category = "RecentAudio",
	ownershipType = Category.OwnershipType.RECENT, assetType = Category.AssetType.AUDIO}

Category.GROUP_MODELS = {name = "GroupModels", category = "GroupModelsExceptPackage",
	ownershipType = Category.OwnershipType.GROUP, assetType = Category.AssetType.MODEL}
Category.GROUP_DECALS = {name = "GroupDecals", category = "GroupDecals",
	ownershipType = Category.OwnershipType.GROUP, assetType = Category.AssetType.DECAL}
Category.GROUP_MESHES = {name = "GroupMeshes", category = "GroupMeshes",
	ownershipType = Category.OwnershipType.GROUP, assetType = Category.AssetType.MESH}
Category.GROUP_AUDIO = {name = "GroupAudio", category = "GroupAudio",
	ownershipType = Category.OwnershipType.GROUP, assetType = Category.AssetType.AUDIO}
Category.GROUP_PLUGINS = {name = "GroupPlugins", category = "GroupPlugins",
	ownershipType = Category.OwnershipType.GROUP, assetType = Category.AssetType.PLUGIN}

Category.MY_PACKAGES = {name = "MyPackages", category = "MyPackages",
	ownershipType = Category.OwnershipType.MY, assetType = Category.AssetType.PACKAGE}
Category.GROUP_PACKAGES = {name = "GroupPackages", category = "GroupPackages",
	ownershipType = Category.OwnershipType.GROUP, assetType = Category.AssetType.PACKAGE}

Category.CREATIONS_DEVELOPMENT_SECTION_DIVIDER = {name = "CreationsDevelopmentSectionDivider", selectable=false}
if FFlagToolboxRemoveGroupInventory2 then
	-- Eventually, the itemsconfiguration endpoint should fetch MyModelsExceptPackages,
	-- but currently it is fetching both Models and Packages.
	-- Until then, pull the logic from the develop api.
	Category.CREATIONS_GROUP_MODELS = {name = "CreationsGroupModels", category = "GroupModelsExceptPackage",
		ownershipType = Category.OwnershipType.GROUP, assetType = Category.AssetType.MODEL}
	Category.CREATIONS_GROUP_PACKAGES = {name = "CreationsGroupPackages", category = "GroupPackages",
		ownershipType = Category.OwnershipType.GROUP, assetType = Category.AssetType.PACKAGE}
else
	Category.CREATIONS_GROUP_MODELS = {name = "CreationsGroupModels", category = "CreationsGroupModels", assetType = Category.AssetType.MODEL,
	ownershipType = Category.OwnershipType.GROUP,}

	if FFlagToolboxLegacyFetchGroupModelsAndPackages then
		-- change the category to reflect the develop api categories
		Category.CREATIONS_GROUP_MODELS = {name = "CreationsGroupModels", category = "GroupModels", assetType = Category.AssetType.MODEL,
			ownershipType = Category.OwnershipType.GROUP,}

		-- stub in GroupPackages
		Category.CREATIONS_GROUP_PACKAGES = {name = "" }
	end
end

Category.CREATIONS_MODELS = {name = "CreationsModels", category = "CreationsModels", assetType = Category.AssetType.MODEL,
		ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_DECALS = {name = "CreationsDecals", category = "CreationsDecals", assetType = Category.AssetType.DECAL,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_AUDIO = {name = "CreationsAudio", category = "CreationsAudio", assetType = Category.AssetType.AUDIO,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_MESHES = {name = "CreationsMeshes", category = "CreationsMeshes", assetType = Category.AssetType.MESHPART,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_PLUGIN = {name = "CreationsPlugins", category = "CreationsPlugins", assetType = Category.AssetType.PLUGIN,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_GROUP_DECALS = {name = "CreationsGroupDecals", category = "CreationsGroupDecals", assetType = Category.AssetType.DECAL,
	ownershipType = Category.OwnershipType.GROUP,}
Category.CREATIONS_GROUP_AUDIO = {name = "CreationsGroupAudio", category = "CreationsGroupAudio", assetType = Category.AssetType.AUDIO,
	ownershipType = Category.OwnershipType.GROUP,}
Category.CREATIONS_GROUP_MESHES = {name = "CreationsGroupMeshes", category = "CreationsGroupMeshes", assetType = Category.AssetType.MESHPART,
	ownershipType = Category.OwnershipType.GROUP,}
Category.CREATIONS_GROUP_PLUGIN = {name = "CreationsGroupPlugins", category = "CreationsGroupPlugins", assetType = Category.AssetType.PLUGIN,
	ownershipType = Category.OwnershipType.GROUP,}
Category.CREATIONS_CATALOG_SECTION_DIVIDER = {name = "CreationsCatalogSectionDivider", selectable=false}
Category.CREATIONS_HATS = {name = "CreationsHats", category = "CreationsHats", assetType = Category.AssetType.HAT,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_TEE_SHIRT = {name = "CreationsTeeShirts", category = "CreationsTeeShirts", assetType = Category.AssetType.TEE_SHIRT,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_SHIRT = {name = "CreationsShirts", category = "CreationsShirts", assetType = Category.AssetType.SHIRT,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_PANTS = {name = "CreationsPants", category = "CreationsPants", assetType = Category.AssetType.PANTS,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_HAIR = {name = "CreationsHair", category = "CreationsHair", assetType = Category.AssetType.HAIR_ACCESSORY,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_FACE_ACCESSORIES = {name = "CreationsFaceAccessories", category = "CreationsFaceAccessories", assetType = Category.AssetType.FACE_ACCESSORY,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_NECK_ACCESSORIES = {name = "CreationsNeckAccessories", category = "CreationsNeckAccessories", assetType = Category.AssetType.NECK_ACCESSORY,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_SHOULDER_ACCESSORIES = {name = "CreationsShoulderAccessories", category = "CreationsShoulderAccessories", assetType = Category.AssetType.SHOULDER_ACCESSORY,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_FRONT_ACCESSORIES = {name = "CreationsFrontAccessories", category = "CreationsFrontAccessories", assetType = Category.AssetType.FRONT_ACCESSORY,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_BACK_ACCESSORIES = {name = "CreationsBackAccessories", category = "CreationsBackAccessories", assetType = Category.AssetType.BACK_ACCESSORY,
	ownershipType = Category.OwnershipType.MY,}
Category.CREATIONS_WAIST_ACCESSORIES = {name = "CreationsWaistAccessories", category = "CreationsWaistAccessories", assetType = Category.AssetType.WAIST_ACCESSORY,
	ownershipType = Category.OwnershipType.MY,}
if FFlagUGCGroupUploads then
	Category.CREATIONS_GROUP_HATS = {name = "CreationsGroupHats", category = "CreationsGroupHats", assetType = Category.AssetType.HAT,
		ownershipType = Category.OwnershipType.GROUP,}
	Category.CREATIONS_GROUP_HAIR = {name = "CreationsGroupHair", category = "CreationsGroupHair", assetType = Category.AssetType.HAIR_ACCESSORY,
		ownershipType = Category.OwnershipType.GROUP,}
	Category.CREATIONS_GROUP_FACE_ACCESSORIES = {name = "CreationsGroupFaceAccessories", category = "CreationsGroupFaceAccessories", assetType = Category.AssetType.FACE_ACCESSORY,
		ownershipType = Category.OwnershipType.GROUP,}
	Category.CREATIONS_GROUP_NECK_ACCESSORIES = {name = "CreationsGroupNeckAccessories", category = "CreationsGroupNeckAccessories", assetType = Category.AssetType.NECK_ACCESSORY,
		ownershipType = Category.OwnershipType.GROUP,}
	Category.CREATIONS_GROUP_SHOULDER_ACCESSORIES = {name = "CreationsGroupShoulderAccessories", category = "CreationsGroupShoulderAccessories", assetType = Category.AssetType.SHOULDER_ACCESSORY,
		ownershipType = Category.OwnershipType.GROUP,}
	Category.CREATIONS_GROUP_FRONT_ACCESSORIES = {name = "CreationsGroupFrontAccessories", category = "CreationsGroupFrontAccessories", assetType = Category.AssetType.FRONT_ACCESSORY,
		ownershipType = Category.OwnershipType.GROUP,}
	Category.CREATIONS_GROUP_BACK_ACCESSORIES = {name = "CreationsGroupBackAccessories", category = "CreationsGroupBackAccessories", assetType = Category.AssetType.BACK_ACCESSORY,
		ownershipType = Category.OwnershipType.GROUP,}
	Category.CREATIONS_GROUP_WAIST_ACCESSORIES = {name = "CreationsGroupWaistAccessories", category = "CreationsGroupWaistAccessories", assetType = Category.AssetType.WAIST_ACCESSORY,
		ownershipType = Category.OwnershipType.GROUP,}
end

-- Category sets used for splitting inventory/shop
Category.MARKETPLACE = {
	Category.FREE_MODELS,
	Category.FREE_DECALS,
	Category.FREE_MESHES,
	Category.FREE_AUDIO,
	Category.MARKETPLACE_VIDEOS,
	Category.WHITELISTED_PLUGINS,
}

Category.INVENTORY = {
	Category.MY_MODELS,
	Category.MY_DECALS,
	Category.MY_MESHES,
	Category.MY_AUDIO,
	Category.MY_PACKAGES,
	Category.MY_VIDEOS,
	Category.MY_PLUGINS,
}

if not FFlagToolboxRemoveGroupInventory2 then
	Category.INVENTORY_WITH_GROUPS = {
		Category.MY_MODELS,
		Category.MY_DECALS,
		Category.MY_MESHES,
		Category.MY_AUDIO,
		Category.MY_PACKAGES,
		Category.MY_VIDEOS,
		Category.GROUP_MODELS,
		Category.GROUP_DECALS,
		Category.GROUP_MESHES,
		Category.GROUP_AUDIO,
		Category.GROUP_PACKAGES,
	}
end

Category.RECENT = {
	Category.RECENT_MODELS,
	Category.RECENT_DECALS,
	Category.RECENT_MESHES,
	Category.RECENT_AUDIO,
	Category.RECENT_VIDEO,
}

Category.DEFAULT = nil
if FFlagToolboxDisableMarketplaceAndRecentsForLuobu and disableMarketplaceAndRecents() then
	Category.DEFAULT = Category.MY_MODELS
else
	Category.DEFAULT = Category.FREE_MODELS
end

if FFlagFixAudioAssetsForLuoBu then
	Category.CREATOR_ROBLOX = {
		Id = 1,
		Type = Enum.CreatorType.User.Value,
	}

	Category.CREATOR_ROBLOX_DEVELOP_API = {
		Id = 1,
		-- Develop API creatorType is not aligned with the CreatorType Enum
		Type = CreatorInfoHelper.clientToBackend(Enum.CreatorType.User.Value),
	}
else
	Category.CREATOR_ROBLOX = {
		Id = 1,
	}
end

-- Categories which are supported by GetToolboxItems
Category.API_NAMES = {
	[Category.FREE_AUDIO.name] = "Audio",
	[Category.WHITELISTED_PLUGINS.name] = "Plugins",
	[Category.FREE_MESHES.name] = "Meshes",
	[Category.FREE_DECALS.name] = "Decals",
	[Category.MARKETPLACE_VIDEOS.name] = "Videos",
	[Category.FREE_MODELS.name] = "Models",
}

local function getCreationCategories()
	local categories = {
		Category.CREATIONS_DEVELOPMENT_SECTION_DIVIDER,
		Category.CREATIONS_MODELS,
		Category.CREATIONS_DECALS,
		Category.CREATIONS_AUDIO,
		Category.CREATIONS_MESHES,
		Category.CREATIONS_PLUGIN,
		Category.CREATIONS_GROUP_MODELS,
		Category.CREATIONS_GROUP_DECALS,
		Category.CREATIONS_GROUP_AUDIO,
		Category.CREATIONS_GROUP_MESHES,
		Category.CREATIONS_GROUP_PLUGIN,
	}

	if FFlagToolboxRemoveGroupInventory2 then
		table.insert(categories, Category.CREATIONS_GROUP_PACKAGES)
	end

	return categories
end

Category.MARKETPLACE_KEY = "Marketplace"
Category.INVENTORY_KEY = "Inventory"
Category.RECENT_KEY = "Recent"
Category.CREATIONS_KEY = "Creations"

if not FFlagToolboxRemoveGroupInventory2 then
	if Rollouts:getToolboxEndpointMigration() then
		local insertIndex = Cryo.List.find(Category.INVENTORY_WITH_GROUPS, Category.MY_VIDEOS) + 1
		table.insert(Category.INVENTORY_WITH_GROUPS, insertIndex, Category.MY_PLUGINS)
	else
		local insertIndex = Cryo.List.find(Category.INVENTORY_WITH_GROUPS, Category.MY_PACKAGES) + 1
		table.insert(Category.INVENTORY_WITH_GROUPS, insertIndex, Category.MY_PLUGINS)
	end

	local insertIndex2 = Cryo.List.find(Category.INVENTORY_WITH_GROUPS, Category.GROUP_AUDIO) + 1
	table.insert(Category.INVENTORY_WITH_GROUPS, insertIndex2, Category.GROUP_PLUGINS)
end

local disabledCategories = {}

if FFlagStudioCreatePluginPolicyService then
	disabledCategories = string.split(getMarketplaceDisabledCategories(), ";")
else
	if (StudioService:BaseURLHasChineseHost()) then
		disabledCategories = string.split(FStringLuobuMarketplaceDisabledCategories, ";")
	end
end

for _, categoryName in pairs(disabledCategories) do
	local categoryIndex = nil

	for i, category in pairs(Category.MARKETPLACE) do
		if category.name == categoryName then
			categoryIndex = i
		end
	end

	if categoryIndex then
		table.remove(Category.MARKETPLACE, categoryIndex)
	end
end
local tabForCategoryName = {}
local tabKeyForCategoryName = {}
local categoryByName = {}

for _, category in pairs(Category) do
	if category.name then
		categoryByName[category.name] = category
	end
end

-- This is to facilitate testability - in the unit test we cannot set the rollout as true until after Category has been required
function Category.updateForToolboxEndpointMigrationRollout()
	Category.API_NAMES = Cryo.Dictionary.join(Category.API_NAMES, {
		[Category.MY_AUDIO.name] = "audio",
		[Category.MY_PLUGINS.name] = "plugin",
		[Category.MY_MODELS.name] = "model",
		[Category.MY_MESHES.name] = "meshpart",
		[Category.MY_DECALS.name] = "decal",
		[Category.MY_VIDEOS.name] = "video",
		[Category.MY_PACKAGES.name] = "package",

		[Category.RECENT_AUDIO.name] = "audio",
		[Category.RECENT_MODELS.name] = "model",
		[Category.RECENT_MESHES.name] = "meshpart",
		[Category.RECENT_DECALS.name] = "decal",
		[Category.RECENT_VIDEO.name] = "video",
	})

	-- Fix broken Category ownership definitions
	-- TODO: When the rollout (ToolboxEndpointMigrationRolloutPercentage) is complete, merge these into the category definitions
	Category.MY_PLUGINS.ownershipType = Category.OwnershipType.MY
	Category.MY_VIDEOS.ownershipType = Category.OwnershipType.MY
	Category.RECENT_VIDEO.ownershipType = Category.OwnershipType.RECENT
end

if Rollouts:getToolboxEndpointMigration() then
	Category.updateForToolboxEndpointMigrationRollout()
end

Category.CREATIONS = getCreationCategories()

local tabs
local tabKeys
if FFlagToolboxDisableMarketplaceAndRecentsForLuobu and disableMarketplaceAndRecents() then
	tabs = {
		FFlagToolboxRemoveGroupInventory2 and Category.INVENTORY or Category.INVENTORY_WITH_GROUPS,
		Category.CREATIONS,
	}
	tabKeys = {
		Category.INVENTORY_KEY,
		Category.CREATIONS_KEY,
	}
elseif FFlagToolboxShowRobloxCreatedAssetsForLuobu and showRobloxCreatedAssets() then
	tabs = {
		Category.MARKETPLACE,
		FFlagToolboxRemoveGroupInventory2 and Category.INVENTORY or Category.INVENTORY_WITH_GROUPS,
		Category.CREATIONS,
	}
	tabKeys = {
		Category.MARKETPLACE_KEY,
		Category.INVENTORY_KEY,
		Category.CREATIONS_KEY,
	}
else
	tabs = {
		Category.MARKETPLACE,
		FFlagToolboxRemoveGroupInventory2 and Category.INVENTORY or Category.INVENTORY_WITH_GROUPS,
		Category.RECENT,
		Category.CREATIONS,
	}
	tabKeys = {
		Category.MARKETPLACE_KEY,
		Category.INVENTORY_KEY,
		Category.RECENT_KEY,
		Category.CREATIONS_KEY,
	}
end

for index, tab in ipairs(tabs) do
	for _, category in ipairs(tab) do
		tabForCategoryName[category.name] = tab
		tabKeyForCategoryName[category.name] = tabKeys[index]
	end
end

function Category.getTabForCategoryName(categoryName)
	return tabForCategoryName[categoryName] or Category.CREATIONS
end
function Category.getTabKeyForCategoryName(categoryName)
	return tabKeyForCategoryName[categoryName] or Category.CREATIONS_KEY
end

function Category.getCategoryByName(categoryName)
	local category = categoryByName[categoryName]
	if not category and DebugFlags.shouldDebugWarnings() then
		warn(("Lua Toolbox: no category for name %s"):format(tostring(categoryName)))
	end
	return category
end

function Category.getCategoryIndex(categoryName, roles)
	if categoryName == "" then
		return 1
	end
	local tabKey = Category.getTabKeyForCategoryName(categoryName)
	local tab = Category.getCategories(tabKey, roles)
	for index, category in ipairs(tab) do
		if category.name == categoryName then
			return index
		end
	end
	if DebugFlags.shouldDebugWarnings() then
		warn(("Lua Toolbox: no category index for name %s"):format(tostring(categoryName)))
	end
	return 1
end

function Category.categoryIsPackage(categoryName)
	local category = Category.getCategoryByName(categoryName)
	return category.assetType == Category.AssetType.PACKAGE
end

function Category.categoryIsFreeAsset(categoryName)
	local category = Category.getCategoryByName(categoryName)
	return category.ownershipType == Category.OwnershipType.FREE
end

function Category.categoryIsGroupAsset(categoryName)
	local category = Category.getCategoryByName(categoryName)
	return category.ownershipType == Category.OwnershipType.GROUP
end

function Category.categoryIsAudio(categoryName)
	local category = Category.getCategoryByName(categoryName)
	return category.assetType == Category.AssetType.AUDIO
end

function Category.categoryIsVideo(categoryName)
	local category = Category.getCategoryByName(categoryName)
	return category.assetType == Category.AssetType.VIDEO
end

function Category.categoryIsGroupPackages(categoryName)
	local category = Category.getCategoryByName(categoryName)
	return category.assetType == Category.AssetType.GROUP_PACKAGES
end

function Category.categoryIsPlugin(categoryName)
	local category = Category.getCategoryByName(categoryName)
	return category.assetType == Category.AssetType.PLUGIN
end

function Category.shouldShowPrices(categoryName)
	if FFlagFixToolboxPluginScaling then
		local isPlugins = Category.categoryIsPlugin(categoryName)
		local tab = Category.getTabForCategoryName(categoryName)
		local showPrices = isPlugins and tab == Category.MARKETPLACE
		return showPrices
	else
		return Category.categoryIsPlugin(categoryName)
	end
end

local ASSET_ENUM_CATEGORY_MAP = {
	[Enum.AssetType.Hat] = Category.CREATIONS_HATS,
	[Enum.AssetType.HairAccessory] = Category.CREATIONS_HAIR,
	[Enum.AssetType.FaceAccessory] = Category.CREATIONS_FACE_ACCESSORIES,
	[Enum.AssetType.NeckAccessory] = Category.CREATIONS_NECK_ACCESSORIES,
	[Enum.AssetType.ShoulderAccessory] = Category.CREATIONS_SHOULDER_ACCESSORIES,
	[Enum.AssetType.FrontAccessory] = Category.CREATIONS_FRONT_ACCESSORIES,
	[Enum.AssetType.BackAccessory] = Category.CREATIONS_BACK_ACCESSORIES,
	[Enum.AssetType.WaistAccessory] = Category.CREATIONS_WAIST_ACCESSORIES,
}

local ASSET_ENUM_GROUP_CATEGORY_MAP = {
	[Enum.AssetType.Hat] = Category.CREATIONS_GROUP_HATS,
	[Enum.AssetType.HairAccessory] = Category.CREATIONS_GROUP_HAIR,
	[Enum.AssetType.FaceAccessory] = Category.CREATIONS_GROUP_FACE_ACCESSORIES,
	[Enum.AssetType.NeckAccessory] = Category.CREATIONS_GROUP_NECK_ACCESSORIES,
	[Enum.AssetType.ShoulderAccessory] = Category.CREATIONS_GROUP_SHOULDER_ACCESSORIES,
	[Enum.AssetType.FrontAccessory] = Category.CREATIONS_GROUP_FRONT_ACCESSORIES,
	[Enum.AssetType.BackAccessory] = Category.CREATIONS_GROUP_BACK_ACCESSORIES,
	[Enum.AssetType.WaistAccessory] = Category.CREATIONS_GROUP_WAIST_ACCESSORIES,
}

function Category.getCategories(tabName, roles)
	if Category.CREATIONS_KEY == tabName then
		local categories = getCreationCategories()
		if roles then
			local allowedAssetTypeEnums
			if FFlagToolboxFixCategoryUrlsCircularDependency then
				allowedAssetTypeEnums = getAllowedAssetTypeEnums(roles.allowedAssetTypesForRelease)
			else
				allowedAssetTypeEnums = AssetConfigUtil.getAllowedAssetTypeEnums(roles.allowedAssetTypesForRelease)
			end
			if #allowedAssetTypeEnums > 0 then
				table.insert(categories, Category.CREATIONS_CATALOG_SECTION_DIVIDER)
				for _, assetTypeEnum in pairs(allowedAssetTypeEnums) do
					table.insert(categories, ASSET_ENUM_CATEGORY_MAP[assetTypeEnum])
				end
				if FFlagUGCGroupUploads then
					for _, assetTypeEnum in pairs(allowedAssetTypeEnums) do
						table.insert(categories, ASSET_ENUM_GROUP_CATEGORY_MAP[assetTypeEnum])
					end
				end
			end
		end
		return categories
	elseif Category.MARKETPLACE_KEY == tabName then
		return Category.MARKETPLACE
	elseif Category.INVENTORY_KEY == tabName then
		return FFlagToolboxRemoveGroupInventory2 and Category.INVENTORY or Category.INVENTORY_WITH_GROUPS
	elseif Category.RECENT_KEY == tabName then
		return Category.RECENT
	end
end

function Category.getEngineAssetType(assetType)
	local result = Category.ToolboxAssetTypeToEngine[assetType]
	if not result then
		if DebugFlags.shouldDebugWarnings() then
			warn(("Lua toolbox: No engine assetType for category asset type %s"):format(tostring(assetType)))
		end
	end
	return result
end

return Category
