local GET = require(script.Parent.GET)
local POST = require(script.Parent.POST)

local RoduxNetworking = {}
RoduxNetworking.__index = RoduxNetworking

function RoduxNetworking.new(options)
	assert(options, "Expected options to be passed into RoduxNetworking")
	assert(options.keyPath, "Expected options.keyPath to be passed into RoduxNetworking")
	assert(options.networkImpl, "Expected options.networkImpl to be passed into RoduxNetworking")

	local self = {
		options = options,
	}

	return setmetatable(self, RoduxNetworking)
end

function RoduxNetworking:GET(moduleScript, constructBuilderFunction)
	assert(moduleScript, "RoduxNetworking:GET expects moduleScript argument")
	assert(moduleScript, "RoduxNetworking:GET expects constructBuilderFunction argument")
	return GET(self.options)(moduleScript, constructBuilderFunction)
end

function RoduxNetworking:POST(...)
	return POST(self.options)(...)
end

function RoduxNetworking:getNetworkImpl()
	return self.options.networkImpl
end

function RoduxNetworking:setNetworkImpl(networkImpl)
	self.options.networkImpl = networkImpl
end

return RoduxNetworking