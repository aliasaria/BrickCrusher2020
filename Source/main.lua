
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
-- import 'CoreLibs/animation'
-- import 'CoreLibs/input'

import 'ball.lua'
import 'paddle.lua'
import 'ball.lua'
import 'pill.lua'
import 'levels.lua'
import 'bricks.lua'

local gfx = playdate.graphics

-- playdate.inputHandlers.push(playdate.input)

local s, ms = playdate.getSecondsSinceEpoch()
math.randomseed(ms,s)

local font = gfx.font.new('images/font/blocky')
local minimonofont = gfx.font.new('images/font/Mini Mono 2X')

SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

paddle = nil
ball = nil

score = 0
currentLevel = 1
currentPowerUP = "NONE"

SpriteTypes = {
	PADDLE = 1,
	BALL = 2,
	BRICK = 3,
	VIOLET = 4,
	YELLOW = 5,
 }

-- Side Panel
local heartImgFilled = gfx.image.new('images/heartFilled.png')
local heartImgEmpty = gfx.image.new('images/heartEmpty.png')
local PANEL_START = 320



holdComboPositionX = nil
holdComboPositionY = nil
local function drawSidePanel()
	gfx.setFont(font)

	-- Draw Border
	gfx.setLineWidth(3)
	gfx.drawLine(PANEL_START, 0, PANEL_START, SCREEN_HEIGHT)

	-- Draw Life Hearts
	local pad = heartImgFilled.width + 1
	local paddingTop = 6
	local paddingLeft = 10
	local linespacing = 16

	heartImgFilled:draw(PANEL_START + paddingLeft,paddingTop)
	heartImgFilled:draw(PANEL_START + paddingLeft + pad,paddingTop)
	heartImgFilled:draw(PANEL_START + paddingLeft + pad * 2,paddingTop)
	heartImgEmpty:draw(PANEL_START + paddingLeft + pad * 3,paddingTop)

	gfx.drawText('LEVEL: '..currentLevel, PANEL_START + 10, 32)

	gfx.drawText('SCORE: '..score, PANEL_START + 10, 32 + linespacing)

	gfx.drawText('BEST', PANEL_START + 10, 32 + linespacing * 2)
	gfx.drawText('COMBO: ' .. longestCombo, PANEL_START + 10, 32 + linespacing * 2 + 10)

	gfx.drawText('POW: '..currentPowerUP, PANEL_START + 10, 32 + linespacing * 2 + 10 + linespacing * 2)

	gfx.drawText('SPRITES: '..#gfx.sprite.getAllSprites(), PANEL_START + 10, 150+2)
	playdate.drawFPS(PANEL_START + 10, 170+2)

	local now = playdate.getCurrentTimeMilliseconds()
	-- gfx.setFont(minimonofont)

	-- if (now - lastHitTime) > 250 and (comboCounter > 1) then
	-- 	holdComboPositionX = comboPositionX
	-- 	holdComboPositionY = comboPositionY
	-- 	-- print(comboCounter)
	-- 	gfx.drawText(comboCounter .. ' COMBO!', comboPositionX, comboPositionY)
	-- end

	if (lastComboPositionX ~= 0 and (now - lastComboTime) < 750) then
		gfx.drawText(lastComboSize .. ' COMBO!', lastComboPositionX, lastComboPositionY)
	end

end

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
		if (currentPowerUP == "GUN") then
			playerFire()
		end
	end

	if playdate.buttonJustPressed("B") then
		-- playerFire()
	end

	createBricksIfNeeded()

	gfx.sprite.update()
	
	drawSidePanel()
end

-- ------------------
-- ------------------
-- Let's do this! ...
-- ------------------
-- ------------------
playdate.display.setRefreshRate(50)
paddle = createPaddle(130, 231)
-- ball = createBall(130,220,1,-2)
ball = createBall(0,0,12,2)
local startMusic = playdate.sound.sampleplayer.new('sounds/8BitRetroSFXPack1_Traditional_GameStarting08.wav')
startMusic:play()


