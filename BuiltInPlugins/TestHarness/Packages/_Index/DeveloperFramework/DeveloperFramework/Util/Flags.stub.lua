--!nolint UnknownRequire
local Framework = script.Parent.Parent

local Dash = require(Framework.packages.Dash)
local join = Dash.join

local Flags = require(script.Parent.Flags_stubbed :: any)

local constructor = Flags.new

function Flags.new(featuresMap, config)
	return constructor(featuresMap, join(config, {
		shouldFetchLiveValues = false
	}))
end

return Flags
