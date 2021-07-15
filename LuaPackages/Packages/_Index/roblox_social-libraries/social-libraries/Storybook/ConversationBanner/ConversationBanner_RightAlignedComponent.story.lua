local SocialLibraries = script:FindFirstAncestor("social-libraries")
local dependencies = require(SocialLibraries.dependencies)

local Roact = dependencies.Roact

local ConversationCell = require(SocialLibraries.Components.Cells.ConversationCell)

return Roact.createElement("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 512, 0, 96),
}, {
	Roact.createElement(ConversationCell, {
		thumbnails = {
			"rbxassetid://2610133241",
		},
	}, {
		rightAlignedComponent = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.new(1,0,0),
			Size = UDim2.new(0, 64, 1, 0),
		})
	})
})
