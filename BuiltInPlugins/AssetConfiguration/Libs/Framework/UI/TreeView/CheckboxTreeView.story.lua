local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)

local Dash = require(Framework.packages.Dash)
local join = Dash.join

local UI = require(Framework.UI)
local Checkbox = UI.Checkbox
local Pane = UI.Pane
local TextLabel = UI.Decoration.TextLabel
local TreeView = UI.TreeView

local FFlagDevFrameworkTreeViewRow = game:GetFastFlag("DevFrameworkTreeViewRow")

local function TreeRowCheckbox(props)
	return Roact.createElement(Pane, {
		Size = UDim2.fromOffset(24, 24),
		Padding = 4,
		LayoutOrder = props.LayoutOrder
	}, {
		Checkbox = Roact.createElement(Checkbox, {
			Checked = props.Checked[props.Item],
			OnClick = function()
				props.OnCheck(props.Item)
			end,
		})
	})
end

local ExampleTreeView = Roact.PureComponent:extend(script.Parent.Name .. "ExampleTreeView")

function ExampleTreeView:init()
	self.state = {
		Expansion = {},
		Checked = {},
		Items = {
			{
				text = "Workspace",
				children = {
					{
						text = "Ocean",
						children = {
							{
								text = "Billy The Fish"
							},
						}
					}
				},
				icon = {
					Image = "rbxasset://textures/DeveloperFramework/Favorites/star_filled.png",
					Size = UDim2.new(0, 14, 0, 14),
				}
			},
			{
				text = "ReplicatedStorage",
				children = {
					{
						text = "WeatherSystem",
					},
					{
						text = "CloudSystem",
						children = {
							{
								text = "Cheeky Cumulus"
							},
						}
					},
				}
			},
			{
				text = "ServerStorage",
				children = {
					{
						text = "Secret Base - The access code to enter the secret base is actually incredibly long - enough to make the tree view scroll",
						icon = {
							Image = "rbxasset://textures/DeveloperFramework/Favorites/star_filled.png",
							Size = UDim2.new(0, 14, 0, 14),
						},
						children = {
							{
								text = "Obsidian Door"
							},
						}
					}
				 }
			}
		}
	}
end

function ExampleTreeView:render()
	if not FFlagDevFrameworkTreeViewRow then
		return Roact.createElement(TextLabel, {
			Text = "Please enable FFlagDevFrameworkTreeViewRow to view this story",
			AutomaticSize = Enum.AutomaticSize.XY,
		})
	end
	return Roact.createElement(TreeView, {
		Size = UDim2.new(0, 240, 0, 240),
		Expansion = self.state.Expansion,
		RootItems = self.state.Items,
		RowProps = {
			Checked = self.state.Checked,
			BeforeIcon = TreeRowCheckbox,
			OnCheck = function(item)
				self:setState({
					Checked = join(self.state.Checked, {
						[item] = not self.state.Checked[item]
					})
				})
			end
		},
		OnExpansionChange = function(newExpansion)
			self:setState({
				Expansion = join(self.state.Expansion, newExpansion)
			})
		end,
	})
end

return ExampleTreeView
