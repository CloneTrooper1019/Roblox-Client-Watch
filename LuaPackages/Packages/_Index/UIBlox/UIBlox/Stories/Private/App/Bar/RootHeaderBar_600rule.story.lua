local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local HeaderBar = require(App.Bar.HeaderBar)

return {
	name = "HeaderBar",
	summary =
	"On landscape, if the screen height is 600pt or less " ..
	"the Common Header Bar is used instead of Root Header Bar!",
	stories = {
		Over_600 = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(550, 45),
		}, {
			headerBar = Roact.createElement(HeaderBar, {
				name = "600+",
				renderLeft = nil,
			}),
		}),
		Under_600 = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(550, 45),
		}, {
			headerBar = Roact.createElement(HeaderBar, {
				name = "600-",
				renderLeft = function()
					return nil
				end,
			}),
		}),
	}
}
