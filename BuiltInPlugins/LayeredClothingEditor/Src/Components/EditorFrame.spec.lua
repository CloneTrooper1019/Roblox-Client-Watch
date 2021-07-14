return function()
	local Plugin = script.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local SetEditingCage = require(Plugin.Src.Actions.SetEditingCage)
	local SetPointData = require(Plugin.Src.Actions.SetPointData)

	local Constants = require(Plugin.Src.Util.Constants)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local EditorFrame = require(script.Parent.EditorFrame)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(EditorFrame, {
			Size = UDim2.new(0, 100, 0, 100),
			LayoutOrder = 1,
		}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(EditorFrame, {
				Size = UDim2.new(0, 100, 0, 100),
				LayoutOrder = 1,
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")

				local EditingModeFrame = frame.EditingModeFrame
				local TransparencyView = frame.TransparencyView

				expect(frame).to.be.ok()
				expect(EditingModeFrame).to.be.ok()
				expect(TransparencyView).to.be.ok()
			end
		)
	end)

	it("should render correctly for CageType:Inner", function ()
		runComponentTest(
			Roact.createElement(EditorFrame, {
				Size = UDim2.new(0, 100, 0, 100),
				LayoutOrder = 1,
			}),
			function(container, store)
				store:dispatch(SetEditingCage(Enum.CageType.Inner))
				store:dispatch(SetPointData({{}}))
				wait()
				local frame = container:FindFirstChildOfClass("Frame")

				local EditingModeFrame = frame.EditingModeFrame
				local TransparencyView = frame.TransparencyView
				local TabsRibbon = frame.TabsRibbon
				local SettingView = frame.SettingView

				expect(frame).to.be.ok()
				expect(EditingModeFrame).to.be.ok()
				expect(TransparencyView).to.be.ok()
				expect(TabsRibbon).to.be.ok()
				expect(SettingView).to.be.ok()
			end
		)
	end)

	it("should render correctly for CageType:Outer", function ()
		runComponentTest(
			Roact.createElement(EditorFrame, {
				Size = UDim2.new(0, 100, 0, 100),
				LayoutOrder = 1,
			}),
			function(container, store)
				store:dispatch(SetEditingCage(Enum.CageType.Outer))
				store:dispatch(SetPointData({{}}))
				wait()
				local frame = container:FindFirstChildOfClass("Frame")

				local EditingModeFrame = frame.EditingModeFrame
				local TransparencyView = frame.TransparencyView
				local TabsRibbon = frame.TabsRibbon
				local SettingView = frame.SettingView

				expect(frame).to.be.ok()
				expect(EditingModeFrame).to.be.ok()
				expect(TransparencyView).to.be.ok()
				expect(TabsRibbon).to.be.ok()
				expect(SettingView).to.be.ok()
			end
		)
	end)

	it("should render correctly for EditMode:MeshPart", function ()
		runComponentTest(
			Roact.createElement(EditorFrame, {
				Size = UDim2.new(0, 100, 0, 100),
				LayoutOrder = 1,
			}),
			function(container, store)
				store:dispatch(SetEditingCage(Constants.EDIT_MODE.Mesh))
				wait()
				local frame = container:FindFirstChildOfClass("Frame")

				local EditingModeFrame = frame.EditingModeFrame
				local TransparencyView = frame.TransparencyView
				local MeshPartModeText = frame.MeshPartModeText

				expect(frame).to.be.ok()
				expect(EditingModeFrame).to.be.ok()
				expect(TransparencyView).to.be.ok()
				expect(MeshPartModeText).to.be.ok()
			end
		)
	end)
end