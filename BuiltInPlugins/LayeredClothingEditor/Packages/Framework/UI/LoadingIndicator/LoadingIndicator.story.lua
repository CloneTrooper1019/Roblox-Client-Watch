local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local LoadingIndicator = UI.LoadingIndicator

return Roact.createElement(LoadingIndicator)
