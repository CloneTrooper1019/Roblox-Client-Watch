local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local Images = require(App.ImageSet.Images)
local LoadingSpinner = Images["icons/graphic/loadingspinner"]

local Core = Packages.UIBlox.Core
local SpinningImage = require(Core.Animation.SpinningImage)

return {
	stories = {
		Default = Roact.createElement(SpinningImage, {
			image = LoadingSpinner,
		}),
		Rot_720 = Roact.createElement(SpinningImage, {
			image = LoadingSpinner,
			rotationRate = 720,
		}),
		Rot_0 = Roact.createElement(SpinningImage, {
			image = LoadingSpinner,
			rotationRate = 0,
		}),
		Rot_Negative360 = Roact.createElement(SpinningImage, {
			image = LoadingSpinner,
			rotationRate = -360,
		}),
		Rot_Negative720 = Roact.createElement(SpinningImage, {
			image = LoadingSpinner,
			rotationRate = -720,
		}),
	}
}