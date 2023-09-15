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
GAME_AREA_WIDTH = 310
GAME_AREA_HEIGHT = playdate.display.getHeight()
SCREEN_WIDTH = playdate.display.getWidth()
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
	GAMEOVER            = 0,
	HOMESCREEN          = 1,
	HOMESCREEN_CUTSCENE = 2,
	LEVEL1              = 3,
	LEVEL2_CUTSCENE     = 4,
	LEVEL2              = 5,
	LEVEL3_CUTSCENE     = 6,
	LEVEL3              = 7,
	LEVEL4_CUTSCENE     = 8,
	LEVEL4              = 9,
	LEVEL5_CUTSCENE     = 10,
	LEVEL5              = 11,
	LEVEL6_CUTSCENE     = 12,
	LEVEL6              = 13,
	LEVEL7_CUTSCENE     = 14,
	LEVEL7              = 15,
	THEEND              = 16
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
-- the following global stores the game state type like "CUTSCENE" or "LEVEL"
GAME_STATE_TYPE = "HOMESCREEN"
currentPowerUP = "NONE"
lives = 3

brickCount = 0             -- total number of bricks on the screen

NUMBER_OF_BALL_BOUNCES = 0 -- used to track the number of bounces for managing ball speed

-- Game goes faster and faster as time passes, but is limited
gameSpeed = 1
gameStartTime = 1 -- we do not use playdate.resetElapsedTime() for whatever reason

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

PANEL_START = GAME_AREA_WIDTH

holdComboPositionX = nil
holdComboPositionY = nil

local cityBackground = gfx.image.new('images/backgrounds/city3.png')


local function gameSpeedSpeedUpIfNeeded()
	-- Don't let the game go faster than the max speed of 5
	if (gameSpeed >= 5) then
		gameSpeed = 5
	else
		gameSpeed = math.ceil(NUMBER_OF_BALL_BOUNCES // 16) + 1
	end

	print(gameSpeed)
end

function gameSpeedReset()
	gameSpeed = 1

	if (DEBUG) then
		gameSpeed = 5
	end
end

local function initializeLevel(n)
	gfx.sprite.removeAll()

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

	-- Reset core things
	resetPaddle()
	balls = createBalls()
	resetAllBalls()
	removeAllPillsAndBullets()
	gameSpeedReset()

	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			-- x,y,width,height is the updated area in sprite-local coordinates
			-- The clip rect is already set to this area, so we don't need to set it ourselves
			cityBackground:drawFaded(0, 0, 0.3, gfx.image.kDitherTypeScreen)
		end
	)

	GAME_STATE_TYPE = "LEVEL"
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
	end
end

function resetPaddle()
	if (paddle ~= nil) then
		paddle:remove()
		paddle = nil
	end
	paddle = createPaddle(130, TOP_OF_PADDLE_Y + 6)
end

function restartGame()
	score = 0
	currentLevel = 1
	GAME_STATE_TYPE = "HOMESCREEN"
	currentPowerUP = "NONE"
	currentGameState = GAME_STATES.HOMESCREEN
	lives = 3

	resetPaddle()
	-- Extra balls
	for i, v in ipairs(balls) do
		v:remove()
	end

	-- Create all balls on standby (moved to initializeLevel)
	-- balls = createBalls()
	-- resetMainBall()

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
		-- Proceed to a cutscene
		currentGameState += 1
		initCutscene(currentLevel)
	elseif currentGameState == GAME_STATES.LEVEL7 then
		currentGameState = GAME_STATES.THEEND
		GAME_STATE_TYPE = "ENDSCREEN"
		currentLevel = 7
	end
end

-- This function is the meat of the game which is to be run in the main loop
-- when we are in active gameplay
function gameUpdate()
	-- Shoot bullets if you have the Gun
	if playdate.buttonJustPressed("B") or playdate.buttonIsPressed("UP") then
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

	if playdate.buttonJustPressed("A") or playdate.buttonIsPressed("DOWN") then
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
	if (GAME_STATE_TYPE == "LEVEL") then
		gameUpdate()
		return
	elseif (currentGameState == GAME_STATES.GAMEOVER) then
		gameOverScreenUpdate()
		return
	elseif (currentGameState == GAME_STATES.HOMESCREEN) then
		homeScreenUpdate()
		return
	elseif (GAME_STATE_TYPE == "CUTSCENE") then
		cutSceneUpdate(currentLevel)
	elseif (currentGameState == GAME_STATES.THEEND) then
		theEndUpdate()
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
		if (GAME_STATE_TYPE == "LEVEL") then
			nextLevel()
		end
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
