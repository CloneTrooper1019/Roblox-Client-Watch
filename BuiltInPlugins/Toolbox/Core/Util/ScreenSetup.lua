local Plugin = script.Parent.Parent.Parent
local Util = Plugin.Core.Util
local convertArrayToTable = require(Util.convertArrayToTable)
local AssetConfigConstants = require(Util.AssetConfigConstants)
local AssetConfigUtil = require(Util.AssetConfigUtil)

local ScreenSetup = {}

local FFlagSupportUploadGroupAnimations = game:DefineFastFlag("StudioSupportUploadGroupAnimations", false)
local FFlagUGCGroupUploads = game:GetFastFlag("UGCGroupUploads")

ScreenSetup.keys = convertArrayToTable({
	"SHOW_SALES_TAB",
	"SHOW_VERSIONS_TAB",
	"SHOW_OWNERSHIP",
	"SHOW_GENRE",
	"SHOW_COPY",
	"SHOW_COMMENT",
	"SHOW_ASSET_TYPE",
	"SHOW_OVERRIDE_BUTTON",
	"SHOW_SALE", -- For marketplace asset, we put sales along with creator
	"SHOW_PRICE",
	"SHOW_PERMISSIONS_TAB", -- For Packages if and only if the current user is the Package Owner.
})

local AssetCategory = {
	Marketplace = {},
	Catalog = {}
}

local keys = ScreenSetup.keys
-- Sorted alphabetically
local params = {
	[AssetConfigConstants.FLOW_TYPE.EDIT_FLOW] = {
		[AssetCategory.Marketplace] = {
			[keys.SHOW_COMMENT] = true,
			[keys.SHOW_COPY] = true,
			[keys.SHOW_GENRE] = true,
			[keys.SHOW_OWNERSHIP] = true,
			[keys.SHOW_PRICE] = false,
			[keys.SHOW_SALE] = false,
			[keys.SHOW_VERSIONS_TAB] = true,
		},
		[AssetCategory.Catalog] = {
			[keys.SHOW_ASSET_TYPE] = true,
			[keys.SHOW_OWNERSHIP] = FFlagUGCGroupUploads,
			[keys.SHOW_SALES_TAB] = true,
		},
	},

	[AssetConfigConstants.FLOW_TYPE.UPLOAD_FLOW] = {
		[AssetCategory.Marketplace] = {
			[keys.SHOW_COMMENT] = true,
			[keys.SHOW_COPY] = true,
			[keys.SHOW_GENRE] = true,
			[keys.SHOW_OVERRIDE_BUTTON] = true,
			[keys.SHOW_OWNERSHIP] = true,
			[keys.SHOW_PRICE] = false,
			[keys.SHOW_SALE] = false,
			[keys.SHOW_VERSIONS_TAB] = false,
		},
		[AssetCategory.Catalog] = {
			[keys.SHOW_ASSET_TYPE] = true,
			[keys.SHOW_OWNERSHIP] = FFlagUGCGroupUploads,
		},
	}
}

params[AssetConfigConstants.FLOW_TYPE.DOWNLOAD_FLOW] = {
	[AssetCategory.Marketplace] = {
		[keys.SHOW_COMMENT] = false,
		[keys.SHOW_COPY] = false,
		[keys.SHOW_GENRE] = false,
		[keys.SHOW_OVERRIDE_BUTTON] = false,
		[keys.SHOW_OWNERSHIP] = false,
		[keys.SHOW_PRICE] = false,
		[keys.SHOW_SALE] = false,
		[keys.SHOW_VERSIONS_TAB] = false,
	},
	[AssetCategory.Catalog] = {
		[keys.SHOW_COMMENT] = false,
		[keys.SHOW_COPY] = false,
		[keys.SHOW_GENRE] = false,
		[keys.SHOW_OVERRIDE_BUTTON] = false,
		[keys.SHOW_OWNERSHIP] = false,
		[keys.SHOW_PRICE] = false,
		[keys.SHOW_SALE] = false,
		[keys.SHOW_VERSIONS_TAB] = false,
	},
}

-- Some assets need to override the default setting for publishing and editing asset. In this case, plugin need to
-- override those.
-- We will first check if we have defined override behavior in this table. If it's defined here, we will be using those value first.
-- everything else falls into default behavoir.
local assetTypeOverride = {
	[Enum.AssetType.Plugin] = {
		[AssetConfigConstants.FLOW_TYPE.UPLOAD_FLOW] = {
			[keys.SHOW_ASSET_TYPE] = true,
			[keys.SHOW_COMMENT] = false,
			[keys.SHOW_COPY] = false, -- For plugin, sales will be acting as allow copy when user is not whitelisted.
			[keys.SHOW_GENRE] = false,
			[keys.SHOW_OVERRIDE_BUTTON] = true,
			[keys.SHOW_PRICE] = false, -- Only show price when sales has been set to OnSale.
			[keys.SHOW_SALES_TAB] = true,
		},
		[AssetConfigConstants.FLOW_TYPE.EDIT_FLOW] = {
			[keys.SHOW_ASSET_TYPE] = true,
			[keys.SHOW_COMMENT] = false,
			[keys.SHOW_COPY] = false,
			[keys.SHOW_GENRE] = false,
			[keys.SHOW_OWNERSHIP] = true,
			[keys.SHOW_PRICE] = false,
			[keys.SHOW_SALE] = false,
			[keys.SHOW_VERSIONS_TAB] = true,
			[keys.SHOW_SALES_TAB] = true,
		}
	},
	[Enum.AssetType.Model] = {
		[AssetConfigConstants.FLOW_TYPE.UPLOAD_FLOW] = {
			[keys.SHOW_OVERRIDE_BUTTON] = true,
		},
	},
}

assetTypeOverride[Enum.AssetType.Animation] = {
	[AssetConfigConstants.FLOW_TYPE.UPLOAD_FLOW] = {
		[keys.SHOW_OVERRIDE_BUTTON] = true,
		[keys.SHOW_COMMENT] = false,
		[keys.SHOW_COPY] = false,
		[keys.SHOW_GENRE] = false,
		[keys.SHOW_OWNERSHIP] = FFlagSupportUploadGroupAnimations,
		[keys.SHOW_PRICE] = false,
		[keys.SHOW_SALE] = false,
		[keys.SHOW_VERSIONS_TAB] = false,
		[keys.SHOW_SALES_TAB] = false,
	},
}

function ScreenSetup.queryParam(flowType, assetTypeEnum, paramKey)
	local assetCategoryType = AssetConfigUtil.isCatalogAsset(assetTypeEnum) and AssetCategory.Catalog or AssetCategory.Marketplace
	local defaultValue = params[flowType][assetCategoryType][paramKey] or false

	if not assetTypeOverride[assetTypeEnum] then return defaultValue end
	if not assetTypeOverride[assetTypeEnum][flowType] then return defaultValue end
	if assetTypeOverride[assetTypeEnum][flowType][paramKey] == nil then return defaultValue end

	return assetTypeOverride[assetTypeEnum][flowType][paramKey]
end

return ScreenSetup
