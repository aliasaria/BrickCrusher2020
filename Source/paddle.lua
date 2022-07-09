local gfx = playdate.graphics

function createPaddle(x, y)
	local paddle = gfx.sprite.new()
	local playerImage = gfx.image.new('images/paddle1')
	local w, h = playerImage:getSize()
	paddle.isSticky = false
	paddle.movementFlip = 1   --if this is -1 then the motion flips

	paddle:setImage(playerImage)

	paddle.spriteType = SpriteTypes.PADDLE
	paddle.hasGun = false

	paddle:setCollideRect(0, 4, w, h-3)
	paddle:moveTo(x, y)
	paddle:add()

	function paddle:grow()
		self:removeAllPowerUps()
		playerImage = gfx.image.new('images/paddle_long')
		paddle:setImage(playerImage)
		w, h = playerImage:getSize()
		paddle:setCollideRect(0, 4, w, h-3)
	end

	function paddle:addGun()
		self:removeAllPowerUps()
		self.hasGun = true
		local gunImage = gfx.image.new('images/paddle_w_gun')
		paddle:moveTo(self.x,y)
		paddle:setImage(gunImage)
		w, h = gunImage:getSize()
		paddle:setCollideRect(0, 4, w, h-3)
	end

	function paddle:removeAllPowerUps()
		local playerImage = gfx.image.new('images/paddle1')
		paddle:setImage(playerImage)
		w, h = playerImage:getSize()
		paddle:setCollideRect(0, 4, w, h-3)
		self.movementFlip = 1
		paddle.isSticky = false
		paddle.hasGun = false
	end

	function paddle:flip()
		self.movementFlip = -1
	end


	-- function paddle:shootBall()
	-- 	if (paddle.isStuck) then
	-- 		paddle.isStuck = false
	-- 		ball.dy = -BALL_ORIGINAL_DY
	-- 		if (ball.dx == 0) then ball.dx = 2 end
	-- 	end

	-- 	if (paddle.isSticky) then
	-- 		ball.dy = -BALL_ORIGINAL_DY
	-- 	end

	-- 	ball:moveBy(0, -2) --if you don't move out a bit it gets stuck with collision again
	-- end

	function paddle:collisionResponse(other)
		return gfx.sprite.kCollisionTypeOverlap
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
			dx = -4 * self.movementFlip
		elseif playdate.buttonIsPressed("RIGHT") then
			dx = 4 * self.movementFlip
		end

		local change, acceleratedChange = playdate.getCrankChange()
		-- print (acceleratedChange)

		dx += acceleratedChange * self.movementFlip

		-- If the player has moved at all, consider the game to be
		-- started, and the game speed timer will start to tick
		if (dx ~= 0) then
			playerHasBegunPlaying = true
		end


		-- print('paddle pos: '..self.x..","..self.y)

		if self.x + dx > SCREEN_WIDTH - w/2 then
			dx = (SCREEN_WIDTH - w/2) - self.x
			-- self:moveTo(SCREEN_WIDTH - w/2, self.y)
		end
		
		if self.x + dx < 0 + w/2 then 
			dx = (w/2) - self.x
			-- self:moveTo(w/2, self.y)
		end

		self:moveBy(dx, dy)

		-- Move any balls that are stuck to the paddle
		for i,ball in ipairs(balls) do
			if ball.isAlive then
				if (ball.isStuck) then
					ball:moveBy(dx,0)
				end
			end
		end

	end

	paddle:setZIndex(1000)
	return paddle
end

-- function playerFire() creates a new bullet sprite
-- and sets up its animation and collision properties
function playerFire()
	-- Create bullet sprite
	local s = gfx.sprite.new()
	local img = gfx.image.new('images/doubleBullet')
	local imgw, imgh = img:getSize()
	s:setImage(img)
	s:moveTo(paddle.x, paddle.y)
	s:setCollideRect(0, 0, imgw, imgh)
	bulletsOnScreenCount += 1

	timeWhenLastBulletWasShot = playdate.getCurrentTimeMilliseconds()

	function s:collisionResponse(other)
		return gfx.sprite.kCollisionTypeOverlap
	end

	function s:update()

		-- Move upwards at 10 pixel per frame
		local newY = s.y - 10
		local didCollisionHappen = false

		-- If past the top of the screen, remove the bullet sprite
		if newY < -imgh then
			s:remove()
			bulletsOnScreenCount -= 1
		else
			-- s:moveTo(s.x, newY)
			local actualX, actualY, collisions, length = s:moveWithCollisions(s.x, newY)
			for i = 1, length do
				local collision = collisions[i]
				-- print (collision.other.spriteType)

				if collision.other.spriteType == SpriteTypes.BRICK then
					-- print("Collision with brick")
					shootBrick(collision.other)
					didCollisionHappen = true
				end

				if collision.other.spriteType == SpriteTypes.BALL then
					-- Do nothing
					-- print("Bullet hit ball!")
				end
			end
		end

		if (didCollisionHappen) then
			s:remove()
			bulletsOnScreenCount -= 1
		end

	end

	s:setZIndex(999)
	s:add()
	return s

end
