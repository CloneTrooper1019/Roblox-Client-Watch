return function()
	local Plugin = script.Parent.Parent

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runRhodiumTest = TestRunner.runRhodiumTest

	it("should be able to run Rhodium tests", function()
		runRhodiumTest(function()
		end)
	end)
end