return function()
	local Library = script.Parent
	local Roact = require(Library.Parent.Parent.Roact)

	local workspace = game:GetService("Workspace")

	local UILibraryWrapper = require(script.Parent.UILibraryWrapper)

	local function createTestWrapper(props, children)
		return Roact.createElement(UILibraryWrapper, props, children)
	end

	it("should create and destroy without errors", function()
		local element = createTestWrapper()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should render its children if nothing is provided", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestWrapper({}, {
			Frame = Roact.createElement("Frame")
		}), container)

		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame).to.be.ok()

		Roact.unmount(instance)
	end)

	it("should render its children if items are provided", function ()
		local container = Instance.new("Folder")
		local instance = Roact.mount(createTestWrapper({
			theme = {},
			focusGui = {},
			plugin = {},
		}, {
			Frame = Roact.createElement("Frame")
		}), container)

		local frame = container:FindFirstChildOfClass("Frame")

		expect(frame).to.be.ok()

		Roact.unmount(instance)
	end)

	describe("addProvider", function()
		it("should place the new provider above the root", function ()
			local container = Instance.new("Folder")
			local root = Roact.createElement("Frame")

			local result = UILibraryWrapper:addProvider(root, "Frame")
			local instance = Roact.mount(result, container)
			local frame = container:FindFirstChildOfClass("Frame")

			expect(frame).to.be.ok()
			expect(frame[1]).to.be.ok()

			Roact.unmount(instance)
		end)

		it("should not modify the tree below the root", function ()
			local container = Instance.new("Folder")
			local root = Roact.createElement("Frame", {}, {
				ChildFrame = Roact.createElement("Frame", {}, {
					DescendantFrame = Roact.createElement("Frame"),
				}),
				OtherChild = Roact.createElement("Frame"),
			})

			local result = UILibraryWrapper:addProvider(root, "Frame")
			local instance = Roact.mount(result, container)
			local frame = container:FindFirstChildOfClass("Frame")

			expect(frame).to.be.ok()
			expect(frame[1]).to.be.ok()
			expect(frame[1].ChildFrame).to.be.ok()
			expect(frame[1].ChildFrame.DescendantFrame).to.be.ok()
			expect(frame[1].OtherChild).to.be.ok()

			Roact.unmount(instance)
		end)
	end)
end