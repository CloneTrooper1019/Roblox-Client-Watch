return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local InstanceSelector = require(script.Parent.InstanceSelector)

	local function createInstanceSelector()
		return Roact.createElement(InstanceSelector, {
			OnValidSelection = function()
			end,
			IsSelectedInstanceValid = function()
				return false
			end,
		})
	end

	it("should mount and unmount", function()
		runComponentTest(createInstanceSelector())
	end)

end