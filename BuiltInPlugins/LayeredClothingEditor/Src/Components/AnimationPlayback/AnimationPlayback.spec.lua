return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local AnimationPlayback = require(script.Parent.AnimationPlayback)

	local function createAnimationPlayback()
		return Roact.createElement(AnimationPlayback)
	end

	it("should create and destroy without errors", function()
		runComponentTest(createAnimationPlayback())
	end)
end