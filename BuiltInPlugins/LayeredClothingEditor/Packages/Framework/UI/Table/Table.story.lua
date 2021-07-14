local Framework = script.Parent.Parent.Parent
local Roact = require(Framework.Parent.Roact)
local UI = require(Framework.UI)
local Pane = UI.Pane
local Table = UI.Table
local TextLabel = UI.Decoration.TextLabel

local insert = table.insert

local scrollRows = {}
for i = 1, 1000 do
	insert(scrollRows, {
		Name = "Row " .. i,
		Count = math.floor(math.random() * 100),
		Size = (math.floor(math.random() * 100) * 10) .. "px",
	})
end

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

return {
	stories = {
		{
			name = "Fixed size",
			story = Roact.createElement(Table, {
				Size = UDim2.new(1, 0, 0, 200),
				Columns = columns,
				Rows = rows,
			})
		},
		{
			name = "With footer",
			story = Roact.createElement(Table, {
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
		},
		{
			name = "With scroll",
			story = Roact.createElement(Table, {
				Scroll = true,	
				Size = UDim2.new(1, 0, 0, 200),
				Footer = Roact.createElement(Pane, {
					Padding = 5,
					Layout = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
				}, {
					Label = Roact.createElement(TextLabel, {
						AutomaticSize = Enum.AutomaticSize.XY,
						Text = "1000 items",
					}),
				}),
				Columns = columns,
				Rows = scrollRows,
			})
		},
	}
}
