local Plugin = script.Parent.Parent.Parent
local FFlagRemoveUILibraryFromToolbox = require(Plugin.Core.Util.getFFlagRemoveUILibraryFromToolbox)()

local Roact = require(Plugin.Libs.Roact)
local UILibrary = require(Plugin.Libs.UILibrary)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local UILibraryProvider = Roact.PureComponent:extend("UILibraryProvider")

if FFlagRemoveUILibraryFromToolbox then
	return nil
end
function UILibraryProvider:render()
	-- since the plugin is handling all the changed signals from Studio, ensure that values are updated
	--  by wrapping UILibraryWrapper in a withTheme. This will ensure re-renders are passed down the chain.
	return ContextHelper.withTheme(function(_)
		local plugin = self.props.plugin
		local focusGui = self.props.focusGui

		-- Toolbox doesn't expose the updated UILibrary theme values in a withTheme. So just grab it from props instead.
		local theme = self.props.theme:getUILibraryTheme()

		return Roact.createElement(UILibrary.Wrapper, {
			plugin = plugin,
			focusGui = focusGui,
			theme = theme,
		},{
			Roact.oneChild(self.props[Roact.Children])
		})
	end)
end

return UILibraryProvider