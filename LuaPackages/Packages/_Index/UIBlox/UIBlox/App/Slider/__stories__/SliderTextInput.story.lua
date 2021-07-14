-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\App\SliderTextInput.story.lua`
local SliderRoot = script.Parent.Parent
local App = SliderRoot.Parent
local UIBlox = App.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)

local StoryView = require(Packages.StoryComponents.StoryView)

local SliderTextInput = require(SliderRoot.SliderTextInput)

local Story = Roact.PureComponent:extend("Story")

function Story:init()
	self:setState({
		value = 10
	})
end

function Story:render()
	return Roact.createFragment({
		List = Roact.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Normal = Roact.createElement(SliderTextInput, {
			layoutOrder = 1,
			value = self.state.value,
			min = 0,
			max = 100,
			stepInterval = 10,
			onValueChanged = function(newValue)
				print(newValue)
				self:setState({
					value = newValue,
				})
			end,
		}),
		Disabled = Roact.createElement(SliderTextInput, {
			layoutOrder = 2,
			value = self.state.value,
			min = 0,
			max = 100,
			stepInterval = 10,
			disabled = true,
			onValueChanged = function(newValue)
			end,
		}),
	})
end

return function(target)
	local styleProvider = Roact.createElement(StoryView, {}, {
		Roact.createElement(Story)
	})

	local handle = Roact.mount(styleProvider, target, "SliderTextInput")
	return function()
		Roact.unmount(handle)
	end
end