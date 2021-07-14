local Keyboard = require(script.Parent.InputTypes.Keyboard)
local Mouse = require(script.Parent.InputTypes.Mouse)
local Touch = require(script.Parent.InputTypes.Touch)
local Text = require(script.Parent.InputTypes.Text)
local GamePad = require(script.Parent.InputTypes.GamePad)

local VirtualInputUtils = require(script.Parent.VirtualInputUtils)

local VirtualInput = {
    Keyboard = Keyboard,
    Mouse = Mouse,
    Touch = Touch,
    Text = Text,
    GamePad = GamePad,

    setCurrentWindow = VirtualInputUtils.setCurrentWindow,
    getCurrentWindow = VirtualInputUtils.getCurrentWindow,
}

return VirtualInput