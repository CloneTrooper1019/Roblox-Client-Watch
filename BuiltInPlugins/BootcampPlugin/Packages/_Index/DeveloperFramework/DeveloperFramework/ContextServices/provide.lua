--[[
	Provides the given list of ContextItems to the list of children.

	NOTE:
	Items will be provided in the order of the ContextItems parameter.
	This means that if one ContextItem relies on a previous item, it should
	be put in the ContextItems list AFTER the item it relies on.

	Params:
		list<ContextItem> ContextItems = A list of ContextItems to provide to the plugin.
		list<Component> Children = The children to render with the given context.

	Example:
		local Localization = ContextServices.Localization
		local Theme = ContextServices.Theme

		local localization = Localization.new(...)
		local theme = Theme.new(...)

		function MyPlugin:render()
			return ContextServices.provide({
				localization, theme,
			}, {
				MyRootComponent = Roact.createElement(MyRootComponent),
			})
		end
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local MultipleProvider = Roact.PureComponent:extend("MultipleProvider")

function MultipleProvider:render()
	local props = self.props
	local items = props.ContextItems

	local children = props[Roact.Children]
	local root = Roact.createFragment(children)

	for index = #items, 1, -1 do
		local item = items[index]

		if item then
			local createProvider = item.createProvider
			assert(createProvider and type(createProvider) == "function",
				string.format("provide: item at %i was not a ContextItem.", index))
			root = item:createProvider(root)
		end
	end

	return root
end

local function provide(contextItems, children)
	assert(contextItems, "provide: Expected a ContextItems list to provide.")
	assert(children, "provide: Expected a table of children.")

	return Roact.createElement(MultipleProvider, {
		ContextItems = contextItems,
	}, children)
end

return provide
