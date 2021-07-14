local RobloxReplicatedStorage = game:GetService("RobloxReplicatedStorage")
local ContextMenuItems = require(script.Parent.ContextMenuItems)

local CoreGuiService = game:GetService("CoreGui")
local RobloxGui = CoreGuiService:WaitForChild("RobloxGui")
local CoreGuiModules = RobloxGui:WaitForChild("Modules")

local FFlagAvatarContextMenuItemsChatButtonRefactor = require(CoreGuiModules.Flags.FFlagAvatarContextMenuItemsChatButtonRefactor)
local FFlagInspectMenuSubjectToPolicy = require(CoreGuiModules.Flags.FFlagInspectMenuSubjectToPolicy)

return function()
	-- Returns a frame with context menu items as children.
	local function makeContextMenuItemsFrame(props)
		local parentFrame = Instance.new("Frame")
		local contextMenuItems = ContextMenuItems.new(parentFrame)

		if not RobloxReplicatedStorage:FindFirstChild("SetPlayerBlockList") then
			local mockEvent = Instance.new("RemoteEvent")
			mockEvent.Name = "SetPlayerBlockList"
			mockEvent.Parent = RobloxReplicatedStorage
		end
		
		local mockPlayer = {
			UserId = 0,
		}
		
		contextMenuItems:BuildContextMenuItems(mockPlayer, props)
		return parentFrame
	end

	local function makeContextMenuButtons(props)
		if props == nil then
			props = {
				localPlayerChatEnabled = true,
				localPlayerCanChatWithSelectedPlayer = true,
			}
		end
		local menuItemsFrame = makeContextMenuItemsFrame(props)
		local buttons = menuItemsFrame:GetChildren()
		return buttons
	end

	describe("Avatar Context Menu Buttons Appearance", function()
		if not FFlagAvatarContextMenuItemsChatButtonRefactor then
			SKIP()
		end

		it("should have the same font for all buttons with center alignment", function()
			local buttons = makeContextMenuButtons()
			local font = nil
			for _, button in ipairs(buttons) do
				local buttonLabel = button:FindFirstChildWhichIsA("TextLabel")
				expect(buttonLabel).to.be.ok()
				expect(buttonLabel.Font).to.be.ok()
				if font == nil then
					font = buttonLabel.Font
				else
					expect(font).never.to.equal(nil)
					expect(buttonLabel.Font).to.equal(font)
					expect(buttonLabel.TextXAlignment).to.equal(Enum.TextXAlignment.Center)
					expect(buttonLabel.TextYAlignment).to.equal(Enum.TextYAlignment.Center)
				end
			end
		end)

		it("all buttons should have white text color", function()
			local buttons = makeContextMenuButtons()
			local whiteColor = Color3.fromRGB(255,255,255)

			for _, button in ipairs(buttons) do
				local buttonLabel = button:FindFirstChildWhichIsA("TextLabel")
				expect(buttonLabel).to.be.ok()
				expect(buttonLabel.TextColor3).to.equal(whiteColor)
			end
		end)

		it("should have 3 default buttons: Friend, Chat, Wave. Also 'View/inspect' if FFlagInspectMenuSubjectToPolicy==false.", function()
			local props = {
				localPlayerChatEnabled = true,
				localPlayerCanChatWithSelectedPlayer = true,
			}
			local menuItemsFrame = makeContextMenuItemsFrame(props)
			local buttons = menuItemsFrame:GetChildren()

			local buttonNames = {"Wave", "ChatStatus", "FriendStatus"}
			if not FFlagInspectMenuSubjectToPolicy then
				table.insert(buttonNames, "View")
			end
			expect(#buttons).to.equal(#buttonNames)

			for _, name in ipairs(buttonNames) do
				expect(menuItemsFrame:FindFirstChild(name)).to.be.ok()
			end
		end)
	end)
end