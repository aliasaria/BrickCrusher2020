local gfx <const> = playdate.graphics

function createPill(x, y)
	local pill = gfx.sprite.new()

	local pillAnimation = gfx.imagetable.new('images/pill/pill')
	local animationLength = pillAnimation:getLength()
	pill.frame = 1.0
	pill:setImage(pillAnimation:getImage(math.floor(pill.frame)))

	local w, h = pill:getImage():getSize()

	pill:setCollideRect(0, 0, w, h)

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
		pill:setImage(pillAnimation:getImage(math.floor(pill.frame)))

		local newY = pill.y + 1

		if newY > 400 + h then
			pill:remove()
		else
			-- pill:moveTo(pill.x, newY)
			local actualX, actualY, collisions, length = pill:moveWithCollisions(pill.x, newY)

			for i = 1, length do
				local collision = collisions[i]

				if (collision.other.spriteType == SpriteTypes.PADDLE) then
					local r = math.random(100)

					if r < 20 then
						powerUp("GUN")
					elseif r < 40 then
						powerUp("LONG")
					elseif r < 45 then
						powerUp("SHORT")
					elseif r < 50 then
						powerUp("1UP")
					elseif r < 55 then
						powerUp("FLIP")
					elseif r < 70 then
						powerUp("SLOW")
					elseif r < 80 then
						powerUp("MLTI")
					elseif r <= 100 then
						powerUp("STKY")
					end

					pill:remove()
				end
			end
		end

		pill.frame += 0.2
		if pill.frame > animationLength then
			pill.frame = 1
		end
	end

	pill:setZIndex(100)
	return pill
end

local powerUpSound = playdate.sound.sampleplayer.new('sounds/MenuSound_DDM23.1_Wav.wav')
function powerUp(type)
	currentPowerUP = type

	if (type == "LONG") then
		paddle:grow()
	elseif (type == "GUN") then
		paddle:removeAllPowerUps()
		paddle:addGun()
	elseif (type == "1UP") then
		paddle:removeAllPowerUps()
		if (lives < 4) then lives = lives + 1 end
	elseif (type == "FLIP") then
		paddle:flip()
	elseif (type == "SLOW") then
		gameSpeedReset()
	elseif (type == "STKY") then
		paddle.isSticky = true
	elseif (type == "MLTI") then
		-- You can't be sticky with multi because that's too much to handle
		paddle.isSticky = false

		activeBalls = MAX_NUMBER_OF_BALLS

		-- Split up the ball that is lowest (aka highest y value)
		local hi = balls:highestBallIndex()
		if hi == nil then
			hix = paddle.x
			hiy = TOP_OF_PADDLE_Y
		else
			hix = balls[hi].x
			hiy = balls[hi].y
		end

		for i = 1, MAX_NUMBER_OF_BALLS do
			balls[i]:moveTo(hix, hiy)

			balls[i]:setVisible(true)
			balls[i]:setUpdatesEnabled(true)
			balls[i].isAlive = true
			-- balls[i].x = hix
			-- balls[i].y = hiy
			p = i - (MAX_NUMBER_OF_BALLS + 1) / 2 --position with zero at center
			balls[i].dx = p
			balls[i].dy = -2 + math.abs(p) / 2
			balls[i].isStuck = false
		end
	else
		paddle:removeAllPowerUps()
	end

	powerUpMessageFadeTimer = 30
	powerUpSound:play()
	score = score + 12
end
