--[[
	Component that displays a SelectionBox with an arbitrary position and size,
	without having to create an adornee.

	Internally, StandaloneSelectionBox creates a transparent adornee with the
	correct position/size and parents it to CoreGui to prevent implementation
	details from leaking into the workspace.
]]

local CoreGui = game:GetService("CoreGui")

local DraggerFramework = script.Parent.Parent

local Library = DraggerFramework.Parent.Parent
local Roact = require(Library.Packages.Roact)

local StandaloneSelectionBox = Roact.PureComponent:extend("StandaloneSelectionBox")

function StandaloneSelectionBox:init()
	self._dummyPartRef = Roact.createRef()
end

function StandaloneSelectionBox:render()
	local container = self.props.Container or CoreGui

	return Roact.createElement(Roact.Portal, {
		target = container,
	}, {
		DummyPart = Roact.createElement("Part", {
			Shape = Enum.PartType.Block,
			Anchored = true,
			CanCollide = false,
			CFrame = self.props.CFrame,
			Size = self.props.Size,
			Transparency = 1,
			[Roact.Ref] = self._dummyPartRef,
		}),
		SelectionBox = Roact.createElement("SelectionBox", {
			Adornee = self._dummyPartRef,
			Color3 = self.props.Color,
			LineThickness = self.props.LineThickness,
			SurfaceTransparency = 1,
			Transparency = 0,
		})
	})
end

return StandaloneSelectionBox
