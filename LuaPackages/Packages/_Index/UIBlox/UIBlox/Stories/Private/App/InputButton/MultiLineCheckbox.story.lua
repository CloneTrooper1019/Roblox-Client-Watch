local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local Core = Packages.UIBlox.Core
local withStyle = require(Core.Style.withStyle)

local App = Packages.UIBlox.App
local CheckboxList = require(App.InputButton.CheckboxList)

local MulitlineCheckboxDemo = Roact.PureComponent:extend("MulitlineCheckboxDemo")

function MulitlineCheckboxDemo:render()
	return withStyle(function(style)
		return Roact.createElement(CheckboxList, {
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
			elementSize = UDim2.new(0, 400, 0, 60),
			layoutOrder = 1,
		})
	end)
end

return {
	summary = "This CheckboxList can have up to 3 boxes selected at a time",
	story = MulitlineCheckboxDemo,
}
