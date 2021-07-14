return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local Constants = require(Plugin.Src.Util.Constants)
	local EditorSettingView = require(script.Parent.EditorSettingView)

	it("should mount and unmount", function()
		runComponentTest(Roact.createElement(EditorSettingView, {
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 1,
			ToolMode = Constants.TOOL_MODE.None,
		}))
	end)

	it("should render correctly for ToolMode:Reset", function ()
		runComponentTest(
			Roact.createElement(EditorSettingView, {
				Size = UDim2.new(1, 0, 1, 0),
				LayoutOrder = 1,
				ToolMode = Constants.TOOL_MODE.Reset,
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local ResetSettings = frame.ResetSettings

				expect(frame).to.be.ok()
				expect(ResetSettings).to.be.ok()
			end
		)
	end)

	it("should render correctly for ToolMode:Point", function ()
		runComponentTest(
			Roact.createElement(EditorSettingView, {
				Size = UDim2.new(1, 0, 1, 0),
				LayoutOrder = 1,
				ToolMode = Constants.TOOL_MODE.Point,
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local PointToolSettings = frame.PointToolSettings

				expect(frame).to.be.ok()
				expect(PointToolSettings).to.be.ok()
			end
		)
	end)

	it("should render correctly for ToolMode:Lattice", function ()
		runComponentTest(
			Roact.createElement(EditorSettingView, {
				Size = UDim2.new(1, 0, 1, 0),
				LayoutOrder = 1,
				ToolMode = Constants.TOOL_MODE.Lattice,
			}),
			function(container)
				local frame = container:FindFirstChildOfClass("Frame")
				local LatticeToolSettings = frame.LatticeToolSettings

				expect(frame).to.be.ok()
				expect(LatticeToolSettings).to.be.ok()
			end
		)
	end)

end