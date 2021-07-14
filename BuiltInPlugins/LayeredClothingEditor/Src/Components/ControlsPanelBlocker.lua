--[[
	This component covers the editor when the user need to select item from workspace

	Required Props:
		string Text: text to display on the cover
		callback OnFocused: function to call when the user returns focus to the editor

	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices
local UI = Framework.UI
local CaptureFocus = UI.CaptureFocus

local ControlsPanelBlocker = Roact.PureComponent:extend("ControlsPanelBlocker")

local Util = Framework.Util
local Typecheck = Util.Typecheck
Typecheck.wrap(ControlsPanelBlocker, script)

function ControlsPanelBlocker:render()
    local props = self.props
    local onFocused = props.OnFocused
    local theme = props.Stylizer
    return Roact.createElement(CaptureFocus, {
        OnFocusLost = onFocused,
    }, {
        Text = Roact.createElement("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = theme.BackgroundColor,
            BackgroundTransparency = theme.BackgroundTransparency,
            Font = theme.Font,
            TextSize = theme.TextSize,
            TextColor3 = theme.TextColor,
            Text = props.Text,
            TextWrapped = true,
        }),
    })
end

ContextServices.mapToProps(ControlsPanelBlocker,{
    Stylizer = ContextServices.Stylizer,
})

return ControlsPanelBlocker
