--[[
	A ContextItem that abstracts tracking of Analytics.

	Each plugin is expected to provide a createEventHandlers function to the constructor
	which should return a table mapping event -> eventHandler.

	Functions:
		report(event, ...):
			Calls the event handler for this event with the varargs. Throws if event does not have a handler.

	Example:
		-- MainPlugin
		local function createEventHandlers(rbxAnalyticsService)

			return {
				myEvent = function(event, a, b)
					rbxAnalyticsService:ReportStats(event, a, b)
				end
			}
		end

		ContextServices.provide({
			Analytics.new(createEventHandlers, rbxAnalyticsService)
		})

		-- Button
		local Button = Roact.PureComponent:extend("Button")

		function Button:handleClick()

			self.props.Analytics:report("myEvent", "foo", {"bar"})
		end

		return ContextServices.withContext({
			Analytics = ContextServices.Analytics,
		})(Button)
]]

local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local Framework = script.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextItem = require(Framework.ContextServices.ContextItem)
local Provider = require(Framework.ContextServices.Provider)
local t = require(Framework.Util.Typecheck.t)

local Analytics = ContextItem:extend("Analytics")

function Analytics.new(createEventHandlers, rbxAnalyticsService)
	assert(t.callback(createEventHandlers), "createEventHandlers must be a function")
	rbxAnalyticsService = rbxAnalyticsService or RbxAnalyticsService

	local self = {
		eventHandlers = createEventHandlers(rbxAnalyticsService)
	}

	assert(t.map(t.string, t.callback)(self.eventHandlers), "createEventHandlers must return a table mapping strings to functions")

	setmetatable(self, Analytics)
	return self
end

function Analytics:createProvider(root)
	return Roact.createElement(Provider, {
		ContextItem = self,
	}, {root})
end

function Analytics:report(event, ...)
	assert(t.string(event), "event must be a string")
	local handler = self:getHandler(event)
	assert(handler, "No event handler is registered for " .. event)
	handler(event, ...)
end

function Analytics:getHandler(event)
	return self.eventHandlers[event]
end

function Analytics.mock()
	local mock = Analytics.new(function()
		return {}
	end, {})
	mock.getHandler = function()
		return function()
		end
	end
	return mock
end

return Analytics
