return function()
	local Plugin = script.Parent.Parent.Parent.Parent
	local Roact = require(Plugin.Packages.Roact)

	local TestRunner = require(Plugin.Src.Util.TestRunner)
	local runComponentTest = TestRunner.runComponentTest

	local ExplorerPreviewInstances = require(script.Parent.ExplorerPreviewInstances)
	it("should create and destroy without errors", function()
		runComponentTest(Roact.createElement(ExplorerPreviewInstances, {
			UserAddedAssets = {}
		}))
	end)

	it("should render correctly", function ()
		runComponentTest(
			Roact.createElement(ExplorerPreviewInstances, {
				UserAddedAssets = {}
			}),
			function(container)
				expect(game.Workspace.LayeredClothingEditorPreview).to.be.ok()
			end
		)
	end)
end