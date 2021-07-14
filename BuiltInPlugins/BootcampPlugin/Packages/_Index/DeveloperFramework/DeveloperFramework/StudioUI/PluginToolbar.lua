--[[
	A Roact wrapper for a PluginToolbar instance.
	Used to display a toolbar column in the Plugins tab.

	Required Props:
		string Title: The text which displays below the toolbar.
		callback RenderButtons: A function for rendering
			the PluginButtons under this toolbar. Passes the toolbar itself
			as a parameter to be used as the button parent.
		Plugin Plugin: A Plugin ContextItem, which is provided via mapToProps.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Typecheck = require(Framework.Util).Typecheck

local PluginToolbar = Roact.PureComponent:extend("PluginToolbar")
Typecheck.wrap(PluginToolbar, script)

function PluginToolbar:createToolbar()
	local props = self.props
	local plugin = props.Plugin:get()
	local title = props.Title

	assert(typeof(title) == "string", string.format("PluginToolbar requires Title to be of type string not %s", typeof(title)))
	self.toolbar = plugin:CreateToolbar(title)
end

function PluginToolbar:render()
	if not self.toolbar then
		self:createToolbar()
	end

	local props = self.props
	local renderButtons = props.RenderButtons

	local children = renderButtons(self.toolbar)
	if children then
		return Roact.createFragment(children)
	end

	return nil
end

function PluginToolbar:willUnmount()
	if self.toolbar then
		self.toolbar:Destroy()
	end
end

ContextServices.mapToProps(PluginToolbar, {
	Plugin = ContextServices.Plugin,
})

return PluginToolbar
