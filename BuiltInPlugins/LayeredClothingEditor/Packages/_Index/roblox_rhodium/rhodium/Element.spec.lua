return function()
	local XPath = require(script.Parent.XPath)
	local Element = require(script.Parent.Element)

	local function makeInstance(className, props, children)
		local instance = Instance.new(className)
		if children then
			for _, child in ipairs(children) do
				child.Parent = instance
			end
		end
		if props then
			for k, v in pairs(props) do
				instance[k] = v
			end
		end
		return instance
	end

	local root = makeInstance("Folder",
			{
				Name = "root",
				Parent = workspace
			}, {
				makeInstance("Frame", {Name = "Frame"}, {
					makeInstance("TextLabel", {
						Text = "Label1"
					}),
				}),
		})

	describe("element creation", function()
		it("valid element creation", function()
			local path = XPath.new("game.Workspace.root.Frame[.TextButton.Text = Button2, .ClassName = Frame]")
			local validElement = Element.new(path:cat(XPath.new("TextLabel")))

			expect(validElement:getRbxInstance()).to.be.ok()
		end)
		it("invalid element creation", function()
			local path = XPath.new("game.Workspace.root.Frame[.TextButton.Text = Button2, .ClassName = Frame]")
			local invalidElement = Element.new(path:cat(XPath.new("TextLabel2")))

			expect(invalidElement:getRbxInstance()).to.never.be.ok()
		end)
	end)
end
