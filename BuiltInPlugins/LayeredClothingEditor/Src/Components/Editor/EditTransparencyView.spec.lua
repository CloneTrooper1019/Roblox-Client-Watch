return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local EditTransparencyView = require(script.Parent.EditTransparencyView)
	local SetEditingCage = require(Plugin.Src.Actions.SetEditingCage)

	local function createEditTransparencyView()
		return Roact.createElement(EditTransparencyView)
	end

	it("should mount and unmount", function()
		runComponentTest(createEditTransparencyView())
	end)

	it("should render correctly", function ()
		runComponentTest(
			createEditTransparencyView(),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local Layout = frame.Layout
				local Mesh = frame.Mesh
				expect(frame).to.be.ok()
				expect(Layout).to.be.ok()
				expect(Mesh).to.be.ok()
			end
		)
	end)

	it("should show inner cage slider if editing inner cage", function ()
		runComponentTest(
			createEditTransparencyView(),
			function(container, store)
				store:dispatch(SetEditingCage(Enum.CageType.Inner))
				wait()
				local frame = container:FindFirstChildOfClass("Frame")
				local Layout = frame.Layout
				local Mesh = frame.Mesh
				local InnerCage = frame.InnerCage
				expect(frame).to.be.ok()
				expect(Layout).to.be.ok()
				expect(Mesh).to.be.ok()
				expect(InnerCage).to.be.ok()
			end
		)
	end)

	it("should show outer cage slider if editing outer cage", function ()
		runComponentTest(
			createEditTransparencyView(),
			function(container, store)
				store:dispatch(SetEditingCage(Enum.CageType.Outer))
				wait()
				local frame = container:FindFirstChildOfClass("Frame")
				local Layout = frame.Layout
				local Mesh = frame.Mesh
				local OuterCage = frame.OuterCage
				expect(frame).to.be.ok()
				expect(Layout).to.be.ok()
				expect(Mesh).to.be.ok()
				expect(OuterCage).to.be.ok()
			end
		)
	end)

end