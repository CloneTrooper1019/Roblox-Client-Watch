local Library = script.Parent

local Roact = require(Library.Parent.Parent.Roact)
local Symbol = require(Library.Utils.Symbol)
local cameraKey = Symbol.named("MarketplaceCamera")

local CameraProvider = Roact.PureComponent:extend("CameraProvider")

function CameraProvider:init(prop)
    local camera = Instance.new("Camera")
    camera.Name = "MarketplaceCamera"

    self._context[cameraKey] = camera
end

function CameraProvider:render()
    return Roact.oneChild(self.props[Roact.Children])
end

local function getCamera(component)
    assert(component._context[cameraKey] ~= nil, "No CameraProvider Found")
    local camera = component._context[cameraKey]
    return camera
end

return {
    Provider = CameraProvider,
    getCamera = getCamera,
}