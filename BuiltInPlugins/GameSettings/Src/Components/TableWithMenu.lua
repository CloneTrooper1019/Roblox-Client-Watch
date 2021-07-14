--[[
	Table of data.

	Props:
        table Headers = list of column names for the table
        table Data = list of data to add in the table, make sure data is in the same order as header for organization
        table MenuItems = list of options to display in dropdown for button
            Formatted like this:
            {
				{Key = "Item1", Text = "SomeLocalizedTextForItem1"},
				{Key = "Item2", Text = "SomeLocalizedTextForItem2"},
            }
        function OnItemClicked(item) = A callback when the user selects an item in the dropdown.
			Returns the item as it was defined in the Items array.
        int LayoutOrder = Order of element in layout
    Optional Props:
        function MenuItemsFilterFunc(row, menuItems) = A callback that filters the menu items based on row data. 
                                                       No return value - just remove unecessary items from menuItems. Don't modify row
        int TableHeight = Custom table height that will overrule default, which is theme.table.height
        string EmptyText = Text to display over the table if there no rows to display
        ImageButton HeaderButton = Button displayed in the top right corner of the table, e.g. a button to refresh the table
        bool showTableBackground = If true, we show the table background
]]

local FFlagFixRadioButtonSeAndTableHeadertForTesting = game:getFastFlag("FixRadioButtonSeAndTableHeadertForTesting")

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)

local UILibrary = require(Plugin.UILibrary)
local InfiniteScrollingFrame = UILibrary.Component.InfiniteScrollingFrame

local Framework = Plugin.Framework

local ContextServices = require(Framework.ContextServices)

local TableWithMenuItem = require(Plugin.Src.Components.TableWithMenuItem)
local TableWithMenu = Roact.PureComponent:extend("TableWithMenu")

function TableWithMenu:createHeaderLabels(theme, headers, headerButton)
    local headerLabels = {
        HeaderLayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),

        Padding = Roact.createElement("UIPadding", {
            PaddingLeft = UDim.new(0, theme.table.textPadding),
            PaddingRight = UDim.new(0, theme.table.textPadding),
        }),
    }
    local numberColumns = #headers
    for i = 1, #headers do
        local header = Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Normal, {
            Size = UDim2.new( 1 / numberColumns, 0, 1, 0),
            LayoutOrder = i,

            Text = FFlagFixRadioButtonSeAndTableHeadertForTesting and headers[i].Text or headers[i],

            BackgroundTransparency = 1,
            BorderSizePixel = 0,

            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }))
        if FFlagFixRadioButtonSeAndTableHeadertForTesting then
            headerLabels[headers[i].Id] = header
        else
            headerLabels[i] = header
        end
    end
    
    if headerButton then
        local frame = Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = #headers + 1,
            Size = UDim2.new( 0, 0, 1, 0),
        }, {headerButton})

        headerLabels[#headers + 1] = frame
    end

    return headerLabels
end

function TableWithMenu:createDataLabels(data, menuItems, onItemClicked, menuItemsFilterFunc)
    local dataRows = {
        ListLayout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            SortOrder = Enum.SortOrder.LayoutOrder,

            [Roact.Ref] = self.layoutRef,
        })
    }
    
    local dataCount = 0
    for id, rowData in pairs(data) do
        local filteredMenuItems
        
        if menuItemsFilterFunc then
            filteredMenuItems = {unpack(menuItems)}
            menuItemsFilterFunc(rowData, filteredMenuItems)
        else
            filteredMenuItems = menuItems
        end

        local rowComponent = Roact.createElement(TableWithMenuItem, {
            RowData = rowData.row,
            MenuItems = filteredMenuItems,
            OnItemClicked = function(key)
                onItemClicked(key, id)
            end,
            LayoutOrder = rowData.index,
            Icon = rowData.icon or nil
        })
        dataRows[id] = rowComponent

        dataCount = dataCount + 1
    end

    return dataRows, dataCount
end

function TableWithMenu:init()
    self.layoutRef = Roact.createRef()
end

function TableWithMenu:render()
	local props = self.props
    local theme = props.Theme:get("Plugin")

    local headers = props.Headers
    local data = props.Data
    local menuItems = props.MenuItems
    local onItemClicked = props.OnItemClicked
    local layoutOrder = props.LayoutOrder
    local nextPageFunc = props.NextPageFunc
    local MenuItemsFilterFunc = props.MenuItemsFilterFunc

    local nextPageRequestDistance = props.ScrollingFrameNextPageRequestDistance
    local headerButton = props.HeaderButton
    local tableHeight = props.TableHeight or theme.table.height
    local showTableBackground = props.ShowTableBackground

    local headerContent = self:createHeaderLabels(theme, headers, headerButton)
    local dataContent, dataCount = self:createDataLabels(data, menuItems, onItemClicked, MenuItemsFilterFunc)
    
    local emptyText = (dataCount == 0 and props.EmptyText) or nil
    local backgroundColor = showTableBackground and theme.table.item.background or nil

    -- EmptyTextBox and ScrollingContainer below both use this size
    local size = UDim2.new(1, 0, 1, -theme.table.header.height)

    return Roact.createElement("Frame", {
        Size = UDim2.new(1, 0, 0, tableHeight),

        BackgroundTransparency = 1,

        LayoutOrder = layoutOrder,
    }, {
        ListLayout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
        }),

        HeaderFrame = Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 0, theme.table.header.height),

            BackgroundTransparency = 1,

            LayoutOrder = 1,
        }, headerContent),

        ScrollingContainer = not emptyText and Roact.createElement(InfiniteScrollingFrame, {
            Size = size,
            BackgroundTransparency = 0,
            BackgroundColor = backgroundColor,

            LayoutRef = self.layoutRef,
            CanvasHeight = theme.table.height,

            NextPageFunc = nextPageFunc,
            NextPageRequestDistance = nextPageRequestDistance,
            
            LayoutOrder = 2,
        }, dataContent),
        
        EmptyTextBox = emptyText and Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Smaller, {
            Size = size,
            LayoutOrder = 2,
            Text = emptyText,
            BackgroundTransparency = showTableBackground and 0 or 1,
            BackgroundColor3 = backgroundColor,
            BorderColor3 = backgroundColor,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }), {})
    })
end

ContextServices.mapToProps(TableWithMenu, {
    Theme = ContextServices.Theme,
})

return TableWithMenu