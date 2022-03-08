
local gfx = playdate.graphics

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
					if math.random(2) == 1 then
						powerUp("GUN")
					else
						powerUp("LONG")
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
function powerUp( type )
	currentPowerUP = type

	if (type == "LONG") then
		paddle:grow()
	elseif (type == "GUN") then
		paddle:addGun()
	end
	
    powerUpSound:play()
    score += 12
end