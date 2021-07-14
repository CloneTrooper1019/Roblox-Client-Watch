local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local FitFrame = require(Packages.FitFrame)
local FitTextLabel = FitFrame.FitTextLabel
local withStyle = require(Packages.UIBlox.Style.withStyle)

local App = Packages.UIBlox.App
local RootHeaderBar = require(App.Bar.HeaderBar)
local IconButton = require(App.Button.IconButton)
local Images = require(App.ImageSet.Images)

local function RootHeaderBarDemo(props)
	local barHeight = 64

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(375, barHeight),
		LayoutOrder = props.LayoutOrder,
	}, {
		demo = Roact.createElement(RootHeaderBar, {
			backgroundTransparency = props.backgroundTransparency,
			title = props.title,
			barHeight = barHeight,
			renderRight = props.renderRight,
		}),
	})
end

return {
	name = "Root Header Bar: Overview",
	summary = table.concat({
		"The Root Header Bar is only used on main navigation pages.",
		"",
		"Currently this includes Home, Discover, Avatar, Chat, and More."
	}, "\n"),
	stories = {
		homeDemo = Roact.createElement(RootHeaderBarDemo, {
			LayoutOrder = 1,
			title = "Home",
			renderRight = function()
				return Roact.createFragment({
					search = Roact.createElement(IconButton, {
						icon = Images["icons/common/search"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 1,
					}),
					robux = Roact.createElement(IconButton, {
						icon = Images["icons/common/goldrobux"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 2,
					}),
					notification = Roact.createElement(IconButton, {
						icon = Images["icons/common/notificationOff"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 3,
					}),
				})
			end,
		}),
		discoverDemo = Roact.createElement(RootHeaderBarDemo, {
			LayoutOrder = 2,
			title = "Discover",
			renderRight = function()
				return Roact.createFragment({
					search = Roact.createElement(IconButton, {
						icon = Images["icons/common/search"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 1,
					}),
					robux = Roact.createElement(IconButton, {
						icon = Images["icons/common/goldrobux"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 2,
					}),
					notification = Roact.createElement(IconButton, {
						icon = Images["icons/common/notificationOff"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 3,
					}),
				})
			end,
		}),
		avatarDemo = Roact.createElement(RootHeaderBarDemo, {
			LayoutOrder = 3,
			title = "Avatar",
			backgroundTransparency = 1,
			renderRight = function()
				return withStyle(function(style)
					local theme = style.Theme
					local font = style.Font

					return Roact.createFragment({
						sampleRobuxBalance = Roact.createElement(FitTextLabel, {
							width = FitTextLabel.Width.FitToText,
							Text = "Robux: 99,999",
							BackgroundColor3 = theme.UIDefault.Color,
							BackgroundTransparency = theme.UIDefault.Transparency,
							TextColor3 = theme.TextEmphasis.Color,
							TextTransparency = theme.TextEmphasis.Transparency,
							Font = font.Body.Font,
							TextSize = font.Body.RelativeSize * font.BaseSize,
						})
					})
				end)
			end,
		}),
		chatDemo = Roact.createElement(RootHeaderBarDemo, {
			LayoutOrder = 4,
			title = "Chat",
			renderRight = function()
				return Roact.createFragment({
					search = Roact.createElement(IconButton, {
						icon = Images["icons/common/search"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 1,
					}),
					compose = Roact.createElement(IconButton, {
						icon = Images["icons/actions/compose"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 2,
					}),
					notification = Roact.createElement(IconButton, {
						icon = Images["icons/common/notificationOff"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 3,
					}),
				})
			end,
		}),
		moreDemo = Roact.createElement(RootHeaderBarDemo, {
			LayoutOrder = 5,
			title = "More",
			renderRight = function()
				return Roact.createFragment({
					robux = Roact.createElement(IconButton, {
						icon = Images["icons/common/goldrobux"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 1,
					}),
					notification = Roact.createElement(IconButton, {
						icon = Images["icons/common/notificationOff"],
						size = UDim2.new(0, 0, 0, 0),
						layoutOrder = 2,
					}),
				})
			end,
		}),
	}
}
