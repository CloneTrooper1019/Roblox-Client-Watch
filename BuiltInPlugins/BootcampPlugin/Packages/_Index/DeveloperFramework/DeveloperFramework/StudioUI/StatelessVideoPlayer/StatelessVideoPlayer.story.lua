local Framework = script.Parent.Parent.Parent

local Roact = require(Framework.Parent.Roact)
local Immutable = require(Framework.Util.Immutable)

local renderStories = require(Framework.Examples.renderStories)
local stories = require(script.Parent.stories)

return renderStories(stories, {
	storyRenderer = function(story, props)
		return Roact.createElement("Frame", Immutable.JoinDictionaries({
			Size = UDim2.new(1, 0, 0, 242),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, props), {
			Story = story
		})
	end,
})

