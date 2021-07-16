return {
	rectangle = function(horizontal, vertical)
		return {
			top = vertical,
			bottom = vertical,
			left = horizontal,
			right = horizontal,
		}
	end,
	square = function(x)
		return {
			top = x,
			bottom = x,
			left = x,
			right = x,
		}
	end,
	quad = function(top, right, bottom, left)
		return {
			top = top,
			bottom = bottom,
			left = left,
			right = right,
		}
	end,
}