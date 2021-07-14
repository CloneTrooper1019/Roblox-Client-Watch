local root = script.Parent
local makeActionCreator = require(root.makeActionCreator)
local RequestBuilder = require(root.RequestBuilder)
local NetworkStatus = require(root.NetworkStatus)
local Promise = require(root.Promise)

return function(options, methodType)
	local keyPath = options.keyPath

	local myNetworkStatus = NetworkStatus({
		keyPath = keyPath,
	})

	return function(moduleScript, constructBuilderFunction)
		local self = makeActionCreator(moduleScript)
		local mockNetworkImpl = nil

		local mockResolver = function(mockResponse, options)
			if options.mockNetworkImpl then
				error("Request already mocked - you may need to call `Mock.clear` between tests/uses")
			end

			if type(mockResponse) ~= "function" and type(mockResponse) ~= options.defaultType then
				error(options.argumentName .. " must be a " .. options.defaultType .. " or function")
			end

			mockNetworkImpl = function(...)
				local response = type(mockResponse) == "function" and mockResponse(...) or mockResponse

				return Promise[options.defaultResolveMethod](response)
			end
		end

		self.API = function(...)
			local userRequestBuilder = constructBuilderFunction(function(...)
				return RequestBuilder:new(...)
			end, ...)

			return function(store)
				return myNetworkStatus.setStatus(store, userRequestBuilder:getIds(), userRequestBuilder:makeKeyMapper(), function(store, filteredIds)
					local networkImpl = mockNetworkImpl or options.networkImpl
					local requestOptions = userRequestBuilder:makeOptions()
					local namedIds = userRequestBuilder:getNamedIds()

					return networkImpl(userRequestBuilder:makeUrl(filteredIds), methodType, requestOptions):andThen(
						function(payload)
							store:dispatch(self.Succeeded(filteredIds, payload.responseBody, namedIds, requestOptions))
							return payload
						end,
						function(errorString)
							store:dispatch(self.Failed(filteredIds, errorString, namedIds, requestOptions))
							-- Throw again so we can catch it outside of library
							return Promise.reject(errorString)
						end
					)
				end)
			end
		end

		self.getStatus = (methodType == "GET") and function(state, key)
			local userRequestBuilder = constructBuilderFunction(function(...)
				return RequestBuilder:new(...)
			end, key)

			local keymapper = userRequestBuilder:makeKeyMapper()
			local mappedKey = keymapper(key)

			return myNetworkStatus.getStatus(state, mappedKey)
		end

		self.Mock = {
			reply = function(mockResponse)
				return mockResolver(mockResponse, {
					defaultResolveMethod = "resolve",
					argumentName = "mockResponse",
					defaultType = "table",
					mockNetworkImpl = mockNetworkImpl,
				})
			end,

			replyWithError = function(mockError)
				return mockResolver(mockError, {
					defaultResolveMethod = "reject",
					argumentName = "mockError",
					defaultType = "string",
					mockNetworkImpl = mockNetworkImpl,
				})
			end,

			clear = function()
				mockNetworkImpl = nil
			end,
		}

		return self
	end
end
