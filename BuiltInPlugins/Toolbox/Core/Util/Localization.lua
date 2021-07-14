--[[
	This script contains all the strings that needs to be localized in the toolbox.
]]

local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Cryo = require(Libs.Cryo)

local createSignal = require(Plugin.Core.Util.createSignal)
local DebugFlags = require(Plugin.Core.Util.DebugFlags)
local wrapStrictTable = require(Plugin.Core.Util.wrapStrictTable)
local AssetConfigConstants = require(Plugin.Core.Util.AssetConfigConstants)
local isCli = require(Plugin.Core.Util.isCli)
local Localization = {}
Localization.__index = Localization

local FFlagToolboxFixCommonWarnings2 = game:GetFastFlag("ToolboxFixCommonWarnings2")

--[[
	options:
		getLocaleId : function void -> LocaleId
		getTranslator : function LocaleId -> Translator
		getFallbackTranslator : function LocaleId -> Translator
		localeIdChanged : RbxScriptSignal
]]
function Localization.new(options)
	local self = {
		_externalLocaleIdGetter = options.getLocaleId or nil,
		_externalTranslatorGetter = options.getTranslator or nil,
		_externalFallbackTranslatorGetter = options.getFallbackTranslator or nil,
		_externalLocaleIdChangedSignal = options.localeIdChanged,

		_externalLocaleIdChangedConnection = nil,

		_content = {},

		_signal = createSignal(),
	}

	self._content = wrapStrictTable(self._content, "content")

	setmetatable(self, Localization)

	if self._externalLocaleIdChangedSignal then
		self._externalLocaleIdChangedConnection = self._externalLocaleIdChangedSignal:Connect(function()
			self:_recalculateContent()
		end)
	end
	self:_recalculateContent()

	return self
end

function Localization.createDummyLocalization()
	return Localization.new({
		getLocaleId = function()
			return "en-us"
		end,
		getTranslator = function(localeId)
			return {
				FormatByKey = function(self, key, args)
					local ret = "TEST_" .. key
					if args and type(args) == "table" then
						for k, v in pairs(args) do
							ret = ret .. "_" .. k .. "=" .. v
						end
					end
					return ret
				end,
			}
		end,
		localeIdChanged = nil,
	})
end

-- Creates a Localization that just echos back whatever's in the debug value
-- Useful for testing UI reacts to strings of all lengths
function Localization.createTestCustomLocaleLocalization(value)
	return Localization.new({
		getLocaleId = function()
			return value.Value
		end,
		getTranslator = function(localeId)
			return {
				FormatByKey = function()
					return localeId
				end
			}
		end,
		localeIdChanged = value:GetPropertyChangedSignal("Value")
	})
end

-- Creates a Localization that uses the LocaleId in a debug flag but reads from the real table
function Localization.createTestRealLocaleLocalization(localizationTable, value)
	return Localization.new({
		getLocaleId = function()
			return value.Value
		end,
		getTranslator = function(localeId)
			return localizationTable:GetTranslator(localeId)
		end,
		localeIdChanged = value:GetPropertyChangedSignal("Value")
	})
end

function Localization:subscribe(...)
	return self._signal:subscribe(...)
end

function Localization:getLocalizedContent()
	return self.content
end

function Localization:getLocalizedCreatorIntroText(userName)
	return self:_safeLocalize("Studio.Toolbox.General.AssetCreatorIntroText", {
		name = userName
	})
end

function Localization:getLocalizedEarningText(earning)
	return self:_safeLocalize("Studio.Toolbox.General.SalesEarning", {
		earning = tostring(earning)
	})
end

function Localization:getLocalizedPriceRangeText(minPrice, maxPrice)
	return self:_safeLocalize("Studio.Toolbox.General.SalesPriceRange", {
		minPrice = tostring(minPrice),
		maxPrice = tostring(maxPrice)
	})
end

function Localization:getLocalizedAssetIDText(assetId)
	return self:_safeLocalize("Studio.Toolbox.General.PreviewAreaAssetID", {
		assetId = tostring(assetId)
	})
end

function Localization:getLocalizedStatusText(assetStatus)
	return self:_safeLocalize("Studio.Toolbox.General.PreviewAreaStatus", {
		assetStatus = tostring(assetStatus)
	})
end

function Localization:getLocalizedImageFormat(formatString, maxX, maxY)
	return self:_safeLocalize("Studio.Toolbox.AssetConfigPreview.Format", {
		formatString = formatString,
		maxDimensionsX = tostring(maxX),
		maxDimensionsY = tostring(maxY),
	})
end

-- percent, string, from 0 to 100
function Localization:getLocalizedFee(percent)
	return self:_safeLocalize("Studio.Toolbox.General.Fee", {
		percent = percent
	})
end

function Localization:getSalesMessage(market, user)
	return self:_safeLocalize("Studio.Toolbox.AssetConfigSales.Target", {
		market = market,
		user = user,
	})
end

function Localization:getLocalizedVoteText(voteCounts)
	local localizedContent = self.content
	local voteText = voteCounts ~= 1 and localizedContent.Voting.VotesText
		or localizedContent.Voting.VoteText

	-- TODO: CLIDEVSRVS-1769 : Improve localization for toolbox's vote counts and vote text
	return string.format("%d %s", voteCounts, voteText)
end

function Localization:getLocalizedCategories(categories)
	return self:_localizeTable(categories, "Category", "name", "name")
end

function Localization:getLocalizedSorts(sorts)
	return self:_localizeTable(sorts, "Sort", "name", "sort")
end

function Localization:getLocalizedSuggestions(suggestions)
	return self:_localizeTable(suggestions, "Suggestions", "name", "search")
end

function Localization:getLocalizedFooter(footerBackgroundNames)
	return self:_localizeTable(footerBackgroundNames, "Footer", "name", "color")
end

function Localization:getLocalizedTooManyCollaborators(maxNumCollaborators)
	return self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.TooManyCollaboratorsText", {
		maxNumCollaborators = maxNumCollaborators,
	})
end

function Localization:getLocalizedBuyPrompt(name, creator, robux)
	return self:_safeLocalize("Studio.Toolbox.Purchase.BuyPrompt", {
		name = name,
		creator = creator,
		robux = robux,
	})
end

function Localization:getLocalizedInsufficientFundsPrompt(robux, name, creator)
	return self:_safeLocalize("Studio.Toolbox.Purchase.InsufficientPrompt", {
		robux = robux,
		name = name,
		creator = creator,
	})
end

function Localization:getPurchaseFailedDetails(name)
	return self:_safeLocalize("Studio.Toolbox.Purchase.FailedDetails", {
		name = name,
	})
end

function Localization:getPurchaseSuccessDetails(name)
	return self:_safeLocalize("Studio.Toolbox.Purchase.SuccessDetails", {
		name = name,
	})
end

function Localization:getMaxTags(max)
	return self:_safeLocalize("Studio.Toolbox.MaxTagsDescription", {
		max = max,
	})
end

function Localization:getThumbnailStatus(status)
	return self:_safeLocalize("Studio.Toolbox.ThumbnailStatus." .. status)
end

function Localization:getUploadWithFee(price)
	return self:_safeLocalize("Studio.Toolbox.AssetConfigFooter.UploadWithFee", {
		price = price,
	})
end

function Localization:destroy()
	if self._externalLocaleIdChangedConnection then
		self._externalLocaleIdChangedConnection:Disconnect()
	end
end


-- Private impl below
function Localization:_getDefaultLocaleId()
	return "en-us"
end

function Localization:_getLocaleId()
	-- First we will see if studio want to override the Toolbox localization.
	local studioForceLocaleId = isCli() and "" or settings():GetFVariable("StudioForceLocale")
	if not (#studioForceLocaleId == 0) then
		return studioForceLocaleId
	end

	-- Then we check what's current LocaleId we want to use
	-- If toolbox localization is enabled.
	if self._externalLocaleIdGetter then
		return self._externalLocaleIdGetter()
	end

	return self:_getDefaultLocaleId()
end

function Localization:_getTranslator(localeId)
	localeId = localeId or self:_getLocaleId()
	if self._externalTranslatorGetter then
		return self._externalTranslatorGetter(localeId)
	end
	return nil
end

function Localization:_getFallbackTranslator()
	if self._externalFallbackTranslatorGetter then
		return self._externalFallbackTranslatorGetter(self:_getDefaultLocaleId())
	end

	return nil
end

function Localization:_getDefaultTranslator()
	return self:_getTranslator(self:_getDefaultLocaleId())
end

function Localization:_update(changedContent)
	self._content = Cryo.Dictionary.join(self._content, changedContent)
	self.content = wrapStrictTable(self._content, "content")
	self._signal:fire(self.content)
end

-- Attempts to localize key with args in the current translator
-- If it fails, it attempts again in the default locale
-- If it still fails, then it just falls back to using the key
-- Else, it returns the translated content
-- If show warnings is on, it will warn when it fails to translate
function Localization:_safeLocalize(key, args)
	local translator = self:_getTranslator()

	if not translator and DebugFlags.shouldDebugWarnings() then
		warn("Toolbox Localization:_safeLocalize() translator = nil")
		return key
	end

	local success, translated = self:_safeLocalizeInner(translator, key, args)

	if not success then
		if DebugFlags.shouldDebugWarnings() then
			warn(("Toolbox error in localizing key \"%s\" to locale \"%s\": %s"):format(
				key, translator.LocaleId, translated))
		end

		local defaultTranslator = self:_getDefaultTranslator()

		if not defaultTranslator and DebugFlags.shouldDebugWarnings() then
			warn("Toolbox Localization:_safeLocalize() defaultTranslator = nil")
			return key
		end

		success, translated = self:_safeLocalizeInner(defaultTranslator, key, args)

		if not success then
			if DebugFlags.shouldDebugWarnings() then
				warn(("\tToolbox error in localizing key \"%s\" to default locale \"%s\": %s"):format(
					key, defaultTranslator.LocaleId, translated))
			end
			-- If we can't translate to real locale or default locale, fallback to returning the key
			translated = key
		else
			if DebugFlags.shouldDebugWarnings() then
				warn(("\tToolbox falling back to default locale \"%s\" for key \"%s\""):format(
					defaultTranslator.LocaleId, key))
			end
		end

		local fallbackTranslator = self:_getFallbackTranslator()
		local fallbackTranslation
		success, fallbackTranslation = self:_safeLocalizeInner(fallbackTranslator, key, args)

		if success then
			translated = fallbackTranslation
		else
			if DebugFlags.shouldDebugWarnings() then
				warn(("\tToolbox error in localizing key \"%s\" using fallback table"):format(key))
			end
		end
	end

	return translated
end

-- Wraps self:translator:FormatByKey(key, args) in pcall
function Localization:_safeLocalizeInner(translator, key, args)
	return pcall(function()
		return translator:FormatByKey(key, args)
	end)
end

function Localization:_recalculateContent()
	self:_update({
		ToolboxToolbarName = self:_safeLocalize("Studio.Toolbox.General.ToolboxToolbarName"),

		Category = {
			FreeModels = self:_safeLocalize("Studio.Toolbox.General.CategoryModels"),
			FreeDecals = self:_safeLocalize("Studio.Toolbox.General.CategoryDecals"),
			FreeMeshes = self:_safeLocalize("Studio.Toolbox.General.CategoryMeshes"),
			FreeAudio = self:_safeLocalize("Studio.Toolbox.General.CategoryAudio"),
			PaidPlugins = self:_safeLocalize("Studio.Toolbox.General.CategoryPaidPlugins"),
			FreeVideo = self:_safeLocalize("Studio.Toolbox.General.CategoryVideos"),
			MyModels = self:_safeLocalize("Studio.Toolbox.General.CategoryMyModels"),
			MyDecals = self:_safeLocalize("Studio.Toolbox.General.CategoryMyDecals"),
			MyMeshes = self:_safeLocalize("Studio.Toolbox.General.CategoryMyMeshes"),
			MyAudio = self:_safeLocalize("Studio.Toolbox.General.CategoryMyAudio"),
			MyPlugins = self:_safeLocalize("Studio.Toolbox.General.CategoryMyPlugins"),
			MyPackages = self:_safeLocalize("Studio.Toolbox.General.CategoryMyPackages"),
			MyVideo = self:_safeLocalize("Studio.Toolbox.General.CategoryMyVideos"),
			RecentModels = self:_safeLocalize("Studio.Toolbox.General.CategoryRecentModels"),
			RecentDecals = self:_safeLocalize("Studio.Toolbox.General.CategoryRecentDecals"),
			RecentMeshes = self:_safeLocalize("Studio.Toolbox.General.CategoryRecentMeshes"),
			RecentAudio = self:_safeLocalize("Studio.Toolbox.General.CategoryRecentAudio"),
			RecentVideo = self:_safeLocalize("Studio.Toolbox.General.CategoryRecentVideos"),
			GroupModels = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupModels"),
			GroupDecals = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupDecals"),
			GroupMeshes = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupMeshes"),
			GroupAudio = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupAudio"),
			GroupPackages = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupPackages"),
			GroupPlugins = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupPlugins"),
			CreationsDevelopmentSectionDivider = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsDevelopmentSectionDivider"),
			CreationsModels = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsModels"),
			CreationsDecals = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsDecals"),
			CreationsAudio = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsAudio"),
			CreationsMeshes = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsMeshes"),
			CreationsPlugins = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsPlugins"),
			CreationsGroupModels = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupModels"),
			CreationsGroupDecals = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupDecals"),
			CreationsGroupMeshes = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupMeshes"),
			CreationsGroupAudio = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupAudio"),
			CreationsGroupPackages = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupPackages"),
			CreationsGroupPlugins = self:_safeLocalize("Studio.Toolbox.General.CategoryGroupPlugins"),
			CreationsCatalogSectionDivider = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsCatalogSectionDivider"),
			CreationsHats = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsHats"),
			CreationsTeeShirts = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsTeeShirts"),
			CreationsShirts = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsShirts"),
			CreationsPants = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsPants"),
			CreationsHair = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsHair"),
			CreationsFaceAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsFaceAccessory"),
			CreationsNeckAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsNeckAccessory"),
			CreationsShoulderAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsShoulderAccessory"),
			CreationsFrontAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsFrontAccessory"),
			CreationsBackAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsBackAccessory"),
			CreationsWaistAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsWaistAccessory"),
			CreationsGroupHats = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsGroupHats"),
			CreationsGroupHair = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsGroupHair"),
			CreationsGroupFaceAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsGroupFaceAccessory"),
			CreationsGroupNeckAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsGroupNeckAccessory"),
			CreationsGroupShoulderAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsGroupShoulderAccessory"),
			CreationsGroupFrontAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsGroupFrontAccessory"),
			CreationsGroupBackAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsGroupBackAccessory"),
			CreationsGroupWaistAccessories = self:_safeLocalize("Studio.Toolbox.General.CategoryCreationsGroupWaistAccessory"),
		},

		Suggestions = {
			IntroText = self:_safeLocalize("Studio.Toolbox.General.SuggestionsIntroText"),
			NPC = self:_safeLocalize("Studio.Toolbox.General.SuggestionsNPC"),
			Vehicle = self:_safeLocalize("Studio.Toolbox.General.SuggestionsVehicle"),
			Weapon = self:_safeLocalize("Studio.Toolbox.General.SuggestionsWeapon"),
			Building = self:_safeLocalize("Studio.Toolbox.General.SuggestionsBuilding"),
			Light = self:_safeLocalize("Studio.Toolbox.General.SuggestionsLight"),
		},

		Sort = {
			ByText = self:_safeLocalize("Studio.Toolbox.General.SortByText"),
			Relevance = self:_safeLocalize("Studio.Toolbox.General.SortByRelevance"),
			MostTaken = self:_safeLocalize("Studio.Toolbox.General.SortByMostTaken"),
			Favorites = self:_safeLocalize("Studio.Toolbox.General.SortByFavorites"),
			Updated = self:_safeLocalize("Studio.Toolbox.General.SortByUpdated"),
			Ratings = self:_safeLocalize("Studio.Toolbox.General.SortByRatings"),
		},

		Voting = {
			VoteText = self:_safeLocalize("Studio.Toolbox.General.VotingVoteText"),
			VotesText = self:_safeLocalize("Studio.Toolbox.General.VotingVotesText"), -- plural
		},

		Footer = {
			BGText = self:_safeLocalize("Studio.Toolbox.General.FooterBGText"),
			White = self:_safeLocalize("Studio.Toolbox.General.FooterButtonWhiteName"),
			Black = self:_safeLocalize("Studio.Toolbox.General.FooterButtonBlackName"),
			None = self:_safeLocalize("Studio.Toolbox.General.FooterButtonNoneName"),
		},

		SearchBarDefaultText = self:_safeLocalize("Studio.Toolbox.General.SearchBarDefaultText"),
		SearchBarCreatorText = self:_safeLocalize("Studio.Toolbox.General.SearchBarCreatorText"),

		EndorseBadgeTooltipText = self:_safeLocalize("Studio.Toolbox.General.EndorseBadgeTooltipText"),

		InfoBannerText = self:_safeLocalize("Studio.Toolbox.General.InfoBannerText"),

		NoPluginsFound = {
			TextLine1 = self:_safeLocalize("Studio.Toolbox.General.NoPluginsFound.TextLine1", {
				link = "{link}" -- Preserve the placeholder because we split this text over several components in NoResultsDetail
			}),
			TextLine2 = self:_safeLocalize("Studio.Toolbox.General.NoPluginsFound.TextLine2", {
				link = "{link}" -- Preserve the placeholder because we split this text over several components in NoResultsDetail
			}),
			LinkText = self:_safeLocalize("Studio.Toolbox.General.NoPluginsFound.LinkText"),
		},

		SearchResults = {
			SearchResults = self:_safeLocalize("Studio.Toolbox.General.SearchResults"),
			SearchResultsKeyword = self:_safeLocalize("Studio.Toolbox.General.SearchResultsKeyword"),
			ClearAll = self:_safeLocalize("Studio.Toolbox.General.SearchResultsClearAll"),
		},

		SearchOptions = {
			Creator = self:_safeLocalize("Studio.Toolbox.General.SearchOptionCreator"),
			Sort = self:_safeLocalize("Studio.Toolbox.General.SearchOptionSort"),
			Apply = self:_safeLocalize("Studio.Toolbox.General.SearchOptionsApply"),
			Cancel = self:_safeLocalize("Studio.Toolbox.General.SearchOptionsCancel"),
		},

		Tabs = {
			Marketplace = self:_safeLocalize("Studio.Toolbox.General.TabMarketplace"),
			Inventory = self:_safeLocalize("Studio.Toolbox.General.TabInventory"),
			Recent = self:_safeLocalize("Studio.Toolbox.General.TabRecent"),
			Creations = self:_safeLocalize("Studio.Toolbox.General.TabCreations"),
		},

		RightClickMenu = {
			CopyAssetID = self:_safeLocalize("Studio.Toolbox.General.RightClickMenuCopyAssetID"),
			CopyAssetURI = self:_safeLocalize("Studio.Toolbox.General.RightClickMenuCopyAssetURI"),
			ViewInBrowser = self:_safeLocalize("Studio.Toolbox.General.RightClickMenuViewInBrowser"),
			ConfigureAsset = self:_safeLocalize("Studio.Toolbox.General.RightClickMenuConfigureAsset"),
			EditAsset = self:_safeLocalize("Studio.Toolbox.General.RightClickMenuEditAsset"),
			Report = self:_safeLocalize("Studio.Toolbox.General.RightClickMenuReport")
		},

		Status = {
			[AssetConfigConstants.ASSET_STATUS.ReviewPending] = self:_safeLocalize("Studio.Toolbox.General.StatusReviewPending"),
			[AssetConfigConstants.ASSET_STATUS.Moderated] = self:_safeLocalize("Studio.Toolbox.General.StatusModerated"),
			[AssetConfigConstants.ASSET_STATUS.ReviewApproved] = self:_safeLocalize("Studio.Toolbox.General.StatusReviewApproved"),
			[AssetConfigConstants.ASSET_STATUS.OnSale] = self:_safeLocalize("Studio.Toolbox.General.StatusOnSale"),
			[AssetConfigConstants.ASSET_STATUS.OffSale] = self:_safeLocalize("Studio.Toolbox.General.StatusOffSale"),
			[AssetConfigConstants.ASSET_STATUS.DelayedRelease] = self:_safeLocalize("Studio.Toolbox.General.StatusDelayedRelease"),
			[AssetConfigConstants.ASSET_STATUS.Free] = self:_safeLocalize("Studio.Toolbox.General.Free"),
		},

		Sales = {
			Sale = self:_safeLocalize("Studio.Toolbox.General.SalesSale"),
			Onsale = self:_safeLocalize("Studio.Toolbox.General.SalesOnsale"),
			OnsaleApplyToSave = self:_safeLocalize("Studio.Toolbox.General.SalesOnsaleApplyToSave"),
			Offsale = self:_safeLocalize("Studio.Toolbox.General.SalesOffsale"),
			OffsaleApplyToSave = self:_safeLocalize("Studio.Toolbox.General.SalesOffsaleApplyToSave"),
			ItemCannotBeSold = self:_safeLocalize("Studio.Toolbox.General.SalesItemCannotBeSold"),
			Price = self:_safeLocalize("Studio.Toolbox.General.SalesPrice"),
			ServiceFee = self:_safeLocalize("Studio.Toolbox.General.SalesServiceFee"),
			Fee = not FFlagToolboxFixCommonWarnings2 and self:_safeLocalize("Studio.Toolbox.General.Fee") or nil,
			Earn = self:_safeLocalize("Studio.Toolbox.General.Earn"),
			PremiumBenefits = self:_safeLocalize("Studio.Toolbox.General.PremiumBenefits"),
		},

		PackagePermissions = {
			ActionDropdown = {
				NoAccessLabel = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.NoAccessLabel"),
				UseViewLabel = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.UseViewLabel"),
				EditLabel = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.EditLabel"),
				OwnerLabel = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.OwnerLabel"),
				MultipleLabel = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.MultipleLabel"),

				NoAccessDescription = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.NoAccessDescription"),
				UseViewDescription = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.UseViewDescription"),
				EditDescription = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.EditDescription"),
			},

			Collaborators = {
				FriendsCollaboratorType = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.FriendsCollaboratorType"),
				UsersCollaboratorType = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.UsersCollaboratorType"),
				GroupsCollaboratorType = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.GroupsCollaboratorType"),
				MyFriendsCollaborator = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.MyFriendsCollaborator"),
			},

			Searchbar = {
				Default = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.SearchbarDefault"),
				NoResults = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.NoResults"),
			},

			Title = {
				PackageCreator = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.PackageCreator"),
				ShareWith = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.ShareWith"),
			},

			Warning = {
				UserOwned = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.UserOwnedWarning"),
				GroupOwned = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.GroupOwnedWarning"),
			},

			RightClickMenu = {
				PackageDetails = self:_safeLocalize("Studio.Toolbox.AssetConfigPackagePermissions.PackageDetails")
			}
		},

		AssetConfig = {
			PublishAsset = {
				Title = self:_safeLocalize("Studio.Toolbox.General.Title"),
				Description = self:_safeLocalize("Studio.Toolbox.General.Description"),
				Ownership = self:_safeLocalize("Studio.Toolbox.General.Ownership"),
				Genre = self:_safeLocalize("Studio.Toolbox.General.Genre"),
				Copy = self:_safeLocalize("Studio.Toolbox.General.Copy"),
				Comments = self:_safeLocalize("Studio.Toolbox.General.Comments"),
				LearnMore = self:_safeLocalize("Studio.Toolbox.General.LearnMore"),
				Me = self:_safeLocalize("Studio.Toolbox.General.Me"),
				AssetType = self:_safeLocalize("Studio.Toolbox.General.AssetType"),
				Tags = self:_safeLocalize("Studio.Toolbox.General.Tags"),

				AssetTextDisplay = {
					[Enum.AssetType.Model] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeModel"),
					[Enum.AssetType.Decal] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeDecal"),
					[Enum.AssetType.Mesh] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeMesh"),
					[Enum.AssetType.Audio] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeAudio"),
					[Enum.AssetType.Hat] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeHat"),
					[Enum.AssetType.TShirt] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeTeeShirt"),
					[Enum.AssetType.Shirt] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeShirt"),
					[Enum.AssetType.Pants] = self:_safeLocalize("Studio.Toolbox.General.AssetTypePants"),
					[Enum.AssetType.Plugin] = self:_safeLocalize("Studio.Toolbox.General.AssetTypePlugin"),
					[Enum.AssetType.HairAccessory] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeHairAccessory"),
					[Enum.AssetType.FaceAccessory] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeFaceAccessory"),
					[Enum.AssetType.NeckAccessory] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeNeckAccessory"),
					[Enum.AssetType.ShoulderAccessory] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeShoulderAccessory"),
					[Enum.AssetType.FrontAccessory] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeFrontAccessory"),
					[Enum.AssetType.BackAccessory] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeBackAccessory"),
					[Enum.AssetType.WaistAccessory] = self:_safeLocalize("Studio.Toolbox.General.AssetTypeWaistAccessory"),
				},
			},

			PreviewArea ={
				PreviewLabel = self:_safeLocalize("Studio.Toolbox.AssetConfigPreview.Preview"),
				Change = self:_safeLocalize("Studio.Toolbox.AssetConfigPreview.Change"),
				Format = not FFlagToolboxFixCommonWarnings2 and self:_safeLocalize("Studio.Toolbox.AssetConfigPreview.Format") or nil,
				Process = self:_safeLocalize("Studio.Toolbox.AssetConfigPreview.Process"),
			},

			Footer = {
				Override = self:_safeLocalize("Studio.Toolbox.AssetConfigFooter.Override"),
				NewAsset = self:_safeLocalize("Studio.Toolbox.AssetConfigFooter.NewAsset"),
			},

			Override = {
				Title = self:_safeLocalize("Studio.Toolbox.AssetConfigFooter.OverrideTitle"),
				FilterID = self:_safeLocalize("Studio.Toolbox.AssetConfigAnimation.FilterID"),
				AnimationID = self:_safeLocalize("Studio.Toolbox.AssetConfigAnimation.AnimationID"),
				InvalidAnimationID = self:_safeLocalize("Studio.Toolbox.AssetConfigAnimation.InvalidAnimationID"),
			},

			Import = {
				Title = self:_safeLocalize("Studio.Toolbox.AssetConfigFooter.ImportTitle"),
			},

			Upload = {
				IDCopied = self:_safeLocalize("Studio.Toolbox.AssetConfigUpload.IDCopied")
			},

			UploadResult = {
				Success = self:_safeLocalize("Studio.Toolbox.AssetUploadResult.Success"),
				Failure = self:_safeLocalize("Studio.Toolbox.AssetUploadResult.Failure"),
			},

			VersionsHistory = {
				Current = self:_safeLocalize("Studio.Toolbox.AssetConfigVersions.Current"),
				Restore = self:_safeLocalize("Studio.Toolbox.AssetConfigVersions.Restore"),
			},

			SideTabs = {
				[AssetConfigConstants.SIDE_TABS.Sales] = self:_safeLocalize("Studio.Toolbox.General.SideTabSales"),
				[AssetConfigConstants.SIDE_TABS.Versions] = self:_safeLocalize("Studio.Toolbox.General.SideTabVersions"),
				[AssetConfigConstants.SIDE_TABS.General] = self:_safeLocalize("Studio.Toolbox.General.SideTabGeneral"),
				[AssetConfigConstants.SIDE_TABS.Permissions] = self:_safeLocalize("Studio.Toolbox.General.SideTabPermissions"),
			},

			Terms = self:_safeLocalize("Studio.Toolbox.AssetConfigCopy.Terms"),
			Accounts = self:_safeLocalize("Studio.Toolbox.AssetConfigCopy.AccountSetting"),

			-- Confirm if I need to change apply to save, back to cancel.
			Apply = self:_safeLocalize("Studio.Toolbox.Common.Submit"),
			Cancel = self:_safeLocalize("Studio.Toolbox.General.SearchOptionsCancel"),

			Error = self:_safeLocalize("Studio.Toolbox.AssetConfig.Error"),
			NetworkError = self:_safeLocalize("Studio.Toolbox.AssetConfigError.NetworkError"),
			GetAssetFailed = self:_safeLocalize("Studio.Toolbox.AssetConfig.GetAssetFailed"),

			Discard = self:_safeLocalize("Studio.Toolbox.General.Discard"),
			Close = self:_safeLocalize("Studio.Toolbox.Common.Close"),
			DiscardMessage = self:_safeLocalize("Studio.Toolbox.General.DiscardMessage"),

			Insert = self:_safeLocalize("Studio.Toolbox.Common.Insert"),
			Install = self:_safeLocalize("Studio.Toolbox.Common.Install"),
			Loading = self:_safeLocalize("Studio.Toolbox.Common.Loading"),
			Update = self:_safeLocalize("Studio.Toolbox.Common.Update"),
			Installed = self:_safeLocalize("Studio.Toolbox.Common.Installed"),

			InstallSuccess = self:_safeLocalize("Studio.Toolbox.General.InstallSuccess"),
			InstallFailure = self:_safeLocalize("Studio.Toolbox.General.InstallFailure"),
			Installing = self:_safeLocalize("Studio.Toolbox.General.Installing"),

			NoTagFound = self:_safeLocalize("Studio.Toolbox.NoTagFound"),
		},

		PurchaseFlow = {
			Cancel = self:_safeLocalize("Studio.Toolbox.Purchase.Cancel"),
			Retry = self:_safeLocalize("Studio.Toolbox.Purchase.Retry"),
			Buy = self:_safeLocalize("Studio.Toolbox.Purchase.Buy"),
			BuyRobux = self:_safeLocalize("Studio.Toolbox.Purchase.BuyRobux"),
			BuyPrompt = not FFlagToolboxFixCommonWarnings2 and self:_safeLocalize("Studio.Toolbox.Purchase.BuyPrompt") or nil,
			FreeTitle = self:_safeLocalize("Studio.Toolbox.Purchase.FreeTitle"),
			BuyTitle = self:_safeLocalize("Studio.Toolbox.Purchase.BuyTitle"),
			InsufficientFundsTitle = self:_safeLocalize("Studio.Toolbox.Purchase.InsufficientTitle"),
			InsufficientPrompt = not FFlagToolboxFixCommonWarnings2 and self:_safeLocalize("Studio.Toolbox.Purchase.InsufficientPrompt") or nil,
			CurrentBalance = self:_safeLocalize("Studio.Toolbox.Purchase.RobuxBalance"),
			FailedHeader = self:_safeLocalize("Studio.Toolbox.Purchase.FailedHeader"),
			FreeSuccessHeader = self:_safeLocalize("Studio.Toolbox.Purchase.FreeSuccessHeader"),
			SuccessHeader = self:_safeLocalize("Studio.Toolbox.Purchase.SuccessHeader"),
			Free = self:_safeLocalize("Studio.Toolbox.Purchase.Free"),
			OK = self:_safeLocalize("Studio.Toolbox.Common.OK"),
		},
	})
end

function Localization:_localizeTable(tbl, localizedTableName, keyToReplace, keyToUse)
	local newTbl = {}
	local localizedContent = self.content
	local content = localizedContent[localizedTableName]

	for index, item in pairs(tbl) do
		local valueToUse = item[keyToUse]
		local newText = content[valueToUse]

		newTbl[index] = Cryo.Dictionary.join(item, {
			[keyToReplace] = newText,
		})
	end

	return newTbl
end

return Localization
