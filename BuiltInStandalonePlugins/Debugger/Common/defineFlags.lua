-- TODO DEVTOOLS-4481: This should be refactored when DEVTOOLS-4481 is fixed.
-- Lua flag definitions should go in this file so that they can be used by both main and runTests
-- If the flags are defined in main, then it's possible for the tests run first
-- And then error when trying to use flags that aren't yet defined
-- In most circumstances flags should be initialized to false

-- New Plugin Setup: Define initial fast flag

game:DefineFastFlag("DebuggerPluginEditBreakpoint_alpha", false)
game:DefineFastFlag("LuaUIDebuggerCallstack", false)

return nil
