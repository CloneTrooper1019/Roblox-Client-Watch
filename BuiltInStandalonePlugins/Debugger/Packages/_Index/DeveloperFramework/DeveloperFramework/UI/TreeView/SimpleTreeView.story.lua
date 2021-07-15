local Framework = script.Parent.Parent.Parent

local Dash = require(Framework.packages.Dash)
local copy = Dash.copy

local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local Button = UI.Button
local Pane = UI.Pane
local TextLabel = UI.Decoration.TextLabel
local TreeView = UI.TreeView

local ExampleTreeView = Roact.PureComponent:extend(script.Parent.Name .. "ExampleTreeView")

function ExampleTreeView:init()
	self.state = {
		Expansion = {},
		Items = {
			{
				name = "Workspace",
				children = {
					{
						name = "Ocean",
						children = {
							{
								name = "Billy The Fish"
							}
						}
					}
				}
			},
			{
				name = "ReplicatedStorage",
				children = {
					{
						name = "WeatherSystem"
					},
					{
						name = "CloudSystem",
						children = {
							{
								name = "Cheeky Cumulus"
							}
						}
					},
				}
			},
			{
				name = "ServerStorage",
				children = {
					{
						name = "Secret Base",
						children = {
							{
								name = "Obsidian Door"
							}
						}
					}
				 }
			}
		}
	}
end

function ExampleTreeView:render()
	return Roact.createElement(TreeView, {
		Size = UDim2.new(0, 240, 0, 240),
		Expansion = self.state.Expansion,
		RootItems = self.state.Items,
		RenderRow = function(row)
			local isExpanded = self.state.Expansion[row.item]
			local hasChildren = row.item.children and #row.item.children > 0
			local indent = row.depth * 24
			return Roact.createElement(Pane, {
				Size = UDim2.new(1, -indent, 0, 32),
				LayoutOrder = row.index
			}, {
				Toggle = hasChildren and Roact.createElement(Button, {
					Text = isExpanded and "-" or "+",
					Position = UDim2.new(0, 5 + indent, 0, 4),
					Size = UDim2.new(0, 24, 0, 24),
					OnClick = function()
						local newExpansion = copy(self.state.Expansion)
						newExpansion[row.item] = not newExpansion[row.item]
						self:setState({
							Expansion = newExpansion
						})
					end
				}) or nil,
				Label = Roact.createElement(TextLabel, {
					Text = row.item.name,
					Size = UDim2.new(1, -40, 1, 0),
					Position = UDim2.new(0, 40 + indent, 0, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
				})
			})
		end,
		GetChildren = function(item)
			return item.children or {}
		end
	})
end

return ExampleTreeView
