--[[
	This stubs the DocParser which accesses the plugin-only Source property on ModuleScripts.
]]
local DocParser = require(script.Parent.DocParser_stubbed :: any)

function DocParser:parse()
	return {
		Required = {},
		Optional = {},
		Style = {},
		Summary = self.name,
	}
end

return DocParser
