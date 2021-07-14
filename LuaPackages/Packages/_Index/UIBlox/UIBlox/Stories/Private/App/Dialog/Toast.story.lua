local Packages = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Roact = require(Packages.Roact)

local App = Packages.UIBlox.App
local Images = require(App.ImageSet.Images)
local ToastContainer = require(App.Dialog.Toast.ToastContainer)
local InformativeToast = require(App.Dialog.Toast.InformativeToast)
local InteractiveToast = require(App.Dialog.Toast.InteractiveToast)

return {
	stories = {
		Informative = Roact.createElement(ToastContainer, {
			anchorPoint = Vector2.new(0.5, 0),
			iconImage = Images["icons/status/warning"],
			position = UDim2.new(0.5, 0, 0, 20),
			renderToast = function(props)
				return Roact.createElement(InformativeToast, props)
			end,
			toastSubtitle = "Some details here",
			toastTitle = "Title Case",
		}),
		Interactive = Roact.createElement(ToastContainer, {
			anchorPoint = Vector2.new(0.5, 0),
			iconImage = Images["icons/status/warning"],
			onActivated = function() end,
			position = UDim2.new(0.5, 0, 0, 20),
			renderToast = function(props)
				return Roact.createElement(InteractiveToast, props)
			end,
			toastSubtitle = "Some details here",
			toastTitle = "Title Case",
		})
	}
}