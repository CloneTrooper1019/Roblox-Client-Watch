return function()
	local Menu = script.Parent
	local App = Menu.Parent
	local UIBlox = App.Parent
	local Roact = require(UIBlox.Parent.Roact)
	local mockStyleComponent = require(UIBlox.Utility.mockStyleComponent)
	local Images = require(UIBlox.App.ImageSet.Images)
	local UIBloxConfig = require(UIBlox.UIBloxConfig)

	local DropdownMenu = require(script.Parent.DropdownMenu)

	describe("lifecycle", function()
		it("should mount and unmount without issue with only required props", function()
			local element = mockStyleComponent({
				DropdownMenu = Roact.createElement(DropdownMenu, {
					placeholder = "Placeholder Text",
					onChange = print,
					size = (not UIBloxConfig.fixDropdownMenuListPositionAndSize)
						and UDim2.new(0,250,0,48) or nil,
					height = UIBloxConfig.fixDropdownMenuListPositionAndSize
						and UDim.new(0,48) or nil,
					screenSize = Vector2.new(500,500),
					cellDatas = {
						{
							text = "Item 1",
						},
						{
							text = "Item 2",
						}
					}
				}),
			})

			local folder = Instance.new("Folder")
			local instance = Roact.mount(element, folder)

			Roact.unmount(instance)
			folder:Destroy()
		end)

		it("should mount and unmount without issue with all props", function()
			local element = mockStyleComponent({
				DropdownMenu = Roact.createElement(DropdownMenu, {
					placeholder = "Placeholder Text",
					errorState = false,
					isDisabled = true,
					onChange = print,
					size = (not UIBloxConfig.fixDropdownMenuListPositionAndSize)
						and UDim2.new(0,250,0,48) or nil,
					height = UIBloxConfig.fixDropdownMenuListPositionAndSize
						and UDim.new(0,48) or nil,
					screenSize = Vector2.new(500,500),
					cellDatas = {
						{
							text = "Item 1",
							icon = Images["component_assets/circle_17_stroke_1"],
							disabled = false,
							-- A KeyCode to display a keycode hint for, the display string based on the users keyboard is displayed.
							keyCodeLabel = Enum.KeyCode.Up,

							iconColorOverride = Color3.new(0,0,0),
							textColorOverride = Color3.new(0,0,0),
						},
						{
							text = "Item 2",
							icon = Images["component_assets/circle_17_stroke_1"],
							disabled = false,
							-- A KeyCode to display a keycode hint for, the display string based on the users keyboard is displayed.
							keyCodeLabel = Enum.KeyCode.Up,

							iconColorOverride = Color3.new(0,0,0),
							textColorOverride = Color3.new(0,0,0),
						}
					}
				}),
			})

			local folder = Instance.new("Folder")
			local instance = Roact.mount(element, folder)

			Roact.unmount(instance)
			folder:Destroy()
		end)

	end)
end