local Framework = script.Parent.Parent.Parent

local renderStories = require(Framework.Examples.renderStories)

local stories = require(script.Parent.stories)

return function()
	return renderStories(stories, {
		-- The VoteBar background color matches the default color for the story backgrounds.
		frameProps = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0,
			margin = {
				top = 10,
				bottom = 10,
				left = 10,
				right = 10,
			}
		}
	})
end
