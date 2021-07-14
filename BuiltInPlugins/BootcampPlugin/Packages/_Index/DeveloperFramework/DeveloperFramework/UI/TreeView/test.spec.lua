return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Theme = ContextServices.Theme
	local provide = ContextServices.provide
	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local TreeView = require(script.Parent)
	local TextLabel = require(Framework.UI.TextLabel)

	local StudioTheme = require(Framework.Style.Themes.StudioTheme)

	local Util = require(Framework.Util)
	local THEME_REFACTOR = Util.RefactorFlags.THEME_REFACTOR

	local items = {
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

	local function createTreeView()
		local theme
		if THEME_REFACTOR then
			theme = StudioTheme.mock()
		else
			theme = Theme.new(function()
				return {
					Framework = FrameworkStyles.new(),
				}
			end)
		end
		return provide({theme}, {
			TreeView = Roact.createElement(TreeView, {
				RootItems = items,
				Size = UDim2.new(0, 240, 0, 240),
				Expansion = {},
				RenderRow = function(row)
					return Roact.createElement(TextLabel, {Text = row.item.name})
				end,
				GetChildren = function(item)
					return item.children
				end
			}),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTreeView()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end