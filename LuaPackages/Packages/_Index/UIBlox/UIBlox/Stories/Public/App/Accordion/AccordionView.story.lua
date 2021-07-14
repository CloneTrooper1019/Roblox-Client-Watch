local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local UIBlox = Packages.UIBlox
local withStyle = require(UIBlox.Style.withStyle)
local AccordionView = require(UIBlox.App.Accordion.AccordionView)

local testImages = {
	-- The 1st image is transparent.
	"http://www.roblox.com/asset/?id=2583107839",
	"http://www.roblox.com/asset/?id=410689385",
	"http://www.roblox.com/asset/?id=410690022",
	"http://www.roblox.com/asset/?id=410689825",
	"http://www.roblox.com/asset/?id=410689711",
}

local function Story()
	return withStyle(function(style)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 400),
			BackgroundTransparency = 1,
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 20),
			}),
			Accordion = Roact.createElement(AccordionView, {
				LayoutOrder = 2,
				items = testImages,
				itemWidth = 355,
				itemHeight = 188,
				renderItem = function(item, transparency)
					return Roact.createElement("ImageButton", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.fromRGB(57, 59, 61),
						BackgroundTransparency = 0.5,
						BorderSizePixel = 0,
						Image = item,
						ImageTransparency = transparency,
						AutoButtonColor = false,
					})
				end,
				placeholderColor = Color3.fromRGB(255, 255, 255),
				placeholderBaseTransparency = 0.5,
				collapseButtonSize = 40,
				renderCollapseButton = function(activatedCallback)
					return Roact.createElement("ImageButton", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						Image = "rbxassetid://48657647",
						AutoButtonColor = false,
						[Roact.Event.Activated] = activatedCallback,
					})
				end,
			}),
			SomeFooterText = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Text = "Test AccordionView Footer.\nThis should not move when the Accordion shrinks.",
				TextColor3 = style.Theme.TextDefault.Color,
			}),
		})
	end)
end

return Story
