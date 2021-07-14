return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local LCERadioButtonList = require(script.Parent.LCERadioButtonList)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(LCERadioButtonList, {
			Buttons = {
				{
					Key = "B1",
					Text = "B1",
					Disabled = false,
				},
				{
					Key = "B2",
					Text = "B2",
					Disabled = false,
				},
			},
			Title = "Test",
			OnClick = function() end,
		}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(LCERadioButtonList, {
				Buttons = {
					{
						Key = "B1",
						Text = "B1",
						Disabled = false,
					},
					{
						Key = "B2",
						Text = "B2",
						Disabled = false,
					},
				},
				Title = "Test",
				OnClick = function() end,
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local layout = frame.Layout
				local title = frame.Title
				local list = frame.List

				expect(frame).to.be.ok()
				expect(layout).to.be.ok()
				expect(title).to.be.ok()
				expect(list).to.be.ok()
			end
		)
	end)
end