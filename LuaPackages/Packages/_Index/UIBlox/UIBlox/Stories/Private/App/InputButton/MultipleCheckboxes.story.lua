local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local CheckboxList = require(App.InputButton.CheckboxList)

local Story = Roact.Component:extend("yourComponent")
function Story:init()
	self.ref = Roact.createRef()
end

function Story:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 450),
		BackgroundColor3 = Color3.fromRGB(55, 55, 55),
	}, {
		layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		checkboxes = Roact.createElement(CheckboxList, {
			layoutOrder = 1,
			atMost = 3,
			checkboxes = {
				{
					label = "Vaporeon",
					isSelected = true,
					isDisabled = true,
				},
				"Jolteon",
				"Flareon",
				"Espeon",
				"Umbreon",
				"Leafeon",
				"Glaceon",
				"Sylveon",
			},
			onActivated = function(value)
				local values = ""
				for k, v in pairs(value) do
					if v then
						values = values .. k .. ", "
					end
				end
				if self.ref.current then
					self.ref.current.Text = "Pick at most 3. The current value is: " .. values
					print(self.ref.current.Text)
				end
			end,
			elementSize = UDim2.new(0, 480, 0, 54),
		}),
		text = Roact.createElement("TextLabel", {
			LayoutOrder = 2,
			TextSize = 14,
			Text = "Pick at most 3",
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 50),
			[Roact.Ref] = self.ref,
		}),
	})

end


return Story