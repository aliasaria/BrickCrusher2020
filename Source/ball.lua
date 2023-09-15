local gfx <const> = playdate.graphics

function createBall(x, y, dx_in, dy_in)
	local ball = gfx.sprite.new()
	local ballImage = gfx.image.new('images/ball9x9')
	local w, h = ballImage:getSize()
	ball:setImage(ballImage)

	ball.dx, ball.dy = dx_in, dy_in

	ball:setTag(SpriteTypes.BALL)

	ball:setCollideRect(0, 0, w, h)
	ball:moveTo(x, y)
	ball:add()

	ball.OldX = x
	ball.OldY = y

	ball.isAlive = false

	ball.spriteType = SpriteTypes.BALL

	ball.isStuck = false


	function ball:collisionResponse(other)
		local collisionType = playdate.graphics.sprite.kCollisionTypeOverlap

		-- Handle paddle collisions manually so this returns overlap which makes
		-- The ball pass through the paddle but still records the collision
		-- In the future we could use groups, or make all paddle collisions
		-- Manual so this doesn't need to be calculated
		if other.spriteType == SpriteTypes.PADDLE then
			collisionType = gfx.sprite.kCollisionTypeOverlap
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

	function ball:die()
		-- lives = lives - 1
		-- paddle.isSticky = false
		-- paddle.isStuck = true
		-- gameSpeedReset()
		-- print("call die")
		activeBalls = activeBalls - 1
		self:setVisible(false)
		self:setUpdatesEnabled(false)
		-- self:moveTo(paddle.x,TOP_OF_PADDLE_Y)
		self.isAlive = false

		if activeBalls < 1 then
			lives = lives - 1

			if lives < 0 then
				currentGameState = GAME_STATES.GAMEOVER
				GAME_STATE_TYPE = "GAMEOVER"
			end

			gameSpeedReset()
			resetMainBall()
		end
	end

	function ball:update()
		-----------------------------
		-- Bounce off edges of screen
		--
		-- Right
		if (ball.x + ball.width / 2 >= GAME_AREA_WIDTH) then
			ball.x = GAME_AREA_WIDTH - ball.width / 2
			ball.dx = -math.abs(ball.dx)
		end
		-- Left
		if (ball.x - ball.width / 2 <= 0) then
			ball.x = 0 + ball.width / 2
			ball.dx = math.abs(ball.dx)
		end
		-- Top
		if (ball.y <= 0 + ball.width / 2) then
			ball.dy = math.abs(ball.dy)
			ball.y = 0 + ball.width / 2
		end
		-- Bottom
		if (ball.y >= GAME_AREA_HEIGHT + 10) then
			if (DEBUG) then
				ball.dy = -(math.abs(ball.dy))
			else
				self:die()
			end
		end
		------------------------------

		-----------------------
		-- BOUNCE off of paddle
		--

		local paddleX, paddleY, paddleWidth, paddleHeight = paddle:getBounds()


		-- Manually detect a collision with paddle based on height and x position between paddle bounds
		-- we add a 1px shift on top because it looks better
		-- we add 5px on the bottom otherwise fast balls go through the paddle
		if (ball.dx ~= 0 and ball.y > TOP_OF_PADDLE_Y - 1 and ball.y < TOP_OF_PADDLE_Y + ball.dy + 5) then
			if (ball.x >= paddleX and ball.x <= (paddleX + paddleWidth)) then
				ball.dy = -(math.abs(ball.dy))
				ball.y = TOP_OF_PADDLE_Y - 1


				local whereOnPaddle = ((ball.x - paddleX) / paddleWidth)
				-- whereOnPaddle is between 0 and 1 which is a percent of the position on the paddle
				-- where 0 is fully to the left, and 1.0 is fully to the right. It can be less than 0
				-- or more than 1 if it hits the far edge.
				-- print (whereOnPaddle)
				--      .2 .4 .5 .6 .8
				--      |  |  |  |  |
				--    <===============>
				-- if     whereOnPaddle < 0.2 	then dx = -8
				-- elseif whereOnPaddle < 0.4  then dx = -4
				-- elseif whereOnPaddle < 0.6  then dx = 2
				-- elseif whereOnPaddle < 0.8  then dx = 4
				-- else   						     dx = 8
				-- end

				ball.dx = (whereOnPaddle - 0.5) * 16

				-- Round floats up or down based on sign
				if (ball.dx > 0)
				then
					ball.dx = math.floor(ball.dx)
				else
					ball.dx = math.ceil(ball.dx)
				end

				-- add slight angle to the ball if it is going perfectly up and down
				if (ball.dx == 0) then ball.dx = 0.5 end

				if (paddle.isSticky and (ball.y >= TOP_OF_PADDLE_Y - 5)) then
					ball.dy = 0
					ball:moveTo(ball.x, TOP_OF_PADDLE_Y)
					ball.isStuck = true
				else
					-- ball.dy = -math.abs(ball.dy)
				end
			end
		end
		-----------------------

		-- self:moveBy(dx, dy)

		local verticalMoveSpeed = ball.dy * (1 + ((gameSpeed - 1) / 2))
		-- print(verticalMoveSpeed)

		-- If we are stuck, no point in checking for collisions
		if (ball.isStuck) then
			return
		end

		local actualX, actualY, collisions, length = ball:moveWithCollisions(ball.x + ball.dx, ball.y + verticalMoveSpeed)
		for i = 1, length do
			local collision = collisions[i]

			if (collision.other.spriteType == SpriteTypes.BRICK) then
				-- This isn't the perfect collision detection
				-- with understanding walls of bricks as flat, for example, but it's simple for now
				local n = collision.normal

				if n.x ~= 0.0 then ball.dx = -ball.dx end
				if n.y ~= 0.0 then ball.dy = -ball.dy end

				hitBrick(collision.other)
			end
		end

		if (ball.x > GAME_AREA_WIDTH) then
			ball.x = GAME_AREA_WIDTH
		end
	end

	function ball:reset(x, y, dx_in, dy_in)
		if (dx_in ~= nil) then
			ball.dx = dx_in
		end
		ball.dy = dy_in
		ball:moveTo(x, y)
	end

	ball:setZIndex(100)
	return ball
end

function createBalls()
	local balls = {}

	for i = 1, MAX_NUMBER_OF_BALLS do
		local b = createBall(330, 100 + i * 10, 0, 0)
		b:setVisible(false)
		b:setUpdatesEnabled(false)
		b.isAlive = false
		-- b:moveTo(paddle.x, TOP_OF_PADDLE_Y)
		balls[i] = b
	end

	balls[1]:setVisible(true)
	balls[1]:setUpdatesEnabled(true)
	balls[1].isAlive = true
	balls[1]:moveTo(paddle.x, TOP_OF_PADDLE_Y)
	activeBalls = 1

	function balls:moveBy(dx, dy)
		for i, v in ipairs(balls) do
			if v.isAlive then
				v:moveBy(dx, dy)
			end
		end
	end

	function balls:highestBallIndex()
		local highestBallIndex = 1
		for i = 2, MAX_NUMBER_OF_BALLS do
			if
				(balls[highestBallIndex].isAlive == false)
				or
				(balls[i].isAlive and balls[i].y > balls[highestBallIndex].y)
			then
				highestBallIndex = i
			end
		end

		if balls[highestBallIndex].isAlive == false then
			highestBallIndex = nil
		end

		return highestBallIndex
	end

	function balls:shootBalls()
		-- Whenever we reset the speed we set this to false
		-- and we wait until the player moves or shoots to
		-- "start the timer"
		playerHasBegunPlaying = true

		for i, ball in ipairs(balls) do
			if ball.isAlive then
				if (ball.isStuck) then
					ball.isStuck = false
					ball.dy = -BALL_ORIGINAL_DY
					if (ball.dx == 0) then ball.dx = 2 end
					ball:moveBy(0, -2) --if you don't move out a bit it gets stuck with collision again
				end
			end
		end
	end

	return balls
end

function resetMainBall()
	if balls[1] ~= nil then
		balls[1]:setVisible(true)
		balls[1]:setUpdatesEnabled(true)
		balls[1].isAlive = true
		balls[1]:moveTo(paddle.x, TOP_OF_PADDLE_Y)
		balls[1].dx = 2
		activeBalls = 1
		balls[1].isStuck = true
	end
end

function resetAllBalls()
	for i = 2, MAX_NUMBER_OF_BALLS do
		local b = balls[i]
		b:setVisible(false)
		b:setUpdatesEnabled(false)
		b.isAlive = false
		b:moveTo(paddle.x, TOP_OF_PADDLE_Y)
	end

	if balls[1] ~= nil then
		balls[1]:setVisible(true)
		balls[1]:setUpdatesEnabled(true)
		balls[1].isAlive = true
		balls[1]:moveTo(paddle.x, TOP_OF_PADDLE_Y)
		balls[1].dx = 2
		activeBalls = 1
		balls[1].isStuck = true
	end
end
