
local gfx = playdate.graphics

function createBall(x, y)
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