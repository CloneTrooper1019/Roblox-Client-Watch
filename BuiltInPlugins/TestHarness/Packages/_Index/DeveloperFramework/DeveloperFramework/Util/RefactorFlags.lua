local RefactorFlags = {
    --[[
	    RefactorFlags needs to be required and updated directly; before Framework's init
	    is required (so that any files that Framework's init requires get the correct values).
    ]]
    THEME_REFACTOR = false
}

return RefactorFlags