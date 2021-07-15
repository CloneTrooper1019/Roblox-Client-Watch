-- Lua flag definitions should go in this file so that they can be used by both main and runTests
-- If the flags are defined in main, then it's possible for the tests run first
-- And then error when trying to use flags that aren't yet defined

game:DefineFastFlag("FixRadioButtonSeAndTableHeadertForTesting", false)
game:DefineFastFlag("SupportFreePrivateServers", false)
game:DefineFastFlag("VIPServersRebrandToPrivateServers", false)
game:DefineFastFlag("EnableDevProductsInGameSettings", false)
game:DefineFastFlag("StudioFixGameManagementIndexNil", false)
game:DefineFastFlag("UXImprovementsShowUserPermsWhenCollaborator2", false)
game:DefineFastFlag("UXImprovementsNonTCPlacesAllowedPlay", false)
game:DefineFastFlag("GameSettingsDisplayCollaborativeEditingWarning", false)

return nil
