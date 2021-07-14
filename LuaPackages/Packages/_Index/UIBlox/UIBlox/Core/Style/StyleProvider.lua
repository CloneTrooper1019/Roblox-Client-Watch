local Style = script.Parent
local Core = Style.Parent
local UIBlox = Core.Parent

--Note: remove along with styleRefactorConfig
local UIBloxConfig = require(UIBlox.UIBloxConfig)
local styleRefactorConfig = UIBloxConfig.styleRefactorConfig

if not styleRefactorConfig then
	return require(UIBlox.Style.StyleProvider)
end
---

local Packages = UIBlox.Parent
local Roact = require(Packages.Roact)
local t = require(Packages.t)

local StyleContext = require(Style.StyleContext)

local StyleProvider = Roact.Component:extend("StyleProvider")

StyleProvider.validateProps = t.strictInterface({
	-- The current style of the app.
	style = t.table,
	[Roact.Children] = t.table,
})

function StyleProvider:render()
	return Roact.createElement(StyleContext.Provider, {
		value = self.props.style,
	}, Roact.oneChild(self.props[Roact.Children]))
end

return StyleProvider