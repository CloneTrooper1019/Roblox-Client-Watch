return function()
	local Spritesheet = require(script.Parent.Spritesheet)

	it("should verify correct props", function()
		local success,_

		-- Missing required props
		success,_ = pcall(function()
			return Spritesheet("", {})
		end)
		expect(success).to.equal(false)

		-- Missing required prop NumSprites
		success,_ = pcall(function()
			return Spritesheet("", {SpriteSize = 1, NumSprites = nil})
		end)
		expect(success).to.equal(false)

		-- Missing required props SpriteSize
		success,_ = pcall(function()
			return Spritesheet("", {SpriteSize = nil, NumSprites = 1})
		end)
		expect(success).to.equal(false)

		-- SpritesheetWidth is invalid type
		success,_ = pcall(function()
			return Spritesheet("", {SpriteSize = 1, NumSprites = 1, SpritesheetWidth = ""})
		end)
		expect(success).to.equal(false)

		-- Has all required props of correct type
		success,_ = pcall(function()
			return Spritesheet("", {SpriteSize = 1, NumSprites = 1})
		end)
		expect(success).to.equal(true)

		-- Has all required props of correct type
		success,_ = pcall(function()
			return Spritesheet("", {SpriteSize = Vector2.new(1,1), NumSprites = 1})
		end)
		expect(success).to.equal(true)

		-- Has all props of correct type
		success,_ = pcall(function()
			return Spritesheet("", {SpriteSize = 1, NumSprites = 1, SpritesheetWidth = 1})
		end)
		expect(success).to.equal(true)

		-- SpriteSize out of range
		success,_ = pcall(function()
			return Spritesheet("", {SpriteSize = 0, NumSprites = 1})
		end)
		expect(success).to.equal(false)

		-- NumSprites out of range
		success,_ = pcall(function()
			return Spritesheet("", {SpriteSize = 1, NumSprites = 0})
		end)
		expect(success).to.equal(false)

		-- SpritesheetWidth out of range
		success,_ = pcall(function()
			return Spritesheet("", {SpriteSize = 1, NumSprites = 1, SpritesheetWidth = 0})
		end)
		expect(success).to.equal(false)
	end)

	it("should return correct result for a single-row spritesheet", function()
		local asset = "rbxasset://test"
		local numSprites = 3
		local spriteSize = Vector2.new(32, 16)
		local sprites = Spritesheet(asset, {
			NumSprites = numSprites,
			SpriteSize = spriteSize,
		})

		-- Correct number of sprites
		expect(#sprites).to.equal(numSprites)

		-- Correct sprite properties
		for i,sprite in pairs(sprites) do
			expect(sprite.Image).to.equal(asset)
			expect(sprite.ImageRectSize).to.equal(spriteSize)
			expect(sprite.ImageRectOffset.X).to.equal((i - 1) * spriteSize.X)
			expect(sprite.ImageRectOffset.Y).to.equal(0)
		end
	end)

	it("should return correct result for a multi-row spritesheet", function()
		local asset = "rbxasset://test"
		local numSprites = 5
		local spriteSize = Vector2.new(32, 16)
		local sheetWidth = 66
		local sprites = Spritesheet(asset, {
			NumSprites = numSprites,
			SpriteSize = spriteSize,
			SpritesheetWidth = sheetWidth,
		})

		-- Correct number of sprites
		expect(#sprites).to.equal(numSprites)

		-- Correct sprite properties
		local numColumns = math.floor(sheetWidth / spriteSize.X)
		for i,sprite in pairs(sprites) do
			local row = math.floor((i - 1) / numColumns)
			local column = (i - 1) % numColumns

			expect(sprite.Image).to.equal(asset)
			expect(sprite.ImageRectSize).to.equal(spriteSize)
			expect(sprite.ImageRectOffset.X).to.equal(column * spriteSize.X)
			expect(sprite.ImageRectOffset.Y).to.equal(row * spriteSize.Y)
		end
	end)
end