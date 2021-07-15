local CorePackages = game:GetService("CorePackages")

local Cryo = require(CorePackages.Packages.Cryo)
local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)

local AddMessage = require(script.Parent.Parent.Parent.Actions.AddMessage)
local chatReducer = require(script.Parent.Parent.Parent.Reducers.chatReducer)
local createMockMessage = require(script.Parent.Parent.Parent.Helpers.createMockMessage)
local BubbleChatList = require(script.Parent.Parent.BubbleChatList)

local USER_ID = "1"

local MESSAGES = {
	"Hello World",
	"How are you today?",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec quis.",
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque eu mollis felis, ac molestie tellus. Morbi non auctor lorem, eget.",
}

local Story = Roact.Component:extend("Story")

function Story:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 16),
		}),

		Button = Roact.createElement("TextButton", {
			LayoutOrder = 1,
			Text = "Add message",
			Size = UDim2.fromOffset(200, 80),
			[Roact.Event.Activated] = self.props.addMessage
		}),

		Container = Roact.createElement("Frame", {
			LayoutOrder = 2,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 300, 1, 0),
		}, {
			BubbleChatList = Roact.createElement(BubbleChatList, {
				userId = USER_ID,
				chatSettings = self.props.chatSettings,
			}),
		}),
	})
end

local function mapDispatchToProps(dispatch)
	return {
		addMessage = function()
			local rng = Random.new()
			local message = createMockMessage({
				userId = USER_ID,
				text = MESSAGES[rng:NextInteger(0, #MESSAGES)]
			})

			dispatch(AddMessage(message))
		end
	}
end

Story = RoactRodux.connect(nil, mapDispatchToProps)(Story)

return function(props)
	return Roact.createElement(RoactRodux.StoreProvider, {
		store = Rodux.Store.new(chatReducer)
	}, {
		Roact.createElement(Story, {
			chatSettings = props.chatSettings,
		})
	})
end
