local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.InGameMenuDependencies)
local t = InGameMenuDependencies.t
local Roact = InGameMenuDependencies.Roact

local InGameMenu = script.Parent.Parent.Parent
local GameIcon = require(InGameMenu.Components.GameIcon)

local FFlagInGameMenuGameIconUseRoundedCorner = game:DefineFastFlag("InGameMenuGameIconUseRoundedCorner", false)

local CORNER_RADIUS = UDim.new(0, 8)

local GameIconButton = Roact.PureComponent:extend("GameIconButton")

GameIconButton.validateProps = t.strictInterface({
	anchorPoint = t.optional(t.Vector2),
	position = t.optional(t.UDim2),
	layoutOrder = t.optional(t.integer),
	onActivated = t.callback,
})

function GameIconButton:render()
	return Roact.createElement("TextButton", {
		Text = "",
		AnchorPoint = self.props.anchorPoint,
		BackgroundTransparency = 1,
		Position = self.props.position,
		Size = UDim2.fromOffset(32, 32),
		LayoutOrder = self.props.layoutOrder,
		[Roact.Event.Activated] = self.props.onActivated,
	}, {
		GameIconButton = Roact.createElement(GameIcon, {
			gameId = game.GameId,
			iconSize = 32,
			cornerRadius = FFlagInGameMenuGameIconUseRoundedCorner and CORNER_RADIUS or nil,
		})
	})
end

return GameIconButton
