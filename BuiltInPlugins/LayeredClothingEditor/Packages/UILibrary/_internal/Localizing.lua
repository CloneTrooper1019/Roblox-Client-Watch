--[[
	A utility for elements that require text to be localized and display translated
	strings.

	When initializing LocalizationProvider, it expects a Localization object, an example being
	src/Studio/Localization.lua where there is two tables for development strings and translated
	strings. withLocalization is mainly used to render elements with the localized strings using
	the localization object passed into LocalizationProvider
]]

local Library = script.Parent

local Roact = require(Library.Parent.Parent.Roact)
local Symbol = require(Library.Utils.Symbol)


local localizationKey = Symbol.named("Localization")

--[[
	Inserted near the top of the Roact tree, this stores the localization object into _context

	Props:
		localization : (Localization) an object that can provide localized strings, preferrably a Localization object
]]
local LocalizationProvider = Roact.PureComponent:extend("LocalizationProvider")

function LocalizationProvider:init()
	assert(self.props.localization ~= nil, "LocalizationProvider expects a Localization object")
	local localization = self.props.localization

	self._context[localizationKey] = localization
end

function LocalizationProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end


--[[
	Never explicitly created by the user, it exposes the localization object from context.
	This should only ever be created by a call to withLocalization().

	Props:
		localizedRender : (function<Roact Element>(Localization localization))
			a callback used to render children while exposing the Localization object stored in _context
]]
local LocalizationConsumer = Roact.PureComponent:extend("LocalizationConsumer")

function LocalizationConsumer:init()
	assert(type(self.props.localizedRender) == "function", "LocalizationConsumer expected to be created with withLocale()")
	assert(self._context[localizationKey] ~= nil, "LocalizationConsumer expects a LocalizationProvider in the Roact tree")

	self.localization = self._context[localizationKey]
	self.state = {
		-- keep a simple string of the table reference so we have something to call setstate on later
		localization = tostring(self.localization.translator)
	}

	self.lcToken = self.localization.localeChanged:connect(function(newLocale)
		-- force trigger a re-render of children
		self:setState({
			localization = tostring(newLocale)
		})
	end)
end

function LocalizationConsumer:render()
	return self.props.localizedRender(self.localization)
end

function LocalizationConsumer:willUnmount()
	if self.lcToken then
		self.lcToken:disconnect()
		self.lcToken = nil
	end
end

--[[
	callback : function<Roact Element>(Localization localization)
		a callback used to render children while exposing the localization stored in _context
]]
local function withLocalization(callback)
	assert(type(callback) == "function", "withLocalization expects a function")
	return Roact.createElement(LocalizationConsumer, {
		localizedRender = callback
	})
end

local function getLocalization(component)
	return component._context[localizationKey]
end

return {
	Provider = LocalizationProvider,
	Consumer = LocalizationConsumer,
	withLocalization = withLocalization,
	getLocalization = getLocalization,
}
