--[[
	Utility function used to get associated files from components that follow the fractal pattern.

    Parameter "folderPath" is expected to be an array of file instances.
]]

return function(folderPath)
    local folderDataLookup = {}

    for _, folder in pairs(folderPath) do
        if folder ~= script then
            folderDataLookup[folder.Name] = {
                name = folder.Name,
                story = folder:FindFirstChild(folder.Name .. ".story"),
                style = folder:FindFirstChild("style"),
                test = folder:FindFirstChild("test.spec"),
            }
        end
    end

    return folderDataLookup
end