return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local FlowScreenLayout = require(script.Parent.FlowScreenLayout)

	local function createFlowScreenLayout(hasBackButton, hasContent)
		local renderContentFrame = function()
			return Roact.createElement("Frame")
		end
		return Roact.createElement(FlowScreenLayout, {
			Title = "Title",
			PromptText = "Prompt",
			NextButtonText = "Next",
			BackButtonText = "Back",
			NextButtonEnabled = true,
			BackButtonEnabled = true,
			HasBackButton = hasBackButton,
			GoToNext = function() end,
			GoToPrevious = function() end,
			RenderContent = hasContent and renderContentFrame or nil,
		})
	end

	it("should render correctly with no back button and content", function ()
		runComponentTest(
			createFlowScreenLayout(false, true),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local viewArea = frame.ViewArea

				local uiPadding_Main = viewArea.UIPadding
				local prompt = viewArea.Prompt
				local content = viewArea.Content
				local nextAndBackButtonContainer = viewArea.NextAndBackButtonContainer
				local layout = nextAndBackButtonContainer.Layout
				local nextButton = nextAndBackButtonContainer.NextButton
				local backButton = nextAndBackButtonContainer:FindFirstChild("BackButton")

				expect(frame).to.be.ok()
				expect(viewArea).to.be.ok()
				expect(uiPadding_Main).to.be.ok()
				expect(prompt).to.be.ok()
				expect(content).to.be.ok()
				expect(layout).to.be.ok()
				expect(nextAndBackButtonContainer).to.be.ok()
				expect(nextButton).to.be.ok()
				expect(backButton).to.equal(nil)
			end
		)
	end)

	it("should render correctly with no back button and no content", function ()
		runComponentTest(
			createFlowScreenLayout(false, false),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local viewArea = frame.ViewArea

				local uiPadding_Main = viewArea.UIPadding
				local prompt = viewArea.Prompt
				local content = viewArea:FindFirstChild("Content")
				local nextAndBackButtonContainer = viewArea.NextAndBackButtonContainer
				local layout = nextAndBackButtonContainer.Layout
				local nextButton = nextAndBackButtonContainer.NextButton
				local backButton = nextAndBackButtonContainer:FindFirstChild("BackButton")

				expect(frame).to.be.ok()
				expect(viewArea).to.be.ok()
				expect(uiPadding_Main).to.be.ok()
				expect(prompt).to.be.ok()
				expect(content).to.equal(nil)
				expect(layout).to.be.ok()
				expect(nextAndBackButtonContainer).to.be.ok()
				expect(nextButton).to.be.ok()
				expect(backButton).to.equal(nil)
			end
		)
	end)

	it("should render correctly with back button and content", function ()
		runComponentTest(
			createFlowScreenLayout(true, true),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local viewArea = frame.ViewArea

				local uiPadding_Main = viewArea.UIPadding
				local prompt = viewArea.Prompt
				local content = viewArea.Content
				local nextAndBackButtonContainer = viewArea.NextAndBackButtonContainer
				local layout = nextAndBackButtonContainer.Layout
				local nextButton = nextAndBackButtonContainer.NextButton
				local backButton = nextAndBackButtonContainer:FindFirstChild("BackButton")

				expect(frame).to.be.ok()
				expect(viewArea).to.be.ok()
				expect(uiPadding_Main).to.be.ok()
				expect(prompt).to.be.ok()
				expect(content).to.be.ok()
				expect(layout).to.be.ok()
				expect(nextAndBackButtonContainer).to.be.ok()
				expect(nextButton).to.be.ok()
				expect(backButton).to.be.ok()
			end
		)
	end)

	it("should render correctly with back button and no content", function ()
		runComponentTest(
			createFlowScreenLayout(true, false),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local viewArea = frame.ViewArea

				local uiPadding_Main = viewArea.UIPadding
				local prompt = viewArea.Prompt
				local nextAndBackButtonContainer = viewArea.NextAndBackButtonContainer
				local layout = nextAndBackButtonContainer.Layout
				local nextButton = nextAndBackButtonContainer.NextButton
				local backButton = nextAndBackButtonContainer:FindFirstChild("BackButton")

				expect(frame).to.be.ok()
				expect(viewArea).to.be.ok()
				expect(uiPadding_Main).to.be.ok()
				expect(prompt).to.be.ok()
				expect(layout).to.be.ok()
				expect(nextAndBackButtonContainer).to.be.ok()
				expect(nextButton).to.be.ok()
				expect(backButton).to.be.ok()
			end
		)
	end)

end