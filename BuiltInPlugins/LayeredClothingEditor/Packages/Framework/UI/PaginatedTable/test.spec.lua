return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local TestHelpers = require(Framework.TestHelpers)
	local PaginatedTable = require(script.Parent)
	local Pane = require(Framework.UI.Pane)
	local TextLabel = require(Framework.UI.TextLabel)

	local columns = {
		{
			Name = "Name",
		}, {
			Name = "Count",
		}, {
			Name = "Size",
		},
	}
	local rows = {
		{
			Name = "Left",
			Count = 1,
			Size = "50px",
		},
		{
			Name = "Middle",
			Count = 10,
			Size = "80px",
		},
		{
			Name = "Right",
			Count = 3,
			Size = "20px",
		}
	}

	local function createPaginatedTable(props)
		props = props or {}

		return TestHelpers.provideMockContext(nil, {
			PaginatedTable = Roact.createElement(PaginatedTable, props),
		})
	end

	it("should create and destroy without errors", function()
		local element = createPaginatedTable({
			Size = UDim2.new(1, 0, 0, 200),
			Footer = Roact.createElement(Pane, {
				Padding = 5,
				Layout = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
			}, {
				Label = Roact.createElement(TextLabel, {
					AutomaticSize = Enum.AutomaticSize.XY,
					Text = "3 items",
				}),
			}),
			Columns = columns,
			Rows = rows,
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end