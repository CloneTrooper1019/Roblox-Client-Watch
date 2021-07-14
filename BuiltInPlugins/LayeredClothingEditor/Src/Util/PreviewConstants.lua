--[[
	Constants applicable to the preview panel
]]

local Plugin = script.Parent.Parent.Parent

local Constants = require(Plugin.Src.Util.Constants)
local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)

local TABS_KEYS = {
	Avatars = "TAB_KEY_Avatars",
	Clothing = "TAB_KEY_Clothing",
	Animations = "TAB_KEY_Animations",

	None = "TAB_KEY_None",
}

local TABS_INFO = {
	[TABS_KEYS.Avatars] = {
		AssetIds = {
			5757830455,
			2280822931,
		},

		CanAddNew = true,
		PanelBlockerLocalizationKey = "PanelBlockerAddAvatar",
		InvalidAddLocalizationKey = "AvatarInvalidAdd",
		IsSelectedInstanceValid = function(item)
			return ItemCharacteristics.isFullyCagedCharacter(item)
		end,

		IsMultiSelect = false, --only one selection for all of sub grid tabs
		LayoutOrder = 1,
		LocalizationKey = Constants.LOCALIZATION_KEYS.Avatars,
	},
	[TABS_KEYS.Clothing] = {
		AssetIds = {
			5609096680,
			5612035582,
			5368411829,
			5081624439,
			3599544679,
			1657047,
			1028595,
		},

		CanAddNew = true,
		PanelBlockerLocalizationKey = "PanelBlockerAddClothing",
		InvalidAddLocalizationKey = "ClothingInvalidAdd",
		IsSelectedInstanceValid = function(item)
			return ItemCharacteristics.isFullyCagedClothing(item)
		end,

		IsMultiSelect = true, -- no restrictions on sub grid tabs
		LayoutOrder = 2,
		LocalizationKey = Constants.LOCALIZATION_KEYS.Clothing,
	},
	-- update AnimationIdToSequenceId when you update asset ids under animation tab
	[TABS_KEYS.Animations] = {
		AssetIds = {
			837009922,
			619528125,
			837011171,
			837013990,
			837012509,
			4849499887,
			3823158750,
			3716636630,
			3576717965,
			4689362868,
		},
		CanAddNew = true,
		PanelBlockerLocalizationKey = "PanelBlockerAddAnimation",
		InvalidAddLocalizationKey = "AnimationInvalidAdd",
		IsSelectedInstanceValid = function(item)
			return item:IsA("KeyframeSequence")
		end,

		IsMultiSelect = false, --only one selection for all of sub grid tabs
		LayoutOrder = 3,
		LocalizationKey = Constants.LOCALIZATION_KEYS.Animations
	},
}

local AnimationIdToSequenceId = {
	[837009922] = 742638842,
	[619528125] = 616111295,
	[837011171] = 742637942,
	[837013990] = 742636889,
	[837012509] = 742639220,
	-- emotes
	[4849499887] = 4841405708,
	[3823158750] = 3337994105,
	[3716636630] = 3333499508,
	[3576717965] = 3337978742,
	[4689362868] = 4686925579,
}

local PreviewConstants = {}
PreviewConstants.TABS_INFO = TABS_INFO
PreviewConstants.TABS_KEYS = TABS_KEYS
PreviewConstants.AnimationIdToSequenceId = AnimationIdToSequenceId
PreviewConstants.PreviewAvatarName = "PreviewAvatar"

return PreviewConstants