--[[
	A collection of Styles.
	Used to help scope the creation of Style tables.

	Example:
		local boxDecoration = StyleTable.new("BoxDecoration", function()
			local Default = Style.new({
				Color = getColor("Background"),
				Transparency = 0,
				BorderSize = 0,
			})

			return {
				Default = Default,
			}
		end)

	StyleTable.extend can be used to merge the styles of two sets of StyleTables.
	This allows you to add new styles to components that have StyleTables.
	Example:
		local studioFrameworkStyles = StudioFrameworkStyles.new(theme, getColor)
		local Framework = StyleTable.extend(studioFrameworkStyles, myFrameworkStyles)
]]

local noParentError = [[
StyleTable.extend: The StyleTable for '%s' has no entry in the parent StyleTable.
extend is used to add entries to existing StyleTables, not to define new StyleTables.
There may be a typo in '%s' or a missing entry in FrameworkStyles.new.

If you're making a new styled component and are seeing this after adding a StudioFrameworkStyles
entry for it, you need to add an entry for it in FrameworkStyles also.]]

local Framework = script.Parent.Parent
local Immutable = require(Framework.Util.Immutable)

local StyleTable = {}
function StyleTable.new(name, createFunc)
	assert(name, "StyleTable.new expects a 'name' parameter")
	assert(createFunc, "StyleTable.new expects a 'createFunc' parameter")

	return createFunc(name)
end

function StyleTable.extend(parent, child)
	local newStyle = {}

	for component, _ in pairs(child) do
		assert(parent[component], string.format(noParentError, component, component))
	end

	for component, _ in pairs(parent) do
		if child[component] then
			newStyle[component] = Immutable.JoinDictionaries(parent[component], child[component])
		else
			newStyle[component] = parent[component]
		end
	end

	return newStyle
end

return StyleTable
