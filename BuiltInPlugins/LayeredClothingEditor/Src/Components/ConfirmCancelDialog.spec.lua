return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local ConfirmCancelDialog = require(script.Parent.ConfirmCancelDialog)

	local function createConfirmCancelDialog()
		return Roact.createElement(ConfirmCancelDialog, {
			Text = "test",
			Title = "title",
			OnConfirm = function()
			end,
			OnClose = function()
			end,
		})
	end

	it("should mount and unmount", function()
		runComponentTest(createConfirmCancelDialog())
	end)

	it("should render correctly", function ()
		runComponentTest(
			createConfirmCancelDialog(),
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