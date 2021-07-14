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

local getFFlagFixScalingToolBoundingBoxForLargeModels = require(DraggerFramework.Flags.getFFlagFixScalingToolBoundingBoxForLargeModels)

function StandaloneSelectionBox:init()
	self._dummyPartRef = Roact.createRef()
end

function StandaloneSelectionBox:render()
	local ones = Vector3.new(1, 1, 1)
	local dummyPartSize = self.props.Size:Min(ones)
	local dummyPartOffset = self.props.Size / 2 - dummyPartSize / 2
	local container = self.props.Container or CoreGui
	-- Fix for MOD-628
	if (getFFlagFixScalingToolBoundingBoxForLargeModels()) then
		return Roact.createElement(Roact.Portal, {
			target = container,
		}, {
			DummyModel = Roact.createElement("Model",{
				[Roact.Ref] = self._dummyPartRef,
			}, {
				DummyPart1 = Roact.createElement("Part", {
					Shape = Enum.PartType.Block,
					Anchored = true,
					CanCollide = false,
					CFrame = self.props.CFrame * CFrame.new(-dummyPartOffset),
					Size = dummyPartSize,
					Transparency = 0,
				}),
				DummyPart2 = Roact.createElement("Part", {
					Shape = Enum.PartType.Block,
					Anchored = true,
					CanCollide = false,
					CFrame = self.props.CFrame * CFrame.new(dummyPartOffset),
					Size = dummyPartSize,
					Transparency = 0,
				})
			}),
			SelectionBox = Roact.createElement("SelectionBox", {
				Adornee = self._dummyPartRef,
				Color3 = self.props.Color,
				LineThickness = self.props.LineThickness,
				SurfaceTransparency = 1,
				Transparency = 0,
			})
		})
	else
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
end

return StandaloneSelectionBox
