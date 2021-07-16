return function()
	local Framework = script.Parent.Parent.Parent
	local Util = require(Framework.Util)
	local FlagsList = Util.Flags.new({
		FFlagStudioDevFrameworkPackage = {"StudioDevFrameworkPackage"},
	})
	local Roact = require(Framework.Parent.Roact)
	local RangeSlider = require(script.Parent)
	local TestHelpers = require(Framework.TestHelpers)
	local provideMockContext = TestHelpers.provideMockContext
	local Cryo
	local isUsedAsPackage = require(Framework.Util.isUsedAsPackage)
	if FlagsList:get("FFlagStudioDevFrameworkPackage") and isUsedAsPackage() then
		Cryo = require(Framework.Parent.Cryo)
	else
		local Util = require(Framework.Util)
		Cryo = Util.Cryo
	end

	local DEFAULT_PROPS = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Disabled = false,
		LowerRangeValue = 0,
		UpperRangeValue = 4,
		Min = 0,
		Max = 4,
		OnValuesChanged = function() end,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 200, 0, 20),
		SnapIncrement = 1,
		VerticalDragTolerance = 300,
	}

	local function createTestRangeSlider(props)
		local combinedProps = Cryo.Dictionary.join(DEFAULT_PROPS, props or {})
		return provideMockContext(nil, {
			RangeSlider = Roact.createElement(RangeSlider, combinedProps)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestRangeSlider()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render correctly", function()
		local container = Instance.new("Folder")
		local element = createTestRangeSlider()
		local instance = Roact.mount(element, container)

		local frame = container:FindFirstChildOfClass("Frame")
		expect(frame).to.be.ok()
		Roact.unmount(instance)
	end)

	it("should set the lower knob to the correct default value", function()
		local folder = Instance.new("Folder")
		local lowerValue = 1
		local max = 4
		local element = createTestRangeSlider({
			LowerRangeValue = lowerValue,
			UpperRangeValue = 4,
			Min = 0,
			Max = max,
		})
		local instance = Roact.mount(element, folder)

		local button = folder:FindFirstChildOfClass("Frame")
		expect(button.LowerKnob).to.be.ok()
		expect(button.LowerKnob.Position.X.Scale).to.equal(lowerValue/max)
		Roact.unmount(instance)
	end)

	it("should set the upper knob to the correct default value", function()
		local folder = Instance.new("Folder")
		local upperValue = 3
		local max = 4
		local element = createTestRangeSlider({
			LowerRangeValue = 0,
			UpperRangeValue = upperValue,
			Min = 0,
			Max = max,
		})
		local instance = Roact.mount(element, folder)

		local button = folder:FindFirstChildOfClass("Frame")
		expect(button.UpperKnob).to.be.ok()
		expect(button.UpperKnob.Position.X.Scale).to.equal(upperValue/max)
		Roact.unmount(instance)
	end)

	it("should throw if range is < 0", function()
		local element = createTestRangeSlider({
			Min = 0,
			Max = -1,
		})

		expect(function()
			Roact.mount(element)
		end).to.throw()
	end)
end