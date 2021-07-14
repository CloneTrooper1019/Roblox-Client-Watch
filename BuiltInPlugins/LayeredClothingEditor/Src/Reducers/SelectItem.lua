local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Packages.Rodux)
local Constants = require(Plugin.Src.Util.Constants)
local Cryo = require(Plugin.Packages.Cryo)

return Rodux.createReducer({
	editingItem = nil,
	layeredClothingItemsInList = {},
	manuallyHiddenLayeredClothingItems = {},
	selectorMode = Constants.SELECTOR_MODE.None,
	editingCage = nil,
	cagesTransparency = {},
	acessoryTypeInfo = nil,
	attachmentPoint = {
		ItemCFrame = CFrame.new(),
		AttachmentCFrame = CFrame.new(),
	},
	}, {
		SetSelectorMode = function(state, action)
			return Cryo.Dictionary.join(state, {
				selectorMode = action.selectorMode,
			})
		end,
		SetLayeredClothingItemsInList = function(state, action)
			return Cryo.Dictionary.join(state, {
				layeredClothingItemsInList = action.layeredClothingItemsInList,
			})
		end,
		SetManuallyHiddenLayeredClothingItems = function(state, action)
			return Cryo.Dictionary.join(state, {
				manuallyHiddenLayeredClothingItems = action.manuallyHiddenLayeredClothingItems,
			})
		end,
		SetEditingCage = function(state, action)
			return Cryo.Dictionary.join(state, {
				editingCage = action.editingCage,
			})
		end,
		SetCagesTransparency = function(state, action)
			return Cryo.Dictionary.join(state, {
				cagesTransparency = action.cagesTransparency,
			})
		end,
		SetAccessoryTypeInfo = function(state, action)
			return Cryo.Dictionary.join(state, {
				accessoryTypeInfo = action.accessoryTypeInfo,
			})
		end,
		SetAttachmentPoint = function(state, action)
			return Cryo.Dictionary.join(state, {
				attachmentPoint = action.attachmentPoint,
			})
		end,
})
