local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local UI = require(Framework.UI)
local Pane = UI.Pane
local FakeLoadingBar = UI.FakeLoadingBar
local Button = UI.Button

-- Mount and display a dialog
local ExampleLoadingBar = Roact.PureComponent:extend("ExampleLoadingBar")

function ExampleLoadingBar:init()
	self.state = {
		completed = false,
		progress = 0,
	}
	self.finishLoading = function()
		self:setState({
			completed = true,
		})
	end
	self.setProgress = function(progress)
		self:setState({
			progress = progress,
		})
	end
end

function ExampleLoadingBar:render()
	local completed = self.state.completed
	local progress = self.state.progress

	local progressText = ("%i%%"):format(progress * 100)

	return Roact.createElement(Pane, {
		Layout = Enum.FillDirection.Vertical,
		AutomaticSize = Enum.AutomaticSize.Y,
		Padding = 10,
		Spacing = 15
	}, {
		-- Loads to full in 5 seconds
		FakeLoadingBar = Roact.createElement(FakeLoadingBar, {
			LayoutOrder = 1,
			Size = UDim2.fromOffset(125, 8),
			LoadingTime = 5,
			OnProgressChanged = self.setProgress,
		}),

		-- Sets text to the loading progress of the bar above
		LoadingText = Roact.createElement("TextLabel", {
			LayoutOrder = 2,
			Size = UDim2.fromOffset(120, 16),
			BackgroundTransparency = 1,
			Text = progressText,
			Font = Enum.Font.SourceSans,
			TextSize = 16,
		}),

		-- Loads to 75% in 2 seconds, then finishes when button is clicked
		FakeLoadingBar2 = Roact.createElement(FakeLoadingBar, {
			LayoutOrder = 3,
			Size = UDim2.fromOffset(125, 8),
			LoadingTime = 2,
			HoldValue = 0.75,
			Completed = completed,
		}),

		Button = Roact.createElement(Button, {
			LayoutOrder = 4,
			Style = "Round",
			Text = "Complete",
			Size = UDim2.fromOffset(120, 32),
			OnClick = self.finishLoading,
		}),
	})
end

return ExampleLoadingBar
