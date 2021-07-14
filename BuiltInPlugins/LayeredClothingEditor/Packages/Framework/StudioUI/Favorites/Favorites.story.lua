local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Util = require(Framework.Util)
local Immutable = Util.Immutable

local renderStories = require(Framework.Examples.renderStories)
local stories = require(script.Parent.stories)

return renderStories(stories, {
	storyRenderer = function(story, props)
		return Roact.createElement("Frame", Immutable.JoinDictionaries({
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, props), {
			Story = story
		})
	end,
})
