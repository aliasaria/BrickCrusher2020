
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

SCREEN_WIDTH = 310
SCREEN_HEIGHT = playdate.display.getHeight()

-- Constants
BALL_ORIGINAL_DY = 2
TOP_OF_PADDLE_Y = 225

MAX_NUMBER_OF_BALLS = 4

-- Important global objects that are sprites
paddle = nil
-- ball = nil
bricks = {}
pills = {}

activeBalls = 1
balls = {}

-- Important global states and variables
score = 0
currentLevel = 3
currentPowerUP = "NONE"
lives = 3
-- Game goes faster and faster as time passes, but is limited
gameSpeed = 1
gameStartTime = 0  -- we do not use playdate.resetElapsedTime() for whatever reason
playerHasBegunPlaying = false

-- Manage the number of gun bullets on the screen
bullets = {}
bulletsOnScreenCount = 0
timeWhenLastBulletWasShot = -99999
-- This is the array of all active Bullets so we can track and remove them


-- when this is greater than 0, it will tell the game
-- to draw the current power up name until the fade timer runs
powerUpMessageFadeTimer = 0

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
local PANEL_START = SCREEN_WIDTH

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

	for i=0,3 do
		if (lives > i) then
			heartImgFilled:draw(PANEL_START + paddingLeft + pad*i,paddingTop)
		else
			heartImgEmpty:draw(PANEL_START + paddingLeft + pad*i,paddingTop)
		end
	end
 
	-- heartImgFilled:draw(PANEL_START + paddingLeft,paddingTop)
	-- heartImgFilled:draw(PANEL_START + paddingLeft + pad,paddingTop)
	-- heartImgFilled:draw(PANEL_START + paddingLeft + pad * 2,paddingTop)
	-- heartImgEmpty:draw(PANEL_START + paddingLeft + pad * 3,paddingTop)

	gfx.drawText('LEVEL: '..currentLevel, PANEL_START + 10, 32)

	gfx.drawText('SCORE: '..score, PANEL_START + 10, 32 + linespacing)

	gfx.drawText('BEST', PANEL_START + 10, 32 + linespacing * 2)
	gfx.drawText('COMBO: ' .. longestCombo, PANEL_START + 10, 32 + linespacing * 2 + 10)

	-- gfx.drawText('POW: '..currentPowerUP, PANEL_START + 10, 32 + linespacing * 2 + 10 + linespacing * 2)
	-- gfx.drawText('ACT: '..activeBalls, PANEL_START + 10, 32 + linespacing * 2 + 10 + linespacing * 2)

	-- gfx.drawText('LIVES: '..lives, PANEL_START + 10, 32 + linespacing * 2 + 10 + linespacing * 3)

	-- gfx.drawText('SPRITES: '..#gfx.sprite.getAllSprites(), PANEL_START + 10, 150+2)
	-- playdate.drawFPS(PANEL_START + 10, 170+2)

	-- gfx.drawText('BUL ON S: ' .. bulletsOnScreenCount, PANEL_START + 10, 32 + linespacing * 2 + 10  + linespacing * 2)
	-- gfx.drawText('TICK ' .. gameStartTime, PANEL_START + 10, 32 + linespacing * 2 + 10  + linespacing * 2)


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

	if (powerUpMessageFadeTimer > 0) then
		gfx.drawText(currentPowerUP, paddle.x - 4, paddle.y-25)
		powerUpMessageFadeTimer = powerUpMessageFadeTimer - 1
	end


	if (lives < 0) then
		gfx.setFont(minimonofont)
		gfx.setColor(playdate.graphics.kColorWhite)
		gfx.fillRect(70, SCREEN_HEIGHT / 2 - 20 - 30, 200, 130)
		gfx.setColor(playdate.graphics.kColorBlack)
		gfx.drawText("GAME OVER!", 90, SCREEN_HEIGHT / 2 - 30)
	end
end

local function gameSpeedSpeedUpIfNeeded()

	if (playerHasBegunPlaying) then
		gameStartTime = gameStartTime + 1
	end

	-- Don't let the game go faster than the max speed of 5
	if (gameSpeed > 5) then
		gameSpeed = 5
	else
		gameSpeed = math.ceil(gameStartTime / 750)
	end

	-- local verticalMoveSpeed = BALL_ORIGINAL_DY * (1+( (gameSpeed-1) / 2))
	-- print(gameSpeed .. ' -> ' .. verticalMoveSpeed)
end

function gameSpeedReset()
	gameSpeed = 1
	gameStartTime = 0
	playerHasBegunPlaying = false
end


-- local function createExplosion(x, y)

-- 	local s = gfx.sprite.new()
-- 	s.frame = 1
-- 	local img = gfx.image.new('images/explosion/'..s.frame)
-- 	s:setImage(img)
-- 	s:moveTo(x, y)

-- 	function s:update()
-- 		s.frame += 1
-- 		if s.frame > 11 then
-- 			s:remove()
-- 		else
-- 			local img = gfx.image.new('images/explosion/'..s.frame)
-- 			s:setImage(img)
-- 		end
-- 	end

-- 	s:setZIndex(2000)
-- 	s:add()

-- end


local function initializeLevel( n )

	for i,v in ipairs(bricks) do
		v:remove()
	end

	for col, v in ipairs(levels[n]) do
		for row, brickVal in ipairs(v) do
			-- print(i2, v2)
			if brickVal ~= 0 then
				local b = createBrick(row, col, brickVal)
				table.insert( bricks, b )
			end
		end
	end
end

local levelStart = true
local function createBricksIfNeeded()
	if (levelStart == true) then
		levelStart = false
		initializeLevel(currentLevel)
	end
end

-- function playdate.cranked(change, acceleratedChange)

-- 	if change > 1 then
-- 		maxEnemies += 1
-- 	elseif change < -1 then
-- 		maxEnemies -= 1
-- 	end

-- end

function restartGame()
	score = 0
	currentLevel = 1
	currentPowerUP = "NONE"
	lives = 3
	if (paddle ~= nil) then
		paddle:remove()
	end
	paddle = createPaddle(130, 231)

	-- Extra balls
	for i,v in ipairs(balls) do
		v:remove()
	end
	-- Create all balls on standby
	balls = createBalls()

	levelStart = true

	-- delete all floating pills
	for i,v in ipairs(pills) do
		v:remove()
	end

	gameSpeedReset()

	bulletsOnScreenCount = 0
	timeWhenLastBulletWasShot = -99999

	-- delete all floating bullets
	for i,v in ipairs(bullets) do
		v:remove()
	end
	bullets = {}
end

function playdate.update()

	if (lives < 0) then
		drawSidePanel()
		return
	end

	-- Shoot bullets if you have the Gun
	if playdate.buttonJustPressed("A") then
		-- Don't shoot if you have a ball stuck to you right now
		if (paddle.hasGun and paddle.isStuck == false) then

			local now = playdate.getCurrentTimeMilliseconds()

			local delay = (now - timeWhenLastBulletWasShot)

			if (bulletsOnScreenCount > 1 or delay < 350) then
				return
			end

			local b = playerFire()

			-- Add this bullet to the global list of bullets
			-- WE don't know how to manage this table and remove so leave out for now ... @TODO table.insert(bullets, b)
			
		end
	end

	if playdate.buttonJustPressed("B") then
		-- playerFire()
		balls:shootBalls()
	end

	createBricksIfNeeded()

	gfx.sprite.update()
	
	drawSidePanel()

	gameSpeedSpeedUpIfNeeded()
end

function playdate.keyPressed(key)
	if (key == "q") then
		powerUp("MLTI")
	elseif (key == "w") then
		powerUp("GUN")
	elseif (key =="e") then
		powerUp("STKY")
	elseif (key =="r") then
		powerUp("SHORT")
	elseif (key =="t") then
		powerUp("SLOW")
	end
end

-- ------------------
-- ------------------
-- Build Menu
-- ------------------
-- ------------------
local menu = playdate.getSystemMenu()

local menuItem, error = menu:addMenuItem("Restart Game", function()
    restartGame()
end)

-- local checkmarkMenuItem, error = menu:addCheckmarkMenuItem("Item 2", true, function(value)
--     print("Checkmark menu item value changed to: ", value)
-- end)

-- ------------------
-- ------------------
-- Let's do this! ...
-- ------------------
-- ------------------
playdate.display.setRefreshRate(30)
restartGame()
-- ball = createBall(130,220,0,0)
local startMusic = playdate.sound.sampleplayer.new('sounds/8BitRetroSFXPack1_Traditional_GameStarting08.wav')
startMusic:play()


