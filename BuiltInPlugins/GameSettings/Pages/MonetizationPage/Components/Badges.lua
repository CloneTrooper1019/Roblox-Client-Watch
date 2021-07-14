local Plugin = script.Parent.Parent.Parent.Parent

local Roact = require(Plugin.Roact)
local Badges = Roact.PureComponent:extend(script.Name)

local Framework = Plugin.Framework
local UILibrary = require(Plugin.UILibrary)
local TitledFrame = UILibrary.Component.TitledFrame

local FrameworkUI = require(Framework.UI)
local Button = FrameworkUI.Button
local HoverArea = FrameworkUI.HoverArea
local ContextServices = require(Framework.ContextServices)
local FitFrameOnAxis = require(Framework.Util).FitFrame.FitFrameOnAxis
local TableWithMenu = require(Plugin.Src.Components.TableWithMenu)

local TextService = game:GetService("TextService")
local StudioService = game:GetService("StudioService")
local GuiService = game:GetService("GuiService")

local KeyProvider = require(Plugin.Src.Util.KeyProvider)
local GetCopyIdKeyName = KeyProvider.getCopyIdKeyName
local GetConfigureKeyName = KeyProvider.getConfigureKeyName

local ShouldAllowBadges = require(Plugin.Src.Util.GameSettingsUtilities).shouldAllowBadges

function Badges:render()
    if not ShouldAllowBadges() then 
        return nil
    end
    
    local props = self.props
    local theme = props.Theme:get("Plugin")
    local localization = props.Localization

    local badgeList = props.BadgeList
    local dispatchOnLoadMoreBadges = props.OnLoadMoreBadges
    local dispatchRefreshBadges = props.RefreshBadges
   
    local layoutOrder = props.LayoutOrder

    local buttonText = localization:getText("General", "ButtonCreate")
    local buttonTextExtents = TextService:GetTextSize(buttonText, theme.fontStyle.Normal.TextSize, theme.fontStyle.Normal.Font, 
        Vector2.new(math.huge, math.huge))

    local headers = {
        localization:getText("Monetization", "BadgeImage"),
        localization:getText("Monetization", "BadgeName"),
        localization:getText("Monetization", "BadgeDescription"),
    }
    
    -- Text to display on table if theres no badges
    local emptyText = localization:getText("Monetization", "NoBadges")

    return Roact.createElement(FitFrameOnAxis, {
        axis = FitFrameOnAxis.Axis.Vertical,
        minimumSize = UDim2.new(1, 0, 0, 0),
        contentPadding = UDim.new(0, theme.badges.headerPadding),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder,
    }, {
        BadgesTitle = Roact.createElement(TitledFrame,{
            Title = localization:getText("Monetization", "Badges"),
            LayoutOrder = 1,
            MaxHeight = theme.header.height,
            TextSize = theme.fontStyle.Title.TextSize,
        },{
            Padding = Roact.createElement("UIPadding", {
                PaddingRight = UDim.new(0, theme.badges.titlePadding)
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
                OnClick = function()
                    local url = StudioService:GetBadgeUploadUrl()
                    if url and string.len(url) > 0 then
                        GuiService:OpenBrowserWindow(url)
                    else
                        error("Failed to open Badge Creation page")
                    end
                end,
            }, {
                Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
            }),
        }),

        BadgesTable =  Roact.createElement(TableWithMenu, {
            Headers = headers,
            Data = badgeList,
            TableHeight = theme.table.height/2,
            LayoutOrder = 2,
            NextPageFunc = dispatchOnLoadMoreBadges,
            ScrollingFrameNextPageRequestDistance = 200,
            EmptyText = emptyText,
            ShowTableBackground = true,


            MenuItems = {
                {Key = GetCopyIdKeyName(), Text = localization:getText("General", GetCopyIdKeyName())},
                {Key = GetConfigureKeyName(), Text = localization:getText("General", GetConfigureKeyName()),}
            },

            OnItemClicked = function(key, id)
                if key == GetCopyIdKeyName() then
                    StudioService:CopyToClipboard(id)
                elseif key == GetConfigureKeyName() then
                    local url = StudioService:GetBadgeConfigureUrl(id)
                    if url and string.len(url) > 0 then
                        GuiService:OpenBrowserWindow(url)
                    else
                        error("Failed to open Badge Configuration page")
                    end
                else
                    assert(false)
                end
            end,

            HeaderButton = Roact.createElement("ImageButton", {
                BackgroundTransparency = 1,
                Image = theme.badges.refreshButton.icon,
                Size = UDim2.new( 0, theme.badges.refreshButton.size, 0, theme.badges.refreshButton.size),
                Position = UDim2.new(.5, theme.badges.refreshButton.offset.x, .5, 0),
                AnchorPoint = Vector2.new(.5, .5),
                [Roact.Event.Activated] = dispatchRefreshBadges,
            }, { 
                Roact.createElement(HoverArea, {Cursor = "PointingHand"}),
            })
        })
    })
end

ContextServices.mapToProps(Badges, {
    Localization = ContextServices.Localization,
    Theme = ContextServices.Theme,
})

return Badges
