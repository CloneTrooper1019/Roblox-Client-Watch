--[[
	A ContextItem that supplies a networking implementation of Roblox APIs using
	ContextServices.provide.

	Optional Props:
		table apiProps: a map of arguments to pass to a RobloxAPI object. See DevFramework.RobloxAPI docs for list of accepted props.
]]

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextItem = require(Framework.ContextServices.ContextItem)
local Provider = require(Framework.ContextServices.Provider)
local RobloxAPI = require(Framework.RobloxAPI)

local API = ContextItem:extend("API")

function API.new(apiProps)
	if apiProps then
		assert(type(apiProps) == "table", "Expected a table of props to pass to a RobloxAPI instance")
	end

	local self = {
		api = RobloxAPI.new(apiProps),
	}
	setmetatable(self, API)
	return self
end

function API:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
	}, {root})
end

function API:get()
	return self.api
end

return API
