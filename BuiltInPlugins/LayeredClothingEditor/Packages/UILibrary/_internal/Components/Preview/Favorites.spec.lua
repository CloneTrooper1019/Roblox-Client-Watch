return function()
    local Library = script.Parent.Parent.Parent
    local Roact = require(Library.Parent.Parent.Roact)

    local MockWrapper = require(Library.MockWrapper)

    local Favorites = require(Library.Components.Preview.Favorites)

    local IMAGE_FAVORITED = "rbxasset://textures/StudioToolbox/AssetPreview/star_filled.png"
    local IMAGE_UNFAVORITED = "rbxasset://textures/StudioToolbox/AssetPreview/star_stroke.png"

    local function createTestFavorites(container, name, props)
        local testFavoriteActivationValue = false
        local favorited = true
        if props then
            favorited = props.Favorited
        end

        local element = Roact.createElement(MockWrapper, {}, {
            Favorites = Roact.createElement(Favorites, {
                Size = UDim2.new(1,0,1,0),

                FavoriteCounts = 1000,
                Favorited = favorited,
                OnActivated = function()
                    testFavoriteActivationValue = not testFavoriteActivationValue
                end,

                LayoutOrder = 1,
            })
        })

        return Roact.mount(element, container or nil, name or "")
    end

    it("should create and destroy without errors", function()
        local instance = createTestFavorites()
        Roact.unmount(instance)
    end)

    it("should render correctly", function()
        local container = Instance.new("Folder")
        local instance = createTestFavorites(container)

        local element = container:FindFirstChildOfClass("Frame")
        expect(element.TextContent).to.be.ok()
        expect(element.ImageContent).to.be.ok()
    end)

    it("should properly set the initial favorite counts", function()
        local container = Instance.new("Folder")
        local instance = createTestFavorites(container)

        local element = container:FindFirstChildOfClass("Frame")

        expect(element.TextContent.Text).to.be.equal("1000")
    end)

    it("should display the correct icon for a favorited asset", function()
        local container = Instance.new("Folder")
        local instance = createTestFavorites(container, nil, {
            Favorited = true
        })

        local element = container:FindFirstChildOfClass("Frame")
        expect(element.ImageContent.Image).to.be.equal(IMAGE_FAVORITED)
    end)

    it("should display the correct icon for an unfavorited asset", function()
        local container = Instance.new("Folder")
        local instance = createTestFavorites(container, nil, {
            Favorited = false
        })

        local element = container:FindFirstChildOfClass("Frame")
        expect(element.ImageContent.Image).to.be.equal(IMAGE_UNFAVORITED)
    end)
end