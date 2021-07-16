local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local ContextServices = require(Framework.ContextServices)

local UI = require(Framework.UI)
local Button = UI.Button
local Pane = UI.Pane
local Decoration = UI.Decoration
local HoverArea = UI.HoverArea

local FrameworkStyle = Framework.Style
local ui = require(FrameworkStyle).ComponentSymbols

-- TODO FFlagEnableDeveloperStorybook: when retired, remove unused StudioTheme import
local FFlagEnableDeveloperStorybook = game:GetFastFlag("EnableDeveloperStorybook")
local StudioTheme = require(FrameworkStyle.Themes.StudioTheme)
local ThemeSwitcher = require(FrameworkStyle.ThemeSwitcher)

local BaseTheme = require(FrameworkStyle.Themes.BaseTheme)
local StyleModifier = require(Framework.Util.StyleModifier)
local StyleKey = require(Framework.Style.StyleKey)

local Dash = require(Framework.packages.Dash)
local join = Dash.join

local theme = FFlagEnableDeveloperStorybook and ThemeSwitcher.new() or StudioTheme.new()
theme:extend({
	[ui.Button] = join(BaseTheme[ui.Button], {
		["&Close"] = {
				Foreground = Decoration.Image,
				ForegroundStyle = {
						Image = "rbxasset://textures/ui/CloseButton.png",
				},
				[StyleModifier.Hover] = {
						ForegroundStyle = {
								Image = "rbxasset://textures/ui/CloseButton_dn.png",
						},
				},
		},
	}),

	[ui.Image] = join(BaseTheme[ui.Image], {
		["&Settings"] = {
				Image = "rbxasset://textures/AnimationEditor/btn_manage.png",
				Color = StyleKey.MainText,
				Size = UDim2.fromOffset(24, 24),
				
		},

		["&SettingsPrimary"] = {
				Color = StyleKey.DialogMainButtonText,
		},
	}),
})

local function printClicked()
	print("Clicked")
end

return {
	controls = {
		isDisabled = false,
	},
	stories = {
		-- The default Studio button
		Round = function(props)
			return ContextServices.provide({theme}, {
				Child = Roact.createElement(Button, {
					Style = "Round",
					Text = "Cancel",
					StyleModifier = props.controls.isDisabled and StyleModifier.Disabled or nil,
					Size = UDim2.fromOffset(120, 32),
					LayoutOrder = 2,
					OnClick = printClicked,
				}, {
					-- Adding a HoverArea as a child allows the cursor to change
					Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
				})
			})
		end,
		-- Subtle button
		RoundSubtle = function(props)
			return ContextServices.provide({theme}, {
				Child = Roact.createElement(Button, {
					Style = "RoundSubtle",
					Text = "Save",
					StyleModifier = props.controls.isDisabled and StyleModifier.Disabled or nil,
					Size = UDim2.fromOffset(120, 32),
					LayoutOrder = 3,
					OnClick = printClicked,
				}, {
					Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
				})
			})
		end,
		-- The default Studio primary button
		RoundPrimary = function(props)
			return ContextServices.provide({theme}, {
				Child = Roact.createElement(Button, {
					Style = "RoundPrimary",
					Text = "Save",
					StyleModifier = props.controls.isDisabled and StyleModifier.Disabled or nil,
					Size = UDim2.fromOffset(120, 32),
					LayoutOrder = 3,
					OnClick = printClicked,
				}, {
					Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
				})
			})
		end,
		-- Buttons can be made of images only, with no text
		-- Using Decorations we can handle many use cases
		CloseButton = function(props)
			return ContextServices.provide({theme}, {
				Child = Roact.createElement(Button, {
					Style = "Close",
					StyleModifier = props.controls.isDisabled and StyleModifier.Disabled or nil,
					Size = UDim2.fromOffset(22, 22),
					LayoutOrder = 1,
					OnClick = printClicked,
				})
			})
		end,
		-- If special appearance logic is needed, children will render
		-- above the button's background. Doing this, we can
		-- easily make many kinds of buttons with images inside.
		RoundPrimaryWithImage = function(props)
			return ContextServices.provide({theme}, {
				Child = Roact.createElement(Button, {
					Style = "Round",
					StyleModifier = props.controls.isDisabled and StyleModifier.Disabled or nil,
					Size = UDim2.fromOffset(24, 24),
					LayoutOrder = 3,
					OnClick = printClicked,
				}, {
					Settings = Roact.createElement(Decoration.Image, {
						Style = "Settings",
					}),
				})
			})
		end,
		-- A more complicated button which looks like a Primary
		-- Studio button but has both an image and text inside.
		RoundWithImage = function(props)
			return ContextServices.provide({theme}, {
				Child = Roact.createElement(Button, {
					Style = "RoundPrimary",
					StyleModifier = props.controls.isDisabled and StyleModifier.Disabled or nil,
					Size = UDim2.fromOffset(120, 32),
					LayoutOrder = 4,
					OnClick = printClicked,
				}, {
					Pane = Roact.createElement(Pane, {
						Layout = Enum.FillDirection.Horizontal,
						Padding = {
							Left = 10,
							Right = 5,
						},
					}, {
						Settings = Roact.createElement(Decoration.Image, {
							Style = "Settings",
							LayoutOrder = 1,
						}),

						Text = Roact.createElement("TextLabel", {
							LayoutOrder = 2,
							Text = "Settings",
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 1),
							TextXAlignment = Enum.TextXAlignment.Left,
							Font = Enum.Font.SourceSans,
							TextSize = 18,
							TextColor3 = Color3.new(1, 1, 1),
						}),
					}),
				})
			})
		end
	}
}
