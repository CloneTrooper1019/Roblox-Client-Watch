local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local StudioUI = require(Framework.StudioUI)
local Button = UI.Button
local StyledDialog = StudioUI.StyledDialog

local AlertDialog = Roact.PureComponent:extend("AlertDialog")

function AlertDialog:init()
	self.state = {
		enabled = false
	}
end

function AlertDialog:render()
	return Roact.createElement(Button, {
		Size = UDim2.new(1, 0, 0, 30),
		LayoutOrder = 2,
		Style = "Round",
		Text = "Open Alert Dialog",
		OnClick = function()
			self:setState({
				enabled = true
			})
		end,
	}, {
		Dialog = Roact.createElement(StyledDialog, {
			Style = "Alert",
			Enabled = self.state.enabled,
			Title = "Styled Dialog examples",
			MinContentSize = Vector2.new(400, 100),
			Buttons = {
				{ Key = "ok", Text = "OK" },
			},
			OnButtonPressed = function(key)
				print("Dialog button pressed : ", key)
				self:setState({
					enabled = false
				})
			end,
			OnClose = function()
				self:setState({
					enabled = false
				})
			end,
		}, {
			Contents = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1.0,
				TextSize = 50,
				Text = "WARNING!",
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0, 0),
			}),
		}),
	})
end

return AlertDialog