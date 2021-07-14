return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local TabsRibbon = require(script.Parent.TabsRibbon)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(TabsRibbon, {
			Buttons = {}
		}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(TabsRibbon, {
				Buttons = {
					{
						Key = "Avatars",
						Text = "Avatars Text",
						IsEnabled = true,
					},
				},
				RenderButtonCallback = function()
					return Roact.createElement("Frame")
				end
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local avatars = frame["1 Avatars"]

				expect(frame).to.be.ok()
				expect(avatars).to.be.ok()
			end
		)
	end)
end