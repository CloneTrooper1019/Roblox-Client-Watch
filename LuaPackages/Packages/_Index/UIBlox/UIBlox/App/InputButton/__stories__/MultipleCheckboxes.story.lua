-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\InputButton\MultipleCheckboxes.story.lua`

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = script.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)
local CheckboxList = require(script.Parent.Parent.CheckboxList)

local StoryView = require(ReplicatedStorage.Packages.StoryComponents.StoryView)

local yourComponent = Roact.Component:extend("yourComponent")
function yourComponent:init()
	self.ref = Roact.createRef()
end

function yourComponent:render()

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, -50),
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


return function(target)
	local handle = Roact.mount(Roact.createElement(StoryView, {}, {
		Story = Roact.createElement(yourComponent),
	}), target, "MultipleCheckboxes")
	return function()
		Roact.unmount(handle)
	end
end
