-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\InputButton\MultiLineCheckbox.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Roact = require(Packages.Roact)
local UIBlox = require(Packages.UIBlox)
local GenericTextLabel = require(Packages.UIBlox.Core.Text.GenericTextLabel.GenericTextLabel)
local withStyle = UIBlox.Core.Style.withStyle

local StoryComponents = Packages.StoryComponents
local StoryView = require(StoryComponents.StoryView)
local StoryItem = require(StoryComponents.StoryItem)

local CheckboxList = UIBlox.App.InputButton.CheckboxList

return function(target)
	local MulitlineCheckboxDemo = Roact.PureComponent:extend("MulitlineCheckboxDemo")

	function MulitlineCheckboxDemo:render()
		return withStyle(function(style)
			return Roact.createElement(StoryView, {}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				Label = Roact.createElement(GenericTextLabel, {
					BackgroundTransparency = 1,
					Text = "This CheckboxList can have up to 3 boxes selected at a time",
					Size = UDim2.new(1, 0, 0, 50),
					LayoutOrder = 1,
					fontStyle = style.Font.Header2,
					colorStyle = style.Theme.TextDefault,
				}),
				CheckboxListFrame = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 480, 0, 300),
					LayoutOrder = 2,
				}, {
					CheckboxList = Roact.createElement(CheckboxList, {
						atMost = 3,
						checkboxes = {
							{
								label = "Selected and Disabled",
								isSelected = true,
								isDisabled = true,
							},
							{
								label = "Unselected and Disabled",
								isSelected = false,
								isDisabled = true,
							},
							{
								label = "Selected and Enabled",
								isSelected = true,
								isDisabled = false,
							},
							"Unselected and Enabled",
							"This is a checkbox that has an absurd amount of text in its label to demonstrate wrapping",
						},
						onActivated = function() end,
						elementSize = UDim2.new(0, 480, 0, 54),
						layoutOrder = 1,
					}),
				}),
			})
		end)
	end

	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		StoryItem = Roact.createElement(StoryItem, {
			title = "A demonstration of checkboxes with long labels",
			subTitle = "Shows how text can wrap when it is long",
			showDivider = true,
		}, {
			Roact.createElement(MulitlineCheckboxDemo)
		})
	}), target, "CheckboxList")
	return function()
		Roact.unmount(handle)
	end
end
