return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local ConfirmDialog = require(script.Parent.ConfirmDialog)

	local function createConfirmDialog()
		return Roact.createElement(ConfirmDialog, {
			Text = "test",
			Title = "title",
			OnClose = function()
			end,
		})
	end

	it("should mount and unmount", function()
		runComponentTest(createConfirmDialog())
	end)

	it("should render correctly", function ()
		runComponentTest(
			createConfirmDialog(),
			function(container)
				wait()
				local screenGui = game.CoreGui["title"]
				local solidBackground = screenGui.SolidBackground
				local contents = solidBackground.Contents.Contents
				local buttonContainer = solidBackground.ButtonContainer.Contents
				local message = contents.Message

				expect(screenGui).to.be.ok()
				expect(solidBackground).to.be.ok()
				expect(contents).to.be.ok()
				expect(buttonContainer).to.be.ok()
				expect(message).to.be.ok()
			end
		)
	end)

end