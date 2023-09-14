-- ------------------------------
-- ------------------------------
-- Imports
-- ------------------------------
-- ------------------------------
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
import 'screens.lua'

local gfx <const> = playdate.graphics

-- playdate.inputHandlers.push(playdate.input)

local s, ms = playdate.getSecondsSinceEpoch()
math.randomseed(ms, s)

-- ------------------------------
-- ------------------------------
-- Constants
-- ------------------------------
-- ------------------------------
SCREEN_WIDTH = 310
SCREEN_HEIGHT = playdate.display.getHeight()

BALL_ORIGINAL_DY = 2
TOP_OF_PADDLE_Y = 225

MAX_NUMBER_OF_BALLS = 4

SpriteTypes = {
	PADDLE = 1,
	BALL = 2,
	BRICK = 3,
	PILL = 4,
	BULLET = 5
}

-- The game goes through these states in order
-- the current state is stored in currentGameState
GAME_STATES = {
	GAMEOVER        = 0,
	HOMESCREEN      = 1,
	LEVEL1          = 2,
	LEVEL2_CUTSCENE = 3,
	LEVEL2          = 4,
	LEVEL3_CUTSCENE = 5,
	LEVEL3          = 6,
	LEVEL4_CUTSCENE = 7,
	LEVEL4          = 8,
	LEVEL5_CUTSCENE = 9,
	LEVEL5          = 10,
	LEVEL6_CUTSCENE = 11,
	LEVEL6          = 12,
	LEVEL7_CUTSCENE = 13,
	LEVEL7          = 14,
	THEEND          = 15
}

-- If this is true, the ball will never die, it will just bounce back
-- Only use this for debugging / testing
DEBUG = false

-- ------------------------------
-- ------------------------------
-- Globals
-- ------------------------------
-- ------------------------------

-- Important global objects that are sprites
paddle = nil
-- ball = nil
bricks = {}
pills = {}

activeBalls = 1
balls = {}

-- Important global states and variables
score = 0
currentLevel = 1
currentGameState = GAME_STATES.HOMESCREEN
currentPowerUP = "NONE"
lives = 3

brickCount = 0 -- total number of bricks on the screen

-- Game goes faster and faster as time passes, but is limited
gameSpeed = 1
gameStartTime = 1 -- we do not use playdate.resetElapsedTime() for whatever reason
playerHasBegunPlaying = false

-- Manage the number of gun bullets on the screen
bullets = {}
bulletsOnScreenCount = 0
timeWhenLastBulletWasShot = -99999
-- This is the array of all active Bullets so we can track and remove them


-- when this is greater than 0, it will tell the game
-- to draw the current power up name until the fade timer runs
powerUpMessageFadeTimer = 0

-- This is true at the start of a level, before the level is loaded
local levelNeedsInitialization = true

-- ------------------------------
-- ------------------------------
-- Side Panel
-- ------------------------------
-- ------------------------------

PANEL_START = SCREEN_WIDTH

holdComboPositionX = nil
holdComboPositionY = nil


local function gameSpeedSpeedUpIfNeeded()
	if (playerHasBegunPlaying) then
		gameStartTime = gameStartTime + 1
	end

	-- Don't let the game go faster than the max speed of 5
	if (gameSpeed >= 5) then
		gameSpeed = 5
	else
		gameSpeed = math.ceil(gameStartTime / 750)
	end

	-- local verticalMoveSpeed = BALL_ORIGINAL_DY * (1+( (gameSpeed-1) / 2))
	-- print(gameSpeed .. ' -> ' .. verticalMoveSpeed)
end

function gameSpeedReset()
	gameSpeed = 1

	if (DEBUG) then
		gameSpeed = 5
	end

	gameStartTime = 1
	playerHasBegunPlaying = false
end

local function initializeLevel(n)
	for i, v in ipairs(bricks) do
		if v ~= nil then
			v:remove()
		end
	end

	brickCount = 0

	for col, v in ipairs(levels[n]) do
		for row, brickVal in ipairs(v) do
			-- print(i2, v2)
			if brickVal ~= 0 then
				local b = createBrick(row, col, brickVal)
				table.insert(bricks, b)
			end
		end
	end
end

function removeAllPillsAndBullets()
	gfx.sprite.performOnAllSprites(function(sprite)
		if (sprite:getTag() == SpriteTypes.PILL or sprite:getTag() == SpriteTypes.BULLET) then
			sprite:remove()
		end
	end)
end

local function createBricksIfNeeded()
	if (levelNeedsInitialization == true) then
		levelNeedsInitialization = false
		initializeLevel(currentLevel)
		resetAllBalls()
		removeAllPillsAndBullets()
		gameSpeedReset()
	end
end

function restartGame()
	score = 0
	currentLevel = 1
	currentPowerUP = "NONE"
	currentGameState = GAME_STATES.HOMESCREEN
	lives = 3
	if (paddle ~= nil) then
		paddle:remove()
	end
	paddle = createPaddle(130, TOP_OF_PADDLE_Y + 6)

	-- Extra balls
	for i, v in ipairs(balls) do
		v:remove()
	end
	-- Create all balls on standby
	balls = createBalls()
	resetMainBall()

	levelNeedsInitialization = true

	-- delete all floating pills
	removeAllPillsAndBullets()

	gameSpeedReset()

	bulletsOnScreenCount = 0
	timeWhenLastBulletWasShot = -99999

	-- delete all floating bullets
	for i, v in ipairs(bullets) do
		v:remove()
	end
	bullets = {}
end

-- Call this function to advance to the next level
function nextLevel()
	currentLevel += 1
	levelNeedsInitialization = true

	if (currentGameState == GAME_STATES.LEVEL1
			or currentGameState == GAME_STATES.LEVEL2
			or currentGameState == GAME_STATES.LEVEL3
			or currentGameState == GAME_STATES.LEVEL4
			or currentGameState == GAME_STATES.LEVEL5
			or currentGameState == GAME_STATES.LEVEL6
		) then
		currentGameState += 1
	elseif currentGameState == GAME_STATES.LEVEL7 then
		currentGameState = GAME_STATES.THEEND
		currentLevel = 7
	end
end

-- This function is the meat of the game which is to be run in the main loop
-- when we are in active gameplay
function gameUpdate()
	-- Shoot bullets if you have the Gun
	if playdate.buttonJustPressed("A") or playdate.buttonIsPressed("UP") then
		-- Don't shoot if you have a ball stuck to you right now ( @TODO )
		if (paddle.hasGun) then
			local now = playdate.getCurrentTimeMilliseconds()

			local delay = (now - timeWhenLastBulletWasShot)

			if (bulletsOnScreenCount > 1 or delay < 350) then
				-- do nothing if there are too many bullets on the screen
			else
				local b = playerFire()
			end

			-- Add this bullet to the global list of bullets
			-- WE don't know how to manage this table and remove so leave out for now ... @TODO table.insert(bullets, b)
		end
	end

	if playdate.buttonJustPressed("B") or playdate.buttonIsPressed("DOWN") then
		balls:shootBalls()
	end

	createBricksIfNeeded()

	gfx.sprite.update()

	drawSidePanel()

	gameSpeedSpeedUpIfNeeded()
end

-- ------------------------------
-- ------------------------------
-- The main loop
-- ------------------------------
-- ------------------------------
function playdate.update()
	-- If we are in an active level then do the following
	if (
			currentGameState == GAME_STATES.LEVEL1
			or currentGameState == GAME_STATES.LEVEL2
			or currentGameState == GAME_STATES.LEVEL3
			or currentGameState == GAME_STATES.LEVEL4
			or currentGameState == GAME_STATES.LEVEL5
			or currentGameState == GAME_STATES.LEVEL6
			or currentGameState == GAME_STATES.LEVEL7
		) then
		gameUpdate()
		return
	elseif (currentGameState == GAME_STATES.GAMEOVER) then
		displayGameOverScreen()
		return
	elseif (currentGameState == GAME_STATES.HOMESCREEN) then
		displayHomeScreen()
		return
	elseif (currentGameState == GAME_STATES.LEVEL2_CUTSCENE
			or currentGameState == GAME_STATES.LEVEL3_CUTSCENE
			or currentGameState == GAME_STATES.LEVEL4_CUTSCENE
			or currentGameState == GAME_STATES.LEVEL5_CUTSCENE
			or currentGameState == GAME_STATES.LEVEL6_CUTSCENE
			or currentGameState == GAME_STATES.LEVEL7_CUTSCENE) then
		displayCutScene(currentLevel)
	elseif (currentGameState == GAME_STATES.THEEND) then
		displayTheEnd()
	end
end

-- CHEAT CODES
-- Remove in production -- this hack let's us fake getting a pill
-- for testing
function playdate.keyPressed(key)
	if (key == "q") then
		powerUp("MLTI")
	elseif (key == "w") then
		powerUp("GUN")
	elseif (key == "e") then
		powerUp("STKY")
	elseif (key == "r") then
		powerUp("SHORT")
	elseif (key == "t") then
		powerUp("SLOW")
	elseif (key == "y") then
		powerUp("1UP")
	elseif (key == ".") then
		nextLevel()
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

-- Play the startup music
local startMusic = playdate.sound.sampleplayer.new('sounds/8BitRetroSFXPack1_Traditional_GameStarting08.wav')
startMusic:play()
