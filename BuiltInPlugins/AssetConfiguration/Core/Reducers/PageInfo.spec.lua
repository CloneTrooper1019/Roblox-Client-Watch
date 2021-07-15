return function()
	local FFlagToolboxRemoveGroupInventory2 = game:GetFastFlag("ToolboxRemoveGroupInventory2")

	local Plugin = script.Parent.Parent.Parent

	local PageInfoHelper = require(Plugin.Core.Util.PageInfoHelper)

	local Category = require(Plugin.Core.Types.Category)
	local RequestReason = require(Plugin.Core.Types.RequestReason)

	local SetToolboxManageableGroups = require(Plugin.Core.Actions.SetToolboxManageableGroups)
	local UpdatePageInfo = require(Plugin.Core.Actions.UpdatePageInfo)

	local PageInfo = require(Plugin.Core.Reducers.PageInfo)

	local function tableLength(tbl)
		local i = 0
		for _ in pairs(tbl) do
			i = i + 1
		end
		return i
	end

	it("should return a table with the correct members", function()
		local state = PageInfo(nil, {})

		expect(type(state)).to.equal("table")
		expect(state.categories).to.be.ok()
		expect(state.categoryName).to.be.ok()
		expect(state.searchTerm).to.be.ok()
		expect(state.sorts).to.be.ok()
		expect(state.sortIndex).to.be.ok()
		expect(state.groups).to.be.ok()
		expect(state.groupIndex).to.be.ok()
		expect(state.currentPage).to.be.ok()
	end)

	describe("SetToolboxManageableGroups action", function()
		it("should set the groups", function()
			local state = PageInfo(nil, {})
			expect(tableLength(state.groups)).to.equal(0)

			local testGroups = {
				{id = 12345, name = "Test1"},
				{id = 67890, name = "Test2"},
			}

			state = PageInfo(state, SetToolboxManageableGroups(testGroups))

			expect(tableLength(state.groups)).to.equal(#testGroups)

			for index, testGroup in ipairs(testGroups) do
				expect(state.groups[index].id).to.equal(testGroup.id)
				expect(state.groups[index].name).to.equal(testGroup.name)
			end
		end)

		it("should overwrite previously set groups", function()
			local state = PageInfo(nil, {})
			expect(tableLength(state.groups)).to.equal(0)

			local testGroups = {
				{id = 12345, name = "Test1"},
				{id = 67890, name = "Test2"},
			}

			state = PageInfo(state, SetToolboxManageableGroups(testGroups))

			expect(tableLength(state.groups)).to.equal(#testGroups)

			local nextTestGroups = {
				{id = 13579, name = "Test3"},
				{id = 24680, name = "Test4"},
			}

			state = PageInfo(state, SetToolboxManageableGroups(nextTestGroups))

			expect(tableLength(state.groups)).to.equal(#nextTestGroups)

			for index, testGroup in ipairs(nextTestGroups) do
				expect(state.groups[index].id).to.equal(testGroup.id)
				expect(state.groups[index].name).to.equal(testGroup.name)
			end
		end)

		if not FFlagToolboxRemoveGroupInventory2 then
			-- TODO: Fix me and make me a smaller unit test.
			-- DEVTOOLS-2937
			itSKIP("should update the categories and group index+id if necessary", function()
				local state = PageInfo(nil, {})

				-- SetCategories is removed, but this test is skipped anyway.
				local SetCategories = nil -- Silence warning caused by roblox-cli. Delete this line along with the fix for this unit test.
				state = PageInfo(state, SetCategories(Category.INVENTORY_KEY, Category.INVENTORY))
				expect(state.categories).to.equal(Category.INVENTORY)
				expect(state.groupIndex).to.equal(0)
				expect(PageInfoHelper.getGroupIdForPageInfo(state)).to.equal(0)

				local firstTestGroups = {
					{id = 12345, name = "Test1"},
					{id = 67890, name = "Test2"},
				}
				state = PageInfo(state, SetToolboxManageableGroups(firstTestGroups))

				expect(state.categories).to.equal(Category.INVENTORY_WITH_GROUPS)

				-- First time we have groups so set groupIndex to 1
				expect(state.groupIndex).to.equal(1)
				expect(PageInfoHelper.getGroupIdForPageInfo(state)).to.equal(firstTestGroups[state.groupIndex].id)

				-- Change the groups list
				-- Previous selected group id stil exists in new array
				-- So index should change to where it is
				local secondTestGroups = {
					{id = 13579, name = "Test3"},
					{id = 12345, name = "Test1"},
					{id = 24680, name = "Test4"},
				}
				state = PageInfo(state, SetToolboxManageableGroups(secondTestGroups))

				expect(state.categories).to.equal(Category.INVENTORY_WITH_GROUPS)
				expect(state.groupIndex).to.equal(2)
				expect(PageInfoHelper.getGroupIdForPageInfo(state)).to.equal(secondTestGroups[state.groupIndex].id)

				local groupModelsCategoryIndex = 6
				local groupModelsCategoryName = Category.INVENTORY_WITH_GROUPS[groupModelsCategoryIndex].categoryName

				state = PageInfo(state, UpdatePageInfo({
					categoryName = groupModelsCategoryName,
					category = Category.INVENTORY_WITH_GROUPS[groupModelsCategoryIndex].category
				}))
				expect(state.categoryName).to.equal(groupModelsCategoryName)

				-- Clear the groups list
				local thirdTestGroups = {}
				state = PageInfo(state, SetToolboxManageableGroups(thirdTestGroups))

				-- Categories list should remove groups
				expect(state.categories).to.equal(Category.INVENTORY)

				-- Category should be reset to "" because the groups categories now don't exist
				expect(state.categoryName).to.equal("")

				-- Group index and id should be reset to 0
				expect(state.groupIndex).to.equal(0)
				expect(PageInfoHelper.getGroupIdForPageInfo(state)).to.equal(0)
			end)
		end
	end)

	describe("UpdatePageInfo action", function()
		it("should update the info", function()
			local state = PageInfo(nil, {})

			expect(state.categoryName).to.equal(Category.FREE_MODELS.name)
			expect(state.sortIndex).to.equal(1)

			state = PageInfo(state, UpdatePageInfo({
				categoryName = state.categories[2].categoryName,
				category = state.categories[2].category
			}))

			expect(state.category).to.equal(state.categories[2].category)
		end)

		it("should generate a new searchId if RequestReason is not Update", function()
			local state = PageInfo(nil, {})

			expect(state.searchId).to.equal(nil)

			state = PageInfo(state, UpdatePageInfo({}))

			local originalSearchId = state.searchId
			expect(type(originalSearchId)).to.equal("string")

			state = PageInfo(state, UpdatePageInfo({
				requestReason = RequestReason.NextPage
			}))
			expect(state.searchId).to.equal(originalSearchId)

			state = PageInfo(state, UpdatePageInfo({
				requestReason = RequestReason.UpdatePage
			}))
			expect(state.searchId).to.equal(originalSearchId)

			state = PageInfo(state, UpdatePageInfo({
				requestReason = RequestReason.StartSearch
			}))
			expect(state.searchId).to.never.equal(originalSearchId)
		end)
	end)
end
