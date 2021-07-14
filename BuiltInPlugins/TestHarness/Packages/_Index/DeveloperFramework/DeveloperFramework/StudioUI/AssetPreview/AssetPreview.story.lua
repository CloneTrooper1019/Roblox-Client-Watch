local Framework = script.Parent.Parent.Parent
local renderStories = require(Framework.Examples.renderStories)
local stories = require(script.Parent.stories)

return renderStories(stories)

