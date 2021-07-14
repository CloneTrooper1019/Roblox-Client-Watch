-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\Badge.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)
local StoryItem = require(ReplicatedStorage.Packages.StoryComponents.StoryItem)

local Indicator = script.Parent.Parent
local App = Indicator.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)

local Badge = require(Indicator.Badge)
local Images = require(App.ImageSet.Images)
local ImageSetComponent = require(UIBlox.Core.ImageSet.ImageSetComponent)

local DarkTheme = require(Packages.UIBlox.App.Style.Themes.DarkTheme)

local BadgeStory = Roact.PureComponent:extend("BadgeStory")

function BadgeStory:init()
	self.state = {
		badgeValue = "",
	}
end

function BadgeStory:render()
	local badgeValue = self.state.badgeValue
	if tonumber(badgeValue) then
		badgeValue = tonumber(badgeValue)
	end
	if badgeValue == "" then
		badgeValue = 0
	end

	return Roact.createElement("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
	}, {
		ScrollingFrame = Roact.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(1, 0, 0, 1500),
			BackgroundTransparency = 1,
			ScrollingDirection = Enum.ScrollingDirection.Y,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),

			ValueUpdated = Roact.createElement("Frame", {
				Size = UDim2.fromOffset(200, 100),
				BackgroundTransparency = 1,
			}, {
				TextBox = Roact.createElement("TextBox", {
					Size = UDim2.fromOffset(200, 50),
					Text = tostring(self.state.badgeValue),
					TextColor3 = Color3.new(0, 0, 0),
					PlaceholderColor3 = Color3.new(0, 0, 0),
					PlaceholderText = "Enter Badge Value",

					[Roact.Change.Text] = function(rbx)
						self:setState({
							badgeValue = rbx.Text,
						})
					end,
				})
			}),

			BadgeStory = Roact.createElement(StoryItem, {
				size = UDim2.new(1, 0, 0, 200),
				layoutOrder = 2,
				title = "Badge",
				subTitle = "Indicator.Badge",
			}, {
				Icon = Roact.createElement(ImageSetComponent.Label, {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 36, 0, 36),
					Image = Images["icons/common/notificationOn"],
				}, {
					Badge = badgeValue ~= 0 and Roact.createElement(Badge, {
						position = UDim2.new(0.5, 0, 0.5, 0),
						anchorPoint = Vector2.new(0, 1),

						value = badgeValue,
					}),
				}),
			}),

			DisabledBadgeStory = Roact.createElement(StoryItem, {
				size = UDim2.new(1, 0, 0, 200),
				layoutOrder = 3,
				title = "Disabled Badge",
				subTitle = "Indicator.Badge",
			}, {
				Icon = Roact.createElement(ImageSetComponent.Label, {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 36, 0, 36),
					ImageTransparency = 0.5,
					Image = Images["icons/common/notificationOn"],
				}, {
					Badge = badgeValue ~= 0 and Roact.createElement(Badge, {
						position = UDim2.new(0.5, 0, 0.5, 0),
						anchorPoint = Vector2.new(0, 1),

						disabled = true,
						value = badgeValue,
					}),
				}),
			}),

			BadgeTileStory = Roact.createElement(StoryItem, {
				size = UDim2.new(1, 0, 0, 300),
				layoutOrder = 4,
				title = "Badge Tile",
				subTitle = "Indicator.Badge",
			}, {
				Tile = Roact.createElement("Frame", {
					Size = UDim2.fromOffset(160, 160),
					BackgroundTransparency = DarkTheme.BackgroundUIDefault.Transparency,
					BackgroundColor3 = DarkTheme.BackgroundUIDefault.Color,
				}, {
					Badge = badgeValue ~= 0 and Roact.createElement(Badge, {
						position = UDim2.new(1, -10, 0, 10),
						anchorPoint = Vector2.new(1, 0),

						value = badgeValue,
					}),
				}),
			}),

			BadgeShadowStory = Roact.createElement(StoryItem, {
				size = UDim2.new(1, 0, 0, 200),
				layoutOrder = 5,
				title = "Badge With Shadow",
				subTitle = "Indicator.Badge",
			}, {
				Background = Roact.createElement("Frame", {
					BackgroundColor3 = Color3.fromRGB(128, 187, 219),
					Size = UDim2.new(0, 200, 1, 0),
				}, {
					DropShadow = Roact.createElement(ImageSetComponent.Label, {
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = UDim2.new(0, 36, 0, 36),
						Image = Images["component_assets/dropshadow_chatOff"],
						ZIndex = 1,
					}),

					Icon = Roact.createElement(ImageSetComponent.Label, {
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = UDim2.new(0, 36, 0, 36),
						Image = Images["icons/menu/chat_off"],
						ZIndex = 2,
					}, {
						Badge = badgeValue ~= 0 and Roact.createElement(Badge, {
							position = UDim2.new(0, 24, 0.5, 0),
							anchorPoint = Vector2.new(0, 0.5),

							hasShadow = true,
							value = badgeValue,
						})
					}),
				}),
			}),
		})
	})
end

return function(target)
	local story = Roact.createElement(StoryView, {}, {
		Roact.createElement(BadgeStory)
	})
	local handle = Roact.mount(story, target, "BadgeStory")
	return function()
		Roact.unmount(handle)
	end
end