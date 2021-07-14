return function()
	local Framework = script.Parent.Parent.Parent
	local Util = require(Framework.Util)
	local FlagsList = Util.Flags.new({
		FFlagStudioDevFrameworkPackage = {"StudioDevFrameworkPackage"},
	})
	local Cryo
	local isUsedAsPackage = require(Framework.Util.isUsedAsPackage)
	if FlagsList:get("FFlagStudioDevFrameworkPackage") and isUsedAsPackage() then
		Cryo = require(Framework.Parent.Cryo)
	else
		Cryo = Util.Cryo
	end
	local Roact = require(Framework.Parent.Roact)
	local Slider = require(script.Parent)
	local TestHelpers = require(Framework.TestHelpers)
	local provideMockContext = TestHelpers.provideMockContext

	local DEFAULT_PROPS = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Disabled = false,
		OnValueChanged = function() end,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 200, 0, 20),
		SnapIncrement = 1,
		VerticalDragTolerance = 300,
	}

	local function createTestSlider(props)
		local combinedProps = Cryo.Dictionary.join(DEFAULT_PROPS, props or {})
		return provideMockContext(nil, {
			Slider = Roact.createElement(Slider, combinedProps)
		})
	end

	it("should render correctly and set the knob value", function()
		local container = Instance.new("Folder")
		local props = {
			Value = 3,
			Min = 0,
			Max = 4,
		}
		local element = createTestSlider(props)
		local instance = Roact.mount(element, container)

		local frame = container:FindFirstChildOfClass("Frame")
		expect(frame).to.be.ok()

		expect(frame:FindFirstChild("LowerKnob")).to.equal(nil)

		local knob = frame:FindFirstChild("UpperKnob")
		expect(knob).to.be.ok()
		expect(knob.Position.X.Scale).to.equal(props.Value/props.Max)

		Roact.unmount(instance)
	end)
end
