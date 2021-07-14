return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)

	local provideMockContext = require(Framework.TestHelpers.provideMockContext)
	local InfiniteScrollingFrame = require(script.Parent)

	local function createTestInfiniteScrollingFrame(props, children)
		return provideMockContext(nil, {
			InfiniteScrollingFrame = Roact.createElement(InfiniteScrollingFrame, props, children)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestInfiniteScrollingFrame({
			Items = {
				{
					text = "abc"
				}
			},
			RenderItem = function(item)
				return item.text
			end
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end