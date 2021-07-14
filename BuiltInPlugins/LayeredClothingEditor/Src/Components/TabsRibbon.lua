--[[
	Shows a button ribbon which uses the SwitchButton

	Required Props:
		table Buttons = A list of buttons to display. Example: { Key = "", Text = "", IsEnabled = "", Image = "" }.

	Optional Props:
		Stylizer Stylizer: A Stylizer ContextItem, which is provided via mapToProps.
		number LayoutOrder = render order of component in layout
		number ZIndex = the z sorting order of the component
		callback OnClick = parameters(string key) function to call when a button is clicked
		string SelectedKey = which button is in the selected state
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Packages.Roact)

local Framework = require(Plugin.Packages.Framework)
local ContextServices = Framework.ContextServices

local Pane = Framework.UI.Pane

local SwitchButton = require(Plugin.Src.Components.SwitchButton)

local TabsRibbon = Roact.PureComponent:extend("TabsRibbon")

local function renderButton(self, button)
	local props = self.props
	local zIndex = props.ZIndex or 1
	local onClick = props.OnClick
	local selectedKey = props.SelectedKey

	return Roact.createElement(SwitchButton, {
		OnClick = function()
			if onClick and button.IsEnabled then
				onClick(button.Key)
			end
		end,
		IsEnabled = button.IsEnabled,
		IsOn = (selectedKey == button.Key),
		Text = button.Text,
		ZIndex = zIndex,
		Size = UDim2.new(1, 0, 1, 0),
		Image = button.Image
	})
end

function TabsRibbon:render()
	local props = self.props
	local theme = props.Stylizer
	local layoutOrder = props.LayoutOrder or 1
	local zIndex = props.ZIndex or 1
	local buttons = props.Buttons

	local children = {}

	local numButtons = 0
	for _ in pairs(buttons) do
		numButtons = numButtons + 1
	end

	for layoutOrder, button in pairs(buttons) do
		children[tostring(layoutOrder) .. " " .. tostring(button.Key)] = Roact.createElement("Frame", {
			Size = UDim2.new(1/numButtons, 0, 0, theme.Height),
			LayoutOrder = layoutOrder,
			Transparency = 1,
		}, {
			renderButton(self, button)
		})
	end

	return Roact.createElement(Pane, {
		BackgroundColor3 = theme.BackgroundColor,
		Size = UDim2.new(1, 0, 0, theme.Height),
		LayoutOrder = layoutOrder,
		ZIndex = zIndex,
		Layout = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
	}, children)
end

ContextServices.mapToProps(TabsRibbon,{
	Stylizer = ContextServices.Stylizer,
})

return TabsRibbon