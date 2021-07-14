return {
	Gray_Lightest = Color3.fromRGB(244, 244, 244),
	Gray_Lighter = Color3.fromRGB(234, 234, 234),
	Gray_Light = Color3.fromRGB(204, 204, 204),
	Gray_Mid = Color3.fromRGB(107, 107, 107),
	Gray = Color3.fromRGB(60, 60, 60),
	Slate = Color3.fromRGB(46, 46, 46),
	Carbon = Color3.fromRGB(34, 34, 34),
	Blue = Color3.fromRGB(0, 162, 255),
	Blue_Dark = Color3.fromRGB(0, 117, 189),
	Blue_Light = Color3.fromRGB(53, 181, 255),

	Red = Color3.fromRGB(255, 0, 0),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),

	-- TODO: DEVTOOLS-4869 - If we add lighter/darker functions to Color3, then refactor this to use that.
	lighter = function(color3, alpha)
		return color3:lerp(Color3.new(1, 1, 1), alpha)
	end,

	darker = function(color3, alpha)
		return color3:lerp(Color3.new(0, 0, 0), alpha)
	end,
}