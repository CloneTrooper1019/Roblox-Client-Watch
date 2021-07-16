local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local Cryo = Util.Cryo
local deepCopy = Util.deepCopy
local Style = Util.Style

local StyleKey = require(Framework.Style.StyleKey)

local UIFolderData = require(Framework.UI.UIFolderData)
local TreeView = require(UIFolderData.TreeView.style)

local StudioFrameworkStyles = Framework.StudioUI.StudioFrameworkStyles
local Common = require(StudioFrameworkStyles.Common)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	local treeView = deepCopy(TreeView)
	return {
		Text = Common.MainText,
		TreeView = treeView,
		Indent = 20,
		RowHeight = 24,
		Arrow = {
			Image = "rbxasset://textures/StudioSharedUI/arrowSpritesheet.png",
			Size = 12,
			ExpandedOffset = Vector2.new(24, 0),
			CollapsedOffset = Vector2.new(12, 0),
			Color = StyleKey.MainText,
		},
		IconPadding = 5,
		HoverColor = StyleKey.ButtonHover,
		SelectedColor = StyleKey.DialogMainButton,
		SelectedTextColor = StyleKey.DialogMainButtonText,

		["&Compact"] = {
			Text = Cryo.Dictionary.join(Common.MainText, {
				TextSize = 14,
			}),
			IconPadding = 3,
			RowHeight = 20,
			Indent = 16
		}
	}
else
	return function(theme, getColor)
		local common = Common(theme, getColor)
		local treeView = TreeView(theme, getColor)

		local Default = Style.new({
			Text = Style.extend(common.MainText, {}),
			TreeView = Style.extend(treeView.Default, {}),
			Indent = 20,
			RowHeight = 24,
			Arrow = {
				Image = "rbxasset://textures/StudioSharedUI/arrowSpritesheet.png",
				Size = 12,
				ExpandedOffset = Vector2.new(24, 0),
				CollapsedOffset = Vector2.new(12, 0),
				Color = theme:GetColor("MainText")
			},
			IconPadding = 5,
			HoverColor = theme:GetColor("Button", "Hover"),
			SelectedColor = theme:GetColor("DialogMainButton"),
			SelectedTextColor = theme:GetColor("DialogMainButtonText")
		})

		local Compact = Style.extend(Default, {
			Text = Style.extend(common.MainText, {
				TextSize = 14
			}),
			IconPadding = 3,
			RowHeight = 20,
			Indent = 16
		})

		return {
			Default = Default,
			Compact = Compact
		}
	end
end
