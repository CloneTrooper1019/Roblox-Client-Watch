local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local BulletList = UI.BulletList
local LinkText = UI.LinkText
local Image = UI.Decoration.Image
local Container = UI.Container

return Roact.createElement(BulletList, {
	Items = {
		"one",
		"This indeed is a very long item for this list example that one would expect to overflow had we not wrapped it.",
		Roact.createElement(Container, {
			Size = UDim2.fromOffset(100, 100),
		}, {
			Decoration = Roact.createElement(Image, {
				Style = {
					Image = "rbxasset://textures/ui/common/robux_color@2x.png",
				},
			})
		}),
		"As you can see, arbitrary elements can be used as list items",
		Roact.createElement(LinkText, {
			OnClick = function()
				print("Link clicked!")
			end,
			Text = "And here is a link, displayed as a list element"
		})
	},
	TextWrapped = true
})
