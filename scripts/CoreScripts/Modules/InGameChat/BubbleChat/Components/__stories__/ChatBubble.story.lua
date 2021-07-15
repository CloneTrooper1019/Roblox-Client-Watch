local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Packages.Roact)

local Helpers = script.Parent.Parent.Parent.Helpers
local Actions = script.Parent.Parent.Parent.Actions
local createMockMessage = require(Helpers.createMockMessage)
local ChatBubble = require(script.Parent.Parent.ChatBubble)

local StoryStore = require(Helpers.StoryStore)
local AddMessage = require(Actions.AddMessage)
local RemoveMessage = require(Actions.RemoveMessage)

return function(props)
	local state = StoryStore:getState()
	for _, message in pairs(state.messages) do
		StoryStore:dispatch(RemoveMessage(message))
	end

	local messages = {
		createMockMessage({
			text = "Hello World!"
		}),
		createMockMessage({
			text = "Testing length to see what happens when it spills to the second line"
		}),
		createMockMessage({
			text = "Quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo " ..
				"consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu" ..
				"fugiat nulla pariatur"
		}),
	}

	local children = {}
	for _, msg in ipairs(messages) do
		StoryStore:dispatch(AddMessage(msg))
		children[msg.id] = Roact.createElement(ChatBubble, {
			messageId = msg.id,
			chatSettings = props.chatSettings,
		})
	end
	
	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.Name,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 16),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
	})

	children.Padding = Roact.createElement("UIPadding", {
		PaddingTop = UDim.new(0, props.chatSettings.Padding),
		PaddingRight = UDim.new(0, props.chatSettings.Padding),
		PaddingBottom = UDim.new(0, props.chatSettings.Padding),
		PaddingLeft = UDim.new(0, props.chatSettings.Padding),
	})
	
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, children)
end
