--[[
	This component is designed to show the favorites counts for the assetPreview.
	It will send request to fetch the data when loaded. And update accordingly.

	Necessary Properties:
	Size = UDim2,

	FavoriteCounts = number, the number of favorites this asset has.
	Favorited = bool, does the current user have this asset favorited.
	OnActivated = callback, function to invoke when the favorited button is clicked.

	LayoutOrder = number,
]]

local Library = script.Parent.Parent.Parent

local Roact = require(Library.Parent.Parent.Roact)

local Theming = require(Library.Theming)
local withTheme = Theming.withTheme

local Favorites = Roact.PureComponent:extend("Favorites")

-- For less then 10k, we use , to seperate the number.
-- For larger than 10k, we use xxk+
local function getFavoritesCountString(counts)
	local countsString
	if counts > 10000 then
		countsString = ("%dk+"):format(math.floor(counts / 1000))
	else
		if counts > 1000 then
			countsString = ("%d,%d"):format(counts / 1000, counts % 1000)
		else
			countsString = tostring(counts)
		end
	end

	return countsString
end

function Favorites:init(props)
	self.state = {
		hovered = false
	}

	self.onMouseEnter = function(rbx, x, y)
		self:setState({
			hovered = true
		})
	end

	self.onMouseLeave = function(rbx, x, y)
		self:setState({
			hovered = false
		})
	end
end

function Favorites:render()
	return withTheme(function(theme)
		local props = self.props
		local state = self.state

		local favoriteCounts = props.FavoriteCounts or 0

		local favoritesTheme = theme.assetPreview.favorites
		local favoritesImage = (state.hovered or props.Favorited) and favoritesTheme.favorited or favoritesTheme.unfavorited
		local textContent = getFavoritesCountString(tonumber(favoriteCounts))
		local contentColor = favoritesTheme.contentColor
		local size = props.Size

		local layoutOrder = props.LayoutOrder
		local verticalAlignment = props.VerticalAlignment or Enum.VerticalAlignment.Center

		return Roact.createElement("Frame", {
			Size = size,

			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder,
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = verticalAlignment,
				Padding = UDim.new(0, 4),
			}),

			ImageContent = Roact.createElement("ImageButton", {
				Size = UDim2.new(0, 20, 0, 20),

				BackgroundTransparency = 1,

				Image = favoritesImage,

				[Roact.Event.MouseEnter] = self.onMouseEnter,
				[Roact.Event.MouseLeave] = self.onMouseLeave,
				[Roact.Event.Activated] = self.props.OnActivated,

				LayoutOrder = 1,
			}),

			TextContent = Roact.createElement("TextLabel", {
				Size = UDim2.new(1, -20, 1, 0),

				Text = tostring(textContent),
				TextColor3 = contentColor,
				Font = theme.assetPreview.font,
				TextSize = theme.assetPreview.textSizeMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,

				BackgroundTransparency = 1,

				LayoutOrder = 2,
			})
		})
	end)
end

return Favorites


