return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local PreviewConstants = require(Plugin.Src.Util.PreviewConstants)

	local PreviewTabsRibbon = require(script.Parent.PreviewTabsRibbon)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(PreviewTabsRibbon))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(PreviewTabsRibbon, {
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local avatars = frame["1 " .. tostring(PreviewConstants.TABS_KEYS.Avatars)]

				expect(frame).to.be.ok()
				expect(avatars).to.be.ok()
			end
		)
	end)
end