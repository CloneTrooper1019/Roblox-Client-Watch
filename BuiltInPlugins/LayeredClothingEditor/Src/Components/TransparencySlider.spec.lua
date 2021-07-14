return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local TransparencySlider = require(script.Parent.TransparencySlider)

	local function createTransparencySlider()
		return Roact.createElement(TransparencySlider, {
			Title = "title",
			Value = 0,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 1, 0),
			IsDisabled = false,
		})
	end

	it("should create and destroy without errors", function()
		runComponentTest(createTransparencySlider())
	end)
end