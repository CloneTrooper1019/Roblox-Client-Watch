local Framework = script.Parent.Parent.Parent

local Dash = require(Framework.packages.Dash)
local join = Dash.join

local sort = table.sort

local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local TreeTable = UI.TreeTable

local ExampleTreeTable = Roact.PureComponent:extend(script.Parent.Name .. "ExampleTreeTable")

local columns = {
	{
		Name = "Name",
		Key = "name",
	},
	{
		Name = "Value",
		Key = "value",
	}
}

function ExampleTreeTable:init()
	self.state = {
		SortChildren = nil,
		SortIndex = nil,
		SortOrder = nil,
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
	self.onSortChange = function(index, sortOrder)
		local function sortChildren(left, right)
			local column = columns[index]
			local leftCell = typeof(left[column.Key]) == "table" and left[column.Key].Value or left[column.Key]
			local rightCell = typeof(right[column.Key]) == "table" and right[column.Key].Value or right[column.Key]
			if sortOrder == Enum.SortDirection.Descending then
				return leftCell < rightCell
			else
				return leftCell > rightCell
			end
		end
		local items = join(self.state.Items)
		sort(items, sortChildren)
		self:setState({
			Items = items,
			SortChildren = sortChildren,
			SortIndex = index,
			SortOrder = sortOrder
		})
	end
end

function ExampleTreeTable:render()
	return Roact.createElement(TreeTable, {
		SortIndex = self.state.SortIndex,
		SortOrder = self.state.SortOrder,
		SortChildren = self.state.SortChildren,
		OnSortChange = self.onSortChange,
		Size = UDim2.new(1, 0, 0, 240),
		Columns = columns,
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
