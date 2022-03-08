local gfx = playdate.graphics

function createPaddle(x, y)
	local paddle = gfx.sprite.new()
	local playerImage = gfx.image.new('images/paddle1')
	local w, h = playerImage:getSize()
	paddle:setImage(playerImage)

	paddle.spriteType = SpriteTypes.PADDLE

	paddle:setCollideRect(0, 5, w, h)
	paddle:moveTo(x, y)
	paddle:add()

	function paddle:grow()
		playerImage = gfx.image.new('images/paddle_long')
		paddle:setImage(playerImage)
		w, h = playerImage:getSize()
		self:setCollideRect(0, 0, w, h)
	end

	function paddle:addGun()
		local gunImage = gfx.image.new('images/paddle_w_gun')
		paddle:moveTo(self.x,y)
		paddle:setImage(gunImage)
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


function playerFire()
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
					shootBrick(collision.other)
					s:remove()
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
