local Framework = script.Parent.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)
local Plugin = ContextServices.Plugin
local Localization = ContextServices.Localization

local Label = require(script.Parent.Label)

local stringResourceTable = script.Parent.DevelopmentReferenceTable
local translationResourceTable = script.Parent.TranslationReferenceTable

local pluginItem = Plugin.new(plugin)
local localization = Localization.new({
	stringResourceTable = stringResourceTable,
	translationResourceTable = translationResourceTable,
	pluginName = "Framework",
})

return ContextServices.provide({pluginItem, localization}, {
	Label = Roact.createElement(Label, {
		Name = "ZeroIndex",
	})
})
