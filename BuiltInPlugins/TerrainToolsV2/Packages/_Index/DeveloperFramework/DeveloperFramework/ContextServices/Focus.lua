--[[
	A utility for elements that need to display on top of all other elements,
	and elements that need to capture focus and block input to all other elements.
	Uses Portals to place elements in the main PluginGui.
	The Focus constructor expects a LayerCollector (PluginGui, ScreenGui, etc).

	NOTE: If you use DockWidget/Dialog from the DeveloperFramework, you do not
	have to manually create or provide a Focus.

	Functions:
		getTarget():
			Returns the top-level LayerCollector above the current component.
]]
local Framework = script.Parent.Parent
local Util = require(Framework.Util)
local FlagsList = Util.Flags.new({
	FFlagRefactorDevFrameworkContextItems = {"RefactorDevFrameworkContextItems"},
})

if FlagsList:get("FFlagRefactorDevFrameworkContextItems") then
	local ContextItem = require(Framework.ContextServices.ContextItem)
	local verifyNewItem = function(target)
		assert(target and target:IsA("LayerCollector"),
			"Focus.new: Expected a LayerCollector as the target.")
	end
	return ContextItem:createSimple("Focus", { verifyNewItem = verifyNewItem })
else
	local Roact = require(Framework.Parent.Roact)
	local ContextItem = require(Framework.ContextServices.ContextItem)
	local Provider = require(Framework.ContextServices.Provider)

	local Focus = ContextItem:extend("Focus")

	function Focus.new(target)
		assert(target and target:IsA("LayerCollector"),
			"Focus.new: Expected a LayerCollector as the target.")

		local self = {
			target = target,
		}

		setmetatable(self, Focus)
		return self
	end

	function Focus:createProvider(root)
		return Roact.createElement(Provider, {
			ContextItem = self,
		}, {root})
	end

	function Focus:getTarget()
		return self.target
	end

	return Focus
end