local RoduxNetworking = require(script.RoduxNetworking)
local NetworkStatus = require(script.NetworkStatus)
local mockRoduxNetworking = require(script.mockRoduxNetworking)

return {
	config = function(options)
		local roduxNetworkingInstance = RoduxNetworking.new(options)
		local networkStatusInstance = NetworkStatus(options)

		return {
			GET = function(...)
				return roduxNetworkingInstance:GET(...)
			end,
			POST = function(...)
				return roduxNetworkingInstance:POST(...)
			end,
			getNetworkImpl = function()
				return roduxNetworkingInstance:getNetworkImpl()
			end,
			setNetworkImpl = function(...)
				roduxNetworkingInstance:setNetworkImpl(...)
			end,

			installReducer = networkStatusInstance.installReducer,
			Enum = {
				NetworkStatus = networkStatusInstance.Enum.Status,
			},
		}
	end,

	mock = mockRoduxNetworking,
}
