local Framework = script.Parent.Parent.Parent

local Dash = require(Framework.packages.Dash)
local join = Dash.join

local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local TreeTable = UI.TreeTable

local ExampleTreeTable = Roact.PureComponent:extend(script.Parent.Name .. "ExampleTreeTable")

function ExampleTreeTable:init()
	self.state = {
		Expansion = {},
		Items = {
			{
				name = "Workspace",
				value = {
					Value = 12,
					LeftIcon = {
						Image = "rbxasset://textures/DeveloperFramework/Favorites/star_filled.png",
						Size = UDim2.new(0, 14, 0, 14),
					},
				},
				children = {
					{
						name = "Ocean",
						value = 53,
						children = {
							{
								name = "Billy The Fish",
								value = 12,
							}
						}
					}
				}
			},
			{
				name = "ReplicatedStorage",
				value = 18,
				children = {
					{
						name = "WeatherSystem",
						value = {
							Value = 193,
							LeftIcon = {
								Image = "rbxasset://textures/DeveloperFramework/Favorites/star_filled.png",
								Size = UDim2.new(0, 14, 0, 14),
							},
						},
					},
					{
						name = "CloudSystem",
						value = 9001,
						children = {
							{
								name = "Cheeky Cumulus",
								value = {
									Value = 200,
									LeftIcon = {
										Image = "rbxasset://textures/DeveloperFramework/Favorites/star_filled.png",
										Size = UDim2.new(0, 14, 0, 14),
									},
								},
							}
						}
					},
				}
			},
			{
				name = "ServerStorage",
				value = 30,
				children = {
					{
						name = "Secret Base",
						value = 212,
						children = {
							{
								name = "Obsidian Door",
								value = 120,
							}
						}
					}
				 }
			}
		}
	}
end

function ExampleTreeTable:render()
	return Roact.createElement(TreeTable, {
		Size = UDim2.new(1, 0, 0, 240),
		Columns = {
			{
				Name = "Name",
				Key = "name",
			},
			{
				Name = "Value",
				Key = "value",
			}
		},
		OnExpansionChange = function(newExpansion)
			self:setState({
				Expansion = join(self.state.Expansion, newExpansion)
			})
		end,
		Expansion = self.state.Expansion,
		RootItems = self.state.Items,
		GetChildren = function(item)
			return item.children or {}
		end,
		Scroll = true,
	})
end

return ExampleTreeTable