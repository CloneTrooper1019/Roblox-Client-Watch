return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local TreeTable = require(script.Parent)

	local TestHelpers = require(Framework.TestHelpers)

	local items = {
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

	local function createTreeTable()
		return Roact.createElement(TreeTable, {
			RootItems = items,
			Size = UDim2.new(0, 240, 0, 240),
			Expansion = {},
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
			OnExpansionChange = function() end,
			GetChildren = function(item)
				return item.children or {}
			end,
			Scroll = true,
		})
	end

	it("should create and destroy without errors", function()
		local element = TestHelpers.provideMockContext(nil, {
			TreeTable = createTreeTable()
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end
