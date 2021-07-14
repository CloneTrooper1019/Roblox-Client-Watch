-- DEPRECATED: This story is provided for backwards compatibility with horsecat and will be removed.
-- Please only make changes to `src\Stories\Private\Core\Animation\SpinningImage.story.lua`

local CoreRoot = script.Parent.Parent
local UIBlox = CoreRoot.Parent
local Packages = UIBlox.Parent

local Roact = require(Packages.Roact)

local Images = require(UIBlox.App.ImageSet.Images)

local SpinningImage = require(script.Parent.SpinningImage)

local SpinningImageStory = Roact.PureComponent:extend("SpinningImageStory")

function SpinningImageStory:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		Layout = Roact.createElement("UIListLayout"),
		Spinner1 = Roact.createElement(SpinningImage, {
			image = Images["icons/graphic/loadingspinner"],
			rotationRate = -720,
		}),
		Spinner2 = Roact.createElement(SpinningImage, {
			image = Images["icons/graphic/loadingspinner"],
			rotationRate = -360,
		}),
		Spinner3 = Roact.createElement(SpinningImage, {
			image = Images["icons/graphic/loadingspinner"],
			rotationRate = 0,
		}),
		Spinner4 = Roact.createElement(SpinningImage, {
			image = Images["icons/graphic/loadingspinner"],
		}),
		Spinner5 = Roact.createElement(SpinningImage, {
			image = Images["icons/graphic/loadingspinner"],
			rotationRate = 720,
		}),
	})
end

return function(target)
	local handle = Roact.mount(Roact.createElement(SpinningImageStory), target, "SpinningImageContainer")

	return function()
		Roact.unmount(handle)
	end
end