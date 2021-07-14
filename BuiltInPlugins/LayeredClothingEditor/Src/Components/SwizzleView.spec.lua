return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local SwizzleView = require(script.Parent.SwizzleView)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(SwizzleView, {
			Title = "Title",
			LayoutOrder = 1
		}))
	end)
end