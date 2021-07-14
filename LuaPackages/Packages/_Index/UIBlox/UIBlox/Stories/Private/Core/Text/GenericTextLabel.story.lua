local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local Core = Packages.UIBlox.Core
local withStyle = require(Core.Style.withStyle)
local GenericTextLabel = require(Core.Text.GenericTextLabel.GenericTextLabel)

local GenericTextLabelStory = Roact.PureComponent:extend("GenericTextLabelStory")

function GenericTextLabelStory:render()
	return withStyle(function(style)
		local theme = style.Theme
		local font = style.Font
		return Roact.createElement(GenericTextLabel, {
			Text = "Phantom Forces [Sniper Update!]",
			Size = UDim2.new(0, 150, 0, 45),
			colorStyle = theme.SystemPrimaryDefault,
			fontStyle = font.Header1,
			fluidSizing = true,
		})
	end)
end

return GenericTextLabelStory