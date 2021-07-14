--[[
    PaidAccess is a wrapper around RadioButtonSet to display a Price config (field for price,
    label for fee, label for actual amount earned) between the "On" and "Off" buttons.

    Necessary props:
        Price = number, the initial price to be shown in the text field.
        TaxRate = number, the percentage of the price that is taken as a fee.
        MinimumFee = number, is the minimum fee that will be levied.
        Enabled = boolean, whether or not this component is enabled.
        Selected = boolean, "true" if On button should be selected, "false" if the off button should be selected.
        LayoutOrder = number, order in which this component should appear under its parent.

        OnPaidAccessToggle = function(button), this is a callback thta is invoked with the button info, when the radio button is toggled.
            example of button info:
            {
                Id = true,
                Title = "This is a foo button.",
                Description = "Lorem ipsum",
            }
        OnPaidAccessPriceChanged = function(price), this is a callback to be invoked when the price field changes values

    Optional props:
        PriceError = string, error message to be shown for this component
]]
local Page = script.Parent.Parent
local Plugin = script.Parent.Parent.Parent.Parent

local Cryo = require(Plugin.Cryo)
local Roact = require(Plugin.Roact)
local Framework = Plugin.Framework
local FitFrameOnAxis = require(Framework.Util).FitFrame.FitFrameOnAxis

local ContextServices = require(Plugin.Framework.ContextServices)

local UILibrary = require(Plugin.UILibrary)
local GetTextSize = UILibrary.Util.GetTextSize
local TitledFrame = UILibrary.Component.TitledFrame
local ToggleButton = UILibrary.Component.ToggleButton

local RobuxFeeBase = require(Page.Components.RobuxFeeBase)

local shouldDisablePrivateServersAndPaidAccess = require(Plugin.Src.Util.GameSettingsUtilities).shouldDisablePrivateServersAndPaidAccess

local PaidAccess = Roact.PureComponent:extend("PaidAccess")

local FFlagVIPServersRebrandToPrivateServers = game:GetFastFlag("VIPServersRebrandToPrivateServers")

function PaidAccess:render()
    -- Remove this block once economy team enables the double wallets workflow (see STUDIOCORE-24488 & STUDIOCORE-24576)
    if shouldDisablePrivateServersAndPaidAccess() then
        return nil
    end

    local props = self.props
    local localization = props.Localization
    local theme = props.Theme:get("Plugin")
    local mouse = props.Mouse

    local title = localization:getText("Monetization", "TitlePaidAccess")
    local priceTitle = localization:getText("Monetization", "PriceTitle")
    local price = props.Price and props.Price or 0
    local taxRate = props.TaxRate
    local minimumFee = props.MinimumFee
    local layoutOrder = props.LayoutOrder

    local enabled = props.Enabled
    local selected = props.Selected

    local onButtonToggled = props.OnPaidAccessToggle
    local onPaidAccessPriceChanged = props.OnPaidAccessPriceChanged

    local subText
    local priceError = props.PriceError
    if enabled and priceError then
        subText = priceError
    end

    local offSubtext
    if FFlagVIPServersRebrandToPrivateServers then
        offSubtext = localization:getText("Monetization", "PaidAccessHint")
    else
        offSubtext = localization:getText("Monetization", "DEPRECATED_PaidAccessHint")
    end

    local offSubTextSize = GetTextSize(offSubtext, theme.fontStyle.Subtext.TextSize, theme.fontStyle.Subtext.Font,
        Vector2.new(theme.robuxFeeBase.subText.width, math.huge))

    return Roact.createElement(FitFrameOnAxis, {
        axis = FitFrameOnAxis.Axis.Vertical,
        minimumSize = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,

        LayoutOrder = layoutOrder,
    }, {
        ToggleAndSubscriptionsAndTotal = Roact.createElement(TitledFrame, {
			Title = title,
            TextSize = theme.fontStyle.Title.TextSize,

            MaxHeight = theme.toggleButton.height + offSubTextSize.Y,

            LayoutOrder = 1,
		}, {
            UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
            }),

            ToggleButton = Roact.createElement(ToggleButton, {
                Enabled = enabled,
                IsOn = selected,
                Mouse = mouse:get(),

                onToggle = function(value)
                    if enabled then
                        onButtonToggled(value)
                    end
                end,

                LayoutOrder = 1,
            }),

            SubText = not selected and Roact.createElement("TextLabel", Cryo.Dictionary.join(theme.fontStyle.Subtext, {
                Size = UDim2.new(0, math.ceil(offSubTextSize.X), 0, offSubTextSize.Y),

                BackgroundTransparency = 1,

                Text = offSubtext,

                TextYAlignment = Enum.TextYAlignment.Center,
                TextXAlignment = Enum.TextXAlignment.Left,

                TextWrapped = true,

                LayoutOrder = 2,
            })),
        }),

        PriceConfigPaidOnly = selected and Roact.createElement(TitledFrame, {
            Title = priceTitle,

            TextSize = theme.fontStyle.Normal.TextSize,
            LayoutOrder = 2,
        },{
            RobuxFeeBase = Roact.createElement(RobuxFeeBase, {
                Price = price,
                TaxRate = taxRate,
                MinimumFee = minimumFee,
                SubText = subText,

                Enabled = enabled,

                OnPriceChanged = onPaidAccessPriceChanged,
            }),
        })
    })
end

ContextServices.mapToProps(PaidAccess, {
    Localization = ContextServices.Localization,
    Theme = ContextServices.Theme,
    Mouse = ContextServices.Mouse,
})

return PaidAccess