return function()
	local Framework = script.Parent.Parent.Parent
	local Roact = require(Framework.Parent.Roact)
	local TestHelpers = require(Framework.TestHelpers)
	local BulletList = require(script.Parent)

	local function createTestBulletList(props)
		props = props or {}
		props.Items = props.Items or {"one", "two", "three"}

		return TestHelpers.provideMockContext(nil, {
			BulletList = Roact.createElement(BulletList, props)
		})
	end

	it("should create and destroy without errors", function()
		local element = createTestBulletList()
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	describe("updates", function()

		it("should add Items without errors and set expected height", function()

			local container = Instance.new("Folder")
			local element = createTestBulletList()
			local instance = Roact.mount(element, container)

			local size1 = container:FindFirstChild("BulletList", true).Size

			Roact.update(instance, createTestBulletList({
				Items = {"one", "two", "three", "four"}
			}))

			local size2 = container:FindFirstChild("BulletList", true).Size

			expect(size2.X).to.equal(size1.X)
			expect(size2.Y.Offset > size1.Y.Offset).to.equal(true)

			Roact.unmount(instance)
		end)

		it("should remove Items without errors and set expected height", function()

			local container = Instance.new("Folder")
			local element = createTestBulletList()
			local instance = Roact.mount(element, container)

			local size1 = container:FindFirstChild("BulletList", true).Size

			Roact.update(instance, createTestBulletList({
				Items = {"one", "two"}
			}))

			local size2 = container:FindFirstChild("BulletList", true).Size

			expect(size2.X).to.equal(size1.X)
			expect(size2.Y.Offset < size1.Y.Offset).to.equal(true)

			Roact.unmount(instance)
		end)

	end)

	describe("elements as items", function()
		it("should render and use the height of the item to calculate the list height", function()

			local height = 10

			local container = Instance.new("Folder")

			local element = createTestBulletList({
				Items = {
					Roact.createElement("Frame", {
						Size = UDim2.new(1, 0, 1, height)
					})
				}
			})
			local instance = Roact.mount(element, container)

			local actualHeight = container:FindFirstChild("BulletList", true).Size.Y.Offset

			expect(actualHeight).to.equal(height)

			Roact.unmount(instance)
		end)
	end)
end
