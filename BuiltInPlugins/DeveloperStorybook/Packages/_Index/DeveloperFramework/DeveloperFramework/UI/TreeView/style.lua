local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local UI = require(Framework.UI)
local Decoration = UI.Decoration
local Style = Util.Style
local UIFolderData = require(Framework.UI.UIFolderData)
local ScrollingFrame = require(UIFolderData.ScrollingFrame.style)
local RoundBox = require(UIFolderData.RoundBox.style)

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	return {
		Background = Decoration.RoundBox,
		BackgroundStyle = RoundBox,
		ScrollingFrame = ScrollingFrame,
		Padding = 1
	}
else
	return function(theme, getColor)
		local roundBox = RoundBox(theme, getColor)
		local scrollingFrame = ScrollingFrame(theme, getColor)

		local Default = Style.new({
			Background = Decoration.RoundBox,
			BackgroundStyle = roundBox.Default,
			ScrollingFrame = Style.extend(scrollingFrame.Default, {}),
			Padding = 1
		})

		return {
			Default = Default,
		}
	end
end
