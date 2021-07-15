--[[
    The DevProducts component has a button to bring up a page to create/edit Developer Products
    as well as contains a table of existing developer products.

    The each item in the table of developer products has a "product id", "product name", and "price"

    Necessary Props:
        ProductList = table, table of developer product data
            list structure:
            {
                95 = {
                    95, --ProductID,
                    "The best product ever", --ProductName
                    10000000000000000, --Price
                }
            }
        OnEditDevProductClicked = function(productID), callback that takes in a productId to be invoked on Menu Item
            button clicked.
        LayoutOrder = number, this will be the layout order of this component in its parent.
        OnLoadMoreDevProducts = function, this will be called when scrolling to load more dev products.

    Optional Props:
        ShowTable = boolean, determines if the table should be displayed or not.
]]
local Plugin = script.Parent.Parent.Parent.Parent

local KeyProvider = require(Plugin.Src.Util.KeyProvider)
local GetCopyIdKeyName = KeyProvider.getCopyIdKeyName
local GetEditKeyName = KeyProvider.getEditKeyName

local StudioService = game:GetService("StudioService")

local Roact = require(Plugin.Roact)

local UILibrary = require(Plugin.UILibrary)
local GetTextSize = UILibrary.Util.GetTextSize
local TitledFrame = UILibrary.Component.TitledFrame

local Framework = Plugin.Framework
local FrameworkUI = require(Framework.UI)
local Button = FrameworkUI.Button
local HoverArea = FrameworkUI.HoverArea
local ContextServices = require(Framework.ContextServices)
local FitFrameOnAxis = require(Framework.Util).FitFrame.FitFrameOnAxis

local TableWithMenu = require(Plugin.Src.Components.TableWithMenu)

local DevProducts = Roact.PureComponent:extend(script.Name)

local FFlagFixRadioButtonSeAndTableHeadertForTesting = game:getFastFlag("FixRadioButtonSeAndTableHeadertForTesting")

function DevProducts:render()
    local props = self.props
    local theme = props.Theme:get("Plugin")
    local localization = props.Localization

    local productsList = props.ProductList
    local showTable = props.ShowTable

    local dispatchCreateNewDevProduct = props.CreateNewDevProduct
    local dispatchSetEditDevProductId = props.OnEditDevProductClicked
    local dispatchOnLoadMoreDevProducts = props.OnLoadMoreDevProducts

    local layoutOrder = props.LayoutOrder

    local buttonText = localization:getText("General", "ButtonCreate")
    local buttonTextExtents = GetTextSize(buttonText, theme.fontStyle.Normal.TextSize, theme.fontStyle.Normal.Font)

    local headers
    if FFlagFixRadioButtonSeAndTableHeadertForTesting then
        headers = {
            {
                Text = localization:getText("Monetization", "ProductID"),
                Id = "ProductID",
            },
            {
                Text = localization:getText("Monetization", "ProductName"),
                Id = "ProductName",
            },
            {
                Text = localization:getText("Monetization", "PriceTitle"),
                Id = "PriceTitle",
            }
        }
    else
        headers = {
            localization:getText("Monetization", "ProductID"),
            localization:getText("Monetization", "ProductName"),
            localization:getText("Monetization", "PriceTitle"),
        }
    end

    local onItemClicked = function(key, id)
        if key == (GetEditKeyName()) then
            dispatchSetEditDevProductId(id)
        elseif key == (GetCopyIdKeyName()) then
            StudioService:CopyToClipboard(id)
        else
            error("Invalid Key")
        end
    end

    local menuItems = {
        {Key = GetEditKeyName(), Text = localization:getText("General", "ButtonEdit"),},
        {Key = GetCopyIdKeyName(), Text = localization:getText("General", "CopyIDToClipboard"),}
    }

    return Roact.createElement(FitFrameOnAxis, {
        axis = FitFrameOnAxis.Axis.Vertical,
        minimumSize = UDim2.new(1, 0, 0, 0),
        contentPadding = UDim.new(0, theme.devProducts.headerPadding),

        BackgroundTransparency = 1,

        LayoutOrder = layoutOrder,
    }, {
        DevProductsTitle = Roact.createElement(TitledFrame,{
            Title = localization:getText("Monetization", "DevProducts"),
            LayoutOrder = 1,
            MaxHeight = theme.header.height,
            TextSize = theme.fontStyle.Title.TextSize,
        },{
            Padding = Roact.createElement("UIPadding", {
                PaddingRight = UDim.new(0, theme.devProducts.titlePadding)
            }),

            Layout = Roact.createElement("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            CreateButton = Roact.createElement(Button, {
                Style = "GameSettingsPrimaryButton",
                Text = buttonText,
                Size = UDim2.new(0, buttonTextExtents.X + theme.createButton.PaddingX,
                0, buttonTextExtents.Y + theme.createButton.PaddingY),
                LayoutOrder = 2,
                OnClick = function()
                    dispatchCreateNewDevProduct()
                end,
            }, {
                Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
            }),
        }),

        DeveloperProductTable = showTable and Roact.createElement(TableWithMenu, {
            Headers = headers,
            Data = productsList,
            MenuItems = menuItems,

            MenuItemsFilterFunc = function(rowData, menuItems)
                local id = rowData.row[1]
                if not tonumber(id) then
                    local indexToRemove
                    for i,v in pairs(menuItems) do
                        if v.Key == (GetCopyIdKeyName()) then
                            indexToRemove = i
                            break
                        end
                    end

                    menuItems[indexToRemove] = nil
                end
            end or nil,

            OnItemClicked = onItemClicked,
            LayoutOrder = 2,
            NextPageFunc = dispatchOnLoadMoreDevProducts,
        })
    })
end

ContextServices.mapToProps(DevProducts, {
    Localization = ContextServices.Localization,
    Theme = ContextServices.Theme,
})

return DevProducts