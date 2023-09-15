local gfx <const> = playdate.graphics

local brickImages = {}
for i = 1, 6 do
	brickImages[i] = gfx.image.new('images/brick/brick' .. i)
end


hitSound = playdate.sound.sampleplayer.new('sounds/Wall_Light_Double_Switch_Off-004.wav')
-- thudSound = playdate.sound.sampleplayer.new('sounds/PUNCH_PERCUSSIVE_HEAVY_06.wav')

lastHitTime = playdate.getCurrentTimeMilliseconds()
lastComboTime = nil
comboCounter = 0
longestCombo = 0
lastComboSize = 0
lastComboPositionX = 0
lastComboPositionY = 0
comboPositionX = 0
comboPositionY = 0

function hitBrick(brick)
	-- createExplosion(brick.x, brick.y)

	-- If the type is not a number, this is a metal brick
	if (type(brick.brickType) ~= "number") then
		-- thudSound:play()
		if (DEBUG) then brick.brickType = 1 end
		return
	end

	hitSound:play()
	brick.brickType -= 1
	score += 1

	local hitTime = playdate.getCurrentTimeMilliseconds()
	if (hitTime - lastHitTime) < 250 then
		comboCounter += 1
		comboPositionX = brick.x
		comboPositionY = brick.y
	else
		if (comboCounter > 1) then
			score += comboCounter * 5
			lastComboPositionX = brick.x
			lastComboPositionY = brick.y
			-- print(brick.x .. ", " .. brick.y)
			lastComboTime = hitTime
			lastComboSize = comboCounter
			if (comboCounter > longestCombo) then
				longestCombo = comboCounter
			end
		end
		comboCounter = 0
	end
	lastHitTime = hitTime

	brick:setImage(brickImages[brick.brickType])

	killBrickIfDead(brick)


	if math.random(6) == 1 then
		local p = createPill(brick.x, brick.y)
		table.insert(pills, p)
	end
end

function shootBrick(brick)
	-- If the type is not a number, this is a metal brick
	if (type(brick.brickType) ~= "number") then
		return
	end
	-- hitSound:play()
	brick.brickType = brick.brickType - 1
	score = score + 1
	brick:setImage(brickImages[brick.brickType])

	killBrickIfDead(brick)
end

function killBrickIfDead(brick)
	if brick.brickType < 1 then
		brick:remove()
		brickCount -= 1

		if brickCount == 0 then
			nextLevel()
		end
	end
end

function createBrick(x, y, brickType)
	local brick = gfx.sprite.new()

	-- Store where in the bricks table this is
	brick.row = x
	brick.column = y

	local brickImg

	if (type(brickType) == "number") then
		brickImg = brickImages[brickType]
		brickCount += 1
	else
		brickImg = gfx.image.new('images/brick/brick-metal')
	end

	local w, h = brickImg:getSize()
	brick:setImage(brickImg)
	brick:setCollideRect(0, 0, w, h)
	-- brick:moveTo(math.random( math.floor(SCREEN_WIDTH / w) )*w - 4, math.random(10)*h)
	brick:setBounds(0, 0, w, h)
	brick:moveTo(x * (w - 1) - w / 2, y * (h - 1) - h / 2)
	brick:add()

	brick:setTag(SpriteTypes.BRICK)

	brick.isEnemy = true

	brick.spriteType = SpriteTypes.BRICK
	brick.brickType = brickType
	-- print(brick.brickType)

	-- function brick:draw(x, y, width, height)
	-- 	brickImg:drawFaded(0, 0, math.random(0,10) / 10, playdate.graphics.image.kDitherTypeScreen)
	-- end

	function brick:collisionResponse(other)
		return gfx.sprite.kCollisionTypeBounce
	end

	function brick:update()

	end

	brick:setZIndex(500)
	return brick
end
