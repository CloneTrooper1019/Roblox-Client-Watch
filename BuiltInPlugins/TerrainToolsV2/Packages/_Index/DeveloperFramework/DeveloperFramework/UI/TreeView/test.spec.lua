return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local ContextServices = require(Framework.ContextServices)
	local Theme = ContextServices.Theme
	local provide = ContextServices.provide
	local FrameworkStyles = require(Framework.UI.FrameworkStyles)
	local TreeView = require(script.Parent)

	local FFlagDevFrameworkTreeViewRow = game:GetFastFlag("DevFrameworkTreeViewRow")
	-- TODO: Remove when FFlagDevFrameworkTreeViewRow is retired
	local UI = require(Framework.UI)
	local Button = UI.Button
	local Pane = UI.Pane
	local TextLabel = UI.Decoration.TextLabel

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

	-- TODO: Remove when FFlagDevFrameworkTreeViewRow is retired
	local function DEPRECATED_renderRow(row)
		local hasChildren = row.item.children and #row.item.children > 0
		local indent = row.depth * 24
		return Roact.createElement(Pane, {
			Size = UDim2.new(1, -indent, 0, 32),
			LayoutOrder = row.index
		}, {
			Toggle = hasChildren and Roact.createElement(Button, {
				Text = "+",
				Position = UDim2.new(0, 5 + indent, 0, 4),
				Size = UDim2.new(0, 24, 0, 24),
				OnClick = function() end
			}) or nil,
			Label = Roact.createElement(TextLabel, {
				Text = row.item.name,
				Size = UDim2.new(1, -40, 1, 0),
				Position = UDim2.new(0, 40 + indent, 0, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
			})
		})
	end

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

		-- TODO: Remove when FFlagDevFrameworkTreeViewRow is retired
		local renderRow = nil
		if not FFlagDevFrameworkTreeViewRow then
			renderRow = DEPRECATED_renderRow
		end

		return provide({theme}, {
			TreeView = Roact.createElement(TreeView, {
				RootItems = items,
				Size = UDim2.new(0, 240, 0, 240),
				Expansion = {},
				GetChildren = function(item)
					return item.children
				end,
				-- TODO: Remove when FFlagDevFrameworkTreeViewRow is retired
				RenderRow = renderRow
			}),
		})
	end

	it("should create and destroy without errors", function()
		local element = createTreeView()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end