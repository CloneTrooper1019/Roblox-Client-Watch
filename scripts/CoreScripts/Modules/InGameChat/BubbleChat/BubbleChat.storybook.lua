local CorePackages = game:GetService("CorePackages")

local Cryo = require(CorePackages.Packages.Cryo)
local Roact = require(CorePackages.Packages.Roact)
local RoactRodux = require(CorePackages.Packages.RoactRodux)

local StoryStore = require(script.Parent.Helpers.StoryStore)
local ChatSettings = require(script.Parent.ChatSettings)

Roact.setGlobalConfig({
	elementTracing = true,
	propValidation = true,
})

return {
	roact = Roact,
	mapStory = function(story)
		return function(storyProps)
			return Roact.createElement(RoactRodux.StoreProvider, {
				store = StoryStore,
			}, {
				Story = Roact.createElement(story, Cryo.Dictionary.join(
					storyProps, {chatSettings = ChatSettings}))
			})
		end
	end,
}
