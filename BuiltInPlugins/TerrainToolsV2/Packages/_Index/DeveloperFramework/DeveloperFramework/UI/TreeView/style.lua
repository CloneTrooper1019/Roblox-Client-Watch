local Framework = script.Parent.Parent.Parent

local Util = require(Framework.Util)
local UI = require(Framework.UI)
local Decoration = UI.Decoration
local Style = Util.Style
local UIFolderData = require(Framework.UI.UIFolderData)
local ScrollingFrame = require(UIFolderData.ScrollingFrame.style)
local RoundBox = require(UIFolderData.RoundBox.style)

local FFlagDevFrameworkTreeViewRow = game:GetFastFlag("DevFrameworkTreeViewRow")

local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

if THEME_REFACTOR then
	if FFlagDevFrameworkTreeViewRow then
		return {
			Padding = 2
		}
	else
		return {
			Background = Decoration.RoundBox,
			BackgroundStyle = RoundBox,
			ScrollingFrame = ScrollingFrame,
			Padding = 1
		}
	end
else
	return function(theme, getColor)
		local roundBox = RoundBox(theme, getColor)
		local scrollingFrame = ScrollingFrame(theme, getColor)

		local Default

		if FFlagDevFrameworkTreeViewRow then
			Default = Style.new({
				Padding = 2
			})
		else
			Default = Style.new({
				Background = Decoration.RoundBox,
				BackgroundStyle = roundBox.Default,
				ScrollingFrame = Style.extend(scrollingFrame.Default, {}),
				Padding = 1
			})
		end

		return {
			Default = Default,
		}
	end
end
