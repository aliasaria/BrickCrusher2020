
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

hitSound = playdate.sound.sampleplayer.new('sounds/Wall_Light_Double_Switch_Off-004.wav')

SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

local enemyCount = 0

paddle = nil
ball = nil

score = 0
currentLevel = 1

local bgY = 0
local bgH = 0

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
paddle = createPaddle(200, 233)
ball = createBall(0,0)


local startMusic = playdate.sound.sampleplayer.new('sounds/8BitRetroSFXPack1_Traditional_GameStarting08.wav')
startMusic:play()


