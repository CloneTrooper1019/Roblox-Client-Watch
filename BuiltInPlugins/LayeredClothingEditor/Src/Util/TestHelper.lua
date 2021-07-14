local Plugin = script.Parent.Parent.Parent
local Framework = require(Plugin.Packages.Framework)
local Rodux = require(Plugin.Packages.Rodux)

local Rhodium = require(Plugin.Packages.Dev.Rhodium)
local Element = Rhodium.Element
local XPath = Rhodium.XPath

local ContextServices = Framework.ContextServices
local Localization = ContextServices.Localization

local ItemCharacteristics = require(Plugin.Src.Util.ItemCharacteristics)

local MainReducer = require(Plugin.Src.Reducers.MainReducer)

local timeoutSeconds = 5

local TestHelper = {}

TestHelper.DefaultClothesName = "clothes"

local function delay()
	local TEST_DELAY_SECONDS = 0.1
	wait(TEST_DELAY_SECONDS)
end

function TestHelper.delay()
	delay()
end

function TestHelper.createTestStore()
	local middlewares = {Rodux.thunkMiddleware}
	return Rodux.Store.new(MainReducer, nil, middlewares)
end

function TestHelper.clickElement(element, repeatCount)
	element:click(repeatCount)
	delay()
end

function TestHelper.sendInputToXPath(xpath,inputValue)
	local element = TestHelper.clickXPath(xpath, 2)
	delay()
	element:sendKey(Enum.KeyCode.Backspace)
	delay()
	element:sendText(inputValue)
	delay()
	element:sendKey(Enum.KeyCode.Return)
	delay()
end

function TestHelper.clickEquippableGridTile(index)
	local gridScrollerChildPath = TestHelper.getEquippableGridTilePath(index)
	TestHelper.waitForXPathInstance(gridScrollerChildPath)

	local childTextButtonPath = gridScrollerChildPath:cat(XPath.new("Contents.TextButton"))
	TestHelper.waitForXPathInstance(childTextButtonPath)
	TestHelper.clickXPath(childTextButtonPath)
end

function TestHelper.getEquippableGridTilePath(index)
	local ScrollerPath = TestHelper.getMainScroller()
	local GridPath = ScrollerPath:cat(XPath.new("PreviewSwizzle.ViewArea.PreviewFrame.Grid"))
	local GridScrollerPath = GridPath:cat(XPath.new("ScrollingFrame.Contents.Scroller"))

	-- add 1 to index to get childIndex as the first equippable tile in the grid has child index 2, as the
	-- first tile in the grid is the add from explorer tile
	local childIndex = index + 1
	return GridScrollerPath:cat(XPath.new(tostring(childIndex)))
end

function TestHelper.getEquippableGridTileInstance(index)
	local gridScrollerChildPath = TestHelper.getEquippableGridTilePath(index)
	return TestHelper.waitForXPathInstance(gridScrollerChildPath)
end

function TestHelper.clickXPath(xpath, repeatCount)
	local element = Element.new(xpath)
	TestHelper.clickElement(element, repeatCount)
	return element
end

local function waitForValidFunctionWithTimeout(validFunc)
	local startTimeSeconds = os.time()
	while not validFunc() do
		if os.time() - startTimeSeconds > timeoutSeconds then
			return false
		end
		delay()
	end
	return true
end

function TestHelper.waitForValid(validFunc)
	return waitForValidFunctionWithTimeout(validFunc)
end

function TestHelper.waitForXPathInstance(xpath)
	local isValid = waitForValidFunctionWithTimeout(function()
		return xpath:getFirstInstance()
	end)
	if isValid then
		return xpath:getFirstInstance()
	else
		return nil
	end
end

local function getProperty(instance, property)
	local succeeded, result = pcall(function() return instance[property] end )
	return succeeded == true and result or nil
end

function TestHelper.waitForPropertyEqualTo(instance, property, expectValue)
	return waitForValidFunctionWithTimeout(function()
		return getProperty(instance,property) == expectValue
	end)
end

function TestHelper.waitForChildrenCountEqualTo(instance, expectValue)
	return waitForValidFunctionWithTimeout(function()
		return #instance:GetChildren() == expectValue
	end)
end

function TestHelper.getMainScroller()
	return XPath.new("game.CoreGui.PluginMockGui.LayeredClothingEditor.MainFrame.Contents.Scroller")
end

function TestHelper.cleanTempInstances()
	local tempInstancesFolder = TestHelper.getTempInstancesFolder()
	if tempInstancesFolder then
		tempInstancesFolder:Destroy()
	end

	local tempScreenGui = TestHelper.getTempScreenGui()
	if tempScreenGui then
		tempScreenGui:Destroy()
	end
end

function TestHelper.getTempInstancesFolder()
	local tempInstancesFolderName = "TempInstancesFolder"
	local tempInstancesFolder = workspace:FindFirstChild(tempInstancesFolderName)
	if tempInstancesFolder then
		return tempInstancesFolder
	end
	tempInstancesFolder = Instance.new("Folder")
	tempInstancesFolder.Name = tempInstancesFolderName
	tempInstancesFolder.Parent = workspace
	return tempInstancesFolder
end

function TestHelper.getTempScreenGui()
	local tempScreenGuiName = "TempScreenGui"
	local tempScreenGui = game.CoreGui:FindFirstChild(tempScreenGuiName)
	if tempScreenGui then
		return tempScreenGui
	end
	tempScreenGui = Instance.new("ScreenGui", game.CoreGui)
	tempScreenGui.Name = tempScreenGuiName
	tempScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	return tempScreenGui
end

function TestHelper.createNonAvatar(name)
	local notAvatar = Instance.new("Model")
	notAvatar.Name = name or "dummy"
	notAvatar.Parent = TestHelper.getTempInstancesFolder()
	return notAvatar
end

function TestHelper.createClothesWithoutCage(name)
	local model = Instance.new("Model")
	local clothes = Instance.new("MeshPart", model)
	clothes.Name = name or TestHelper.DefaultClothesName
	model.Parent = TestHelper.getTempInstancesFolder()
	return clothes
end

function TestHelper.createClothesWithFullCages(name)
	local model = Instance.new("Model")
	local clothes = Instance.new("MeshPart", model)
	clothes.Name = name or TestHelper.DefaultClothesName
	model.Parent = TestHelper.getTempInstancesFolder()
	local wrapInst = Instance.new("MeshPart",clothes)
	wrapInst.Name = clothes.Name
	Instance.new("WrapLayer", clothes)
	return clothes
end

local function createAvatar(name)
	local avatar = Instance.new("Model")
	avatar.Parent = TestHelper.getTempInstancesFolder()
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = avatar
	local HumanoidRootPart = Instance.new("Part", avatar)
	HumanoidRootPart.Name = "HumanoidRootPart"
	local UpperTorso = Instance.new("MeshPart", avatar)
	UpperTorso.Name = "UpperTorso"
	local LowerTorso = Instance.new("MeshPart", avatar)
	LowerTorso.Name = "LowerTorso"
	local Head = Instance.new("MeshPart", avatar)
	Head.Name = "Head"
	local LeftFoot = Instance.new("MeshPart", avatar)
	LeftFoot.Name = "LeftFoot"
	local RightFoot = Instance.new("MeshPart", avatar)
	RightFoot.Name = "RightFoot"
	local LeftHand = Instance.new("MeshPart", avatar)
	LeftHand.Name = "LeftHand"
	local RightHand = Instance.new("MeshPart", avatar)
	RightHand.Name = "RightHand"
	local RightUpperArm = Instance.new("MeshPart", avatar)
	RightUpperArm.Name = "RightUpperArm"
	local RightLowerArm = Instance.new("MeshPart", avatar)
	RightLowerArm.Name = "RightLowerArm"
	local LeftUpperArm = Instance.new("MeshPart", avatar)
	LeftUpperArm.Name = "LeftUpperArm"
	local LeftLowerArm = Instance.new("MeshPart", avatar)
	LeftLowerArm.Name = "LeftLowerArm"
	local LeftUpperLeg = Instance.new("MeshPart", avatar)
	LeftUpperLeg.Name = "LeftUpperLeg"
	local LeftLowerLeg = Instance.new("MeshPart", avatar)
	LeftLowerLeg.Name = "LeftLowerLeg"
	local RightUpperLeg = Instance.new("MeshPart", avatar)
	RightUpperLeg.Name = "RightUpperLeg"
	local RightLowerLeg = Instance.new("MeshPart", avatar)
	RightLowerLeg.Name = "RightLowerLeg"
	avatar.Name = name or "dummy"
	Instance.new("WrapTarget", UpperTorso)
	return avatar
end

function TestHelper.createAvatarWithoutCages(name)
	return createAvatar(name)
end

function TestHelper.createAvatarWithFullCages(name)
	local avatar = createAvatar(name)
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = avatar
	local meshPart = Instance.new("MeshPart")
	meshPart.Parent = avatar
	local innerCage = Instance.new("MeshPart",avatar)
	innerCage.Name = "Inner"
	local outerCage = Instance.new("MeshPart",avatar)
	outerCage.Name = "Outer"
	return avatar
end

local function addItemAndConfirm(item, addItemFromExplorerButton)
	if not addItemFromExplorerButton then
		local ScrollerPath = TestHelper.getMainScroller()
		local AddItemFromExplorerButtonPath =
			XPath.new("SelectSwizzle.ViewArea.SelectFrame.SelectItemFrame.AddItemFromExplorerButton.ImageButton")
		addItemFromExplorerButton = ScrollerPath:cat(AddItemFromExplorerButtonPath)
	end

	TestHelper.clickXPath(addItemFromExplorerButton)

	local Selection = game:GetService("Selection")
	Selection:Set({item})
	delay()

	local dialogName = Localization.mock():getText("Dialog","DefaultTitle")
	local dialogPath = XPath.new(game.CoreGui[dialogName])
	local dialogConfirmButtonPath =
		dialogPath:cat(XPath.new("SolidBackground.ButtonContainer.Contents.1.Contents.TextButton"))
	TestHelper.waitForXPathInstance(dialogConfirmButtonPath)
	TestHelper.clickXPath(dialogConfirmButtonPath)
end

function TestHelper.addLCItemWithoutCageFromExplorer(item)
	item = item or TestHelper.createClothesWithoutCage()
	assert(not ItemCharacteristics.hasFullCages(item))

	addItemAndConfirm(item)

	-- item does not have full cage need to confirm another dialog
	local dialogName = Localization.mock():getText("Dialog","DefaultTitle")
	local dialogPath = XPath.new(game.CoreGui[dialogName])
	local dialogConfirmButtonPath =
		dialogPath:cat(XPath.new("SolidBackground.ButtonContainer.Contents.1.Contents.TextButton"))
	TestHelper.waitForXPathInstance(dialogConfirmButtonPath)
	TestHelper.clickXPath(dialogConfirmButtonPath)
	return item
end

function TestHelper.addLCItemWithFullCageFromExplorer(item)
	item = item or TestHelper.createClothesWithFullCages()
	assert(ItemCharacteristics.hasFullCages(item))

	addItemAndConfirm(item)
	return item
end

local function addItemToGrid(item)
	local ScrollerPath = TestHelper.getMainScroller()
	local GridPath = ScrollerPath:cat(XPath.new("PreviewSwizzle.ViewArea.PreviewFrame.Grid"))
	local GridScrollerPath = GridPath:cat(XPath.new("ScrollingFrame.Contents.Scroller"))
	local gridScrollerChildPath =  GridScrollerPath:cat(XPath.new("AddNewTile"))
	TestHelper.waitForXPathInstance(gridScrollerChildPath)
	local childTextButtonPath = gridScrollerChildPath:cat(XPath.new("Contents.TextButton"))
	TestHelper.waitForXPathInstance(childTextButtonPath)

	addItemAndConfirm(item, childTextButtonPath)
end

--assumes avatar tab is already selected
function TestHelper.addAvatarToGrid()
	addItemToGrid(TestHelper.createAvatarWithFullCages())
end

--assumes clothing tab is already selected
function TestHelper.addClothesItemToGrid()
	addItemToGrid(TestHelper.createClothesWithFullCages())
end

function TestHelper.selectCage(cage)
	local ScrollerPath = TestHelper.getMainScroller()
	local SelectCageRadioButtonListPath =
		ScrollerPath:cat(XPath.new("EditSwizzle.ViewArea.EditorFrame.EditingModeFrame.EditingModeRadioButtonList"))
	local cageButtonPath
	if cage == Enum.CageType.Inner then
		local SelectInnerCageRadioButtonPath =
			SelectCageRadioButtonListPath:cat(XPath.new("Inner.RadioImage.Contents"))
		cageButtonPath = SelectInnerCageRadioButtonPath:cat(XPath.new("TextButton"))
	else
		local SelectOuterCageRadioButtonPath =
			SelectCageRadioButtonListPath:cat(XPath.new("Outer.RadioImage.Contents"))
		cageButtonPath = SelectOuterCageRadioButtonPath:cat(XPath.new("TextButton"))
	end
	TestHelper.clickXPath(cageButtonPath)
end

return TestHelper