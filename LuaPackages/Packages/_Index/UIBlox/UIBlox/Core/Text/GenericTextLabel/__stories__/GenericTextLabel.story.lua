-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\Core\Text\GenericTextLabel.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local GenericTextLabelRoot = script.Parent.Parent
local Text = GenericTextLabelRoot.Parent
local Core = Text.Parent
local UIBlox = Core.Parent
local Packages = UIBlox.Parent

local withStyle = require(UIBlox.Core.Style.withStyle)

local Roact = require(Packages.Roact)

local GenericTextLabel = require(GenericTextLabelRoot.GenericTextLabel)

local GenericTextLabelStory = Roact.PureComponent:extend("GenericTextLabelStory")

function GenericTextLabelStory:render()
	return withStyle(function(style)
		local theme = style.Theme
		local font = style.Font
		return Roact.createElement(StoryItem, {
			size = UDim2.new(0, 300, 0, 128),
			layoutOrder = 1,
			title = "Generic Text Label",
			subTitle = "Text.GenericTextLabel",
			showDivider = true,
		}, {
			GenericTextLabel = Roact.createElement(GenericTextLabel, {
				Text = "Phantom Forces [Sniper Update!]",
				Size = UDim2.new(0, 150, 0, 45),
				colorStyle = theme.SystemPrimaryDefault,
				fontStyle = font.Header1,
				fluidSizing = true,
			}),
		})
	end)
end

return function(target)
	local styleProvider = Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(GenericTextLabelStory),
	})

	local handle = Roact.mount(styleProvider, target, "GenericTextLabel")
	return function()
		Roact.unmount(handle)
	end
end