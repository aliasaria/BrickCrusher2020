
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
-- import 'CoreLibs/animation'
-- import 'CoreLibs/input'

local gfx = playdate.graphics

-- playdate.inputHandlers.push(playdate.input)

local s, ms = playdate.getSecondsSinceEpoch()
math.randomseed(ms,s)

local font = gfx.font.new('images/font/blocky')

hitSound = playdate.sound.sampleplayer.new('sounds/Wall_Light_Double_Switch_Off-004.wav')

local SCREEN_WIDTH = 320
local SCREEN_HEIGHT = 240

local maxEnemies = 80
local enemyCount = 0

local maxBackgroundPlanes = 10
local backgroundPlaneCount = 0

local player = nil

local ball = nil

local score = 0

local bgY = 0
local bgH = 0


SpriteTypes = {
	PADDLE = 1,
	BALL = 2,
	BRICK = 3,
	VIOLET = 4,
	YELLOW = 5,
 }


-- local explosionImages = {}
-- for i = 1, 8 do
-- 	explosionImages[i] = gfx.image.new('images/x/'..i)
-- end

local brickImages = {}
for i = 1, 6 do
	brickImages[i] = gfx.image.new('images/brick/brick'..i)
end

-- Side Panel
local heartImgFilled = gfx.image.new('images/heartFilled.png')
local heartImgEmpty = gfx.image.new('images/heartEmpty.png')
local PANEL_START = 320

local currentLevel = 1

-- All Levels
local levels = {}

-- Level 1
levels[1] = {}
levels[1][1] = { 1, 2, 3, 4, 1, 1, 1, 1, 1 }
levels[1][2] = { 1, 1, 0, 0, 0, 1, 1, 1, 1 }
levels[1][3] = { 1, 2, 3, 4, 5, 6, 6, 4, 4 }
levels[1][4] = { 1, 2, 3, 4, 5, 6, 6, 1, 1 }
levels[1][5] = { 1, 1, 0, 0, 0, 1, 1, 0, 0 }
levels[1][6] = { 1, 1, 1, 1, 1, 1, 1, 1, 1 }
levels[1][7] = { 1, 2, 3, 4, 5, 1, 1, 0, 0 }
levels[1][8] = { 1, 1, 0, 0, 0, 1, 1, 0, 0 }
levels[1][9] = { 1, 1, 1, 1, 1, 1, 1, 0, 0 }
levels[1][10]= { 1, 2, 3, 4, 5, 1, 1, 1, 1 }

-- Level 2
levels[2] = {}
levels[2][1] = { 1, 1, 1, 1, 1, 1, 1 }
levels[2][2] = { 1, 1, 0, 0, 0, 1, 1 }
levels[2][3] = { 1, 0, 1, 1, 1, 0, 1 }
levels[2][4] = { 1, 1, 1, 1, 1, 1, 1 }


local function drawSidePanel()


	-- Draw Border
	gfx.setLineWidth(3)
	gfx.drawLine(PANEL_START, 0, PANEL_START, SCREEN_HEIGHT)


	-- Draw Life Hearts
	local pad = heartImgFilled.width + 1
	local paddingTop = 6
	local paddingLeft = 10

	heartImgFilled:draw(PANEL_START + paddingLeft,paddingTop)
	heartImgFilled:draw(PANEL_START + paddingLeft + pad,paddingTop)
	heartImgFilled:draw(PANEL_START + paddingLeft + pad * 2,paddingTop)
	heartImgEmpty:draw(PANEL_START + paddingLeft + pad * 3,paddingTop)

	gfx.drawText('LEVEL: '..currentLevel, PANEL_START + 10, 32)

	gfx.drawText('SCORE: '..score, PANEL_START + 10, 50)
end

-- -- Background
-- local function createBackgroundSprite()

-- 	local bg = gfx.sprite.new()
-- 	local bgImg = gfx.image.new('images/background.png')
-- 	local w, h = bgImg:getSize()
-- 	bgH = h
-- 	bg:setBounds(0, 0, 400, 240)

-- 	function bg:draw(x, y, width, height)
-- 		bgImg:draw(0, bgY)
-- 		bgImg:draw(0, bgY-bgH)

-- 	end

-- 	function bg:update()
-- 		bgY += 1
-- 		if bgY > bgH then
-- 			bgY = 0
-- 		end
-- 		self:markDirty()
-- 	end

-- 	bg:setZIndex(0)
-- 	bg:add()
-- end



local function createExplosion(x, y)

	local s = gfx.sprite.new()
	s.frame = 1
	local img = gfx.image.new('images/explosion/'..s.frame)
	s:setImage(img)
	s:moveTo(x, y)

	function s:update()
		s.frame += 1
		if s.frame > 11 then
			s:remove()
		else
			local img = gfx.image.new('images/explosion/'..s.frame)
			s:setImage(img)
		end
	end

	s:setZIndex(2000)
	s:add()

end


local function hitBrick(brick)
	-- createExplosion(brick.x, brick.y)
	
	brick.brickType -= 1

	if brick.brickType < 1 then
		brick:remove()
		enemyCount -= 1
	end

	if math.random(6) == 1 then
		createPill(brick.x, brick.y)
	end

end


local function createPlayer(x, y)
	local paddle = gfx.sprite.new()
	local playerImage = gfx.image.new('images/paddle1')
	local w, h = playerImage:getSize()
	paddle:setImage(playerImage)

	paddle.spriteType = SpriteTypes.PADDLE

	paddle:setCollideRect(0, 0, w, h)
	paddle:moveTo(x, y)
	paddle:add()

	function paddle:grow()
		playerImage = gfx.image.new('images/paddle_long')
		paddle:setImage(playerImage)
		w, h = playerImage:getSize()
		self:setCollideRect(0, 0, w, h)
	end

	function paddle:collisionResponse(other)
		return gfx.sprite.kCollisionTypeBounce
	end

	function paddle:update()

		local dx = 0
		local dy = 0

		if playdate.buttonIsPressed("UP") then
			-- dy = -4
		elseif playdate.buttonIsPressed("DOWN") then
			-- dy = 4
		end
		if playdate.buttonIsPressed("LEFT") then
			dx = -4
		elseif playdate.buttonIsPressed("RIGHT") then
			dx = 4
		end

		local change, acceleratedChange = playdate.getCrankChange()
		-- print (acceleratedChange)

		dx += acceleratedChange

		self:moveBy(dx, dy)

		-- print('paddle pos: '..self.x..","..self.y)

		if self.x > SCREEN_WIDTH - w/2 then self:moveTo(SCREEN_WIDTH - w/2, self.y) end
		if self.x < 0 + w/2			 then self:moveTo(w/2, self.y) end

		-- local actualX, actualY, collisions, length = paddle:moveWithCollisions(paddle.x + dx, paddle.y + dy)
		-- for i = 1, length do
		-- 	local collision = collisions[i]
		-- 	if collision.other.isEnemy == true then	-- crashed into enemy plane
		-- 		hitBrick(collision.other)
		-- 		collision.other:remove()
		-- 		score -= 1
		-- 	end
		-- end

	end

	paddle:setZIndex(1000)
	return paddle
end



local function createBall(x, y)
	dx, dy = 2, 2
	local ball = gfx.sprite.new()
	local ballImage = gfx.image.new('images/ball9x9')
	local w, h = ballImage:getSize()
	ball:setImage(ballImage)

	ball:setTag(SpriteTypes.BALL)
	
	ball:setCollideRect(0, 0, w, h)
	ball:moveTo(x, y)
	ball:add()

	ball.OldX = x
	ball.OldY = y

	ball.spriteType = SpriteTypes.BALL


	function ball:collisionResponse(other)
		local collisionType = playdate.graphics.sprite.kCollisionTypeOverlap

		if other.spriteType == SpriteTypes.PADDLE then
			collisionType = gfx.sprite.kCollisionTypeBounce
		end

		if other.spriteType == SpriteTypes.BRICK then
			collisionType = gfx.sprite.kCollisionTypeBounce
		end

		return collisionType
	end

	-- ball:setBounds(-dx,-dy,w+dx,h+dy)

	-- function ball:draw(x, y, width, height)
	-- 	ballImage:draw(0,0)
	-- 	gfx.drawCircleInRect(-dx,-dy,3,3)
	-- end


	function ball:update()

		-- if playdate.buttonIsPressed("UP") then
		-- 	dy = -4
		-- elseif playdate.buttonIsPressed("DOWN") then
		-- 	dy = 4
		-- end
		-- if playdate.buttonIsPressed("LEFT") then
		-- 	dx = -4
		-- elseif playdate.buttonIsPressed("RIGHT") then
		-- 	dx = 4
		-- end
		ball.oldX = ball.x
		ball.oldY = ball.y

		-- Bounce of edges of screen
		if (ball.x + ball.width >= SCREEN_WIDTH) then dx = -math.abs(dx) end
		if (ball.x <= 0) then dx = math.abs(dx) end
		if (ball.y >= SCREEN_HEIGHT) then dy = -math.abs(dy) end
		if (ball.y <= 0) then dy = math.abs(dy) end

 		-- self:moveBy(dx, dy)

		local actualX, actualY, collisions, length = ball:moveWithCollisions(ball.x + dx, ball.y + dy)
		for i = 1, length do
			local collision = collisions[i]

			if (collision.other.spriteType == SpriteTypes.BRICK) then
				-- This isn't the perfect collision detection
				-- with understanding walls, etc, but it's simple for now
				local n = collision.normal

				if n.x ~= 0.0 then dx = -dx end
				if n.y ~= 0.0 then dy = -dy end
				score += 1

				hitSound:play()

				hitBrick(collision.other)
			end

			if (collision.other.spriteType == SpriteTypes.PADDLE) then
				local whereOnPaddle = ( (ball.x - collision.otherRect.x) / collision.other.width)
				-- whereOnPaddle is between 0 and 1 which is a percent of the position on the paddle
				-- where 0 is fully to the left, and 1.0 is fully to the right. It can be less than 0
				-- or more than 1 if it hits the far edge.
				-- print (whereOnPaddle)

				--      .2 .4 .5 .6 .8
				--      |  |  |  |  |
				--    <===============>
				if     whereOnPaddle < 0.2 	then dx = -8
				elseif whereOnPaddle < 0.4  then dx = -4
				elseif whereOnPaddle < 0.6  then dx = 2
				elseif whereOnPaddle < 0.8  then dx = 4
				else   						     dx = 8
				end

				dy = -math.abs(dy)
			end

			-- if collision.other.isEnemy == true then	-- crashed into enemy plane
			-- 	hitBrick(collision.other)
			-- 	collision.other:remove()
			-- 	score += 1
			-- end
		end

	end

	ball:setZIndex(100)
	return ball
end




local function playerFire()
	local s = gfx.sprite.new()
	local img = gfx.image.new('images/doubleBullet')
	local imgw, imgh = img:getSize()
	s:setImage(img)
	s:moveTo(paddle.x, paddle.y)
	s:setCollideRect(0, 0, imgw, imgh)

	function s:collisionResponse(other)
		return gfx.sprite.kCollisionTypeOverlap
	end

	function s:update()

		local newY = s.y - 20

		if newY < -imgh then
			s:remove()
		else
			-- s:moveTo(s.x, newY)
			local actualX, actualY, collisions, length = s:moveWithCollisions(s.x, newY)
			for i = 1, length do
				local collision = collisions[i]
				-- print (collision.other.spriteType)

				if collision.other.spriteType == SpriteTypes.BRICK then
					hitBrick(collision.other)
					s:remove()
					score += 1
				end

				if collision.other.spriteType == SpriteTypes.BALL then
					-- Do nothing
					-- print("Bullet hit ball!")
				end
			end
		end

	end

	s:setZIndex(999)
	s:add()

end




local function createEnemyPlane(x, y)

	local plane = gfx.sprite.new()

	local planeImg

	planeImg = gfx.image.new('images/plane1')

	local w, h = planeImg:getSize()
	plane:setImage(planeImg)
	plane:setCollideRect(0, 0, w, h)
	plane:moveTo(math.random(400), -math.random(30) - h)
	plane:add()

	plane.isEnemy = true

	enemyCount += 1

	function plane:collisionResponse(other)
		return gfx.sprite.kCollisionTypeOverlap
	end


	function plane:update()

		local newY = plane.y + 4

		if newY > 400 + h then
			plane:remove()
			enemyCount -= 1
		else

			plane:moveTo(plane.x, newY)

		end
	end


	plane:setZIndex(500)
	return plane
end

local function createBrick(x, y, brickType)

	local brick = gfx.sprite.new()

	local brickImg

	brickImg = brickImages[1]

	local w, h = brickImg:getSize()
	brick:setImage(brickImg)
	brick:setCollideRect(0, 0, w, h)
	-- brick:moveTo(math.random( math.floor(SCREEN_WIDTH / w) )*w - 4, math.random(10)*h)
	brick:setBounds(0, 0, w, h)
	brick:moveTo(x * w, y * h)
	brick:add()
	
	ball:setTag(SpriteTypes.BRICK)

	brick.isEnemy = true

	brick.spriteType = SpriteTypes.BRICK
	brick.brickType = brickType
	-- print(brick.brickType)

	enemyCount += 1

	-- function brick:draw(x, y, width, height)
	-- 	brickImg:drawFaded(0, 0, math.random(0,10) / 10, playdate.graphics.image.kDitherTypeScreen)
	-- end

	function brick:collisionResponse(other)
		return gfx.sprite.kCollisionTypeBounce
	end


	function brick:update()

		-- local newY = brick.y

		-- if newY > 400 + h then
		-- 	brick:remove()
		-- 	enemyCount -= 1
		-- else

		-- 	brick:moveTo(brick.x, newY)

		-- end
		-- print(brick.brickType)
		-- print(brickImages[brick.brickType])
		brick:setImage(brickImages[brick.brickType])
		-- brick:setImage( gfx.image.new('images/brick/brick3') )

	end


	brick:setZIndex(500)
	return brick
end



local function spawnEnemyIfNeeded()
	if enemyCount < maxEnemies then
		if math.random(math.ceil(120/maxEnemies)) == 1 then
			-- createEnemyPlane()
			-- createBrick()
		end
	end
end



function createPill(x, y)

	local pill = gfx.sprite.new()

	local pillAnimation = gfx.imagetable.new('images/pill/pill')
	local animationLength = pillAnimation:getLength()
	pill.frame = 1.0
	pill:setImage(pillAnimation:getImage( math.floor(pill.frame) ))

	-- print ( pillAnimation:getLength() )

	local w, h = pill:getImage():getSize()

	pill:setCollideRect(0, 0, w, h)

	-- plane:setImage(planeImg)
	pill:moveTo(x, y)
	pill:add()


	function pill:collisionResponse(other)
		if (other.spriteType == SpriteTypes.PADDLE) then
			return gfx.sprite.kCollisionTypeFreeze
		else
			return gfx.sprite.kCollisionTypeOverlap
		end
	end

	function pill:update()
		pill:setImage(pillAnimation:getImage( math.floor(pill.frame) ))

		local newY = pill.y + 1

		if newY > 400 + h then
			pill:remove()
		else
			-- pill:moveTo(pill.x, newY)
			local actualX, actualY, collisions, length = pill:moveWithCollisions(pill.x, newY)

			for i = 1, length do
				local collision = collisions[i]
	
				if (collision.other.spriteType == SpriteTypes.PADDLE) then
					powerUp("LONG")
					pill:remove()
				end
			end
		end
		
		pill.frame += 0.3
		if pill.frame > animationLength then
			pill.frame = 1
		end
	end


	pill:setZIndex(100)
	return pill
end


function powerUp( type )
	paddle:grow()
end

local function initializeLevel( n )
	for col, v in ipairs(levels[n]) do
		for row, brickVal in ipairs(v) do
			-- print(i2, v2)
			if brickVal ~= 0 then
				createBrick(row, col, brickVal)
			end
		end
	end
end

local levelStart = true
local function createBricksIfNeeded()
	if (levelStart == true) then
		levelStart = false
		initializeLevel(1)
	end
end

-- function playdate.cranked(change, acceleratedChange)

-- 	if change > 1 then
-- 		maxEnemies += 1
-- 	elseif change < -1 then
-- 		maxEnemies -= 1
-- 	end

-- end


function playdate.update()

	if playdate.buttonJustPressed("A") then
		playerFire()
	end

	if playdate.buttonJustPressed("B") then
		-- playerFire()
	end

	createBricksIfNeeded()

	-- spawnEnemyIfNeeded()
	-- spawnBackgroundPlaneIfNeeded()

	gfx.sprite.update()
	

	drawSidePanel()

	gfx.setFont(font)
	-- gfx.drawText('sprite count: '..#gfx.sprite.getAllSprites(), 2, 150+2)
	-- gfx.drawText('max bricks: '..maxEnemies, 2, 150+16)
	-- gfx.drawText('score: '..score, 2, 150+30)

	playdate.drawFPS(2, 224)

end

-- ------------------
-- ------------------
-- Let's do this! ...
-- ------------------
-- ------------------
playdate.display.setRefreshRate(30)
-- createBackgroundSprite()
paddle = createPlayer(200, 233)
ball = createBall(0,0)


local startMusic = playdate.sound.sampleplayer.new('sounds/8BitRetroSFXPack1_Traditional_GameStarting08.wav')
startMusic:play()


