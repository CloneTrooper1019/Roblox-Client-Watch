return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local TestHelpers = require(Framework.TestHelpers)
	local stories = require(script.Parent.stories)

	describe("stories", function()
		for name, story in pairs(stories()) do
			it(name, function()
				local element = TestHelpers.provideMockContext(nil, {
					[name] = story
				})
				local instance = Roact.mount(element)
				Roact.unmount(instance)
			end)
		end
	end)
end