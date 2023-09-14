import 'textbox.lua'
import 'cutscene_text.lua'

local gfx <const> = playdate.graphics

local cityscapeBackground = gfx.image.new('images/backgrounds/cityscape_background.png')
local city1 = gfx.image.new('images/backgrounds/city1.png')
-- local city2 = gfx.image.new('images/backgrounds/city3.png')

local heartImgFilled = gfx.image.new('images/heartFilled.png')
local heartImgEmpty = gfx.image.new('images/heartEmpty.png')

local font = gfx.font.new('images/font/Mini Mono')
local minimonofont = gfx.font.new('images/font/Mini Mono 2X')

local ScreenWidth = playdate.display.getWidth()


function displayHomeScreen()
	cityscapeBackground:draw(0, 0)

	local paddingTop = 100

	gfx.setFont(minimonofont)
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(5, paddingTop, 280, 24)
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.drawText("BRICKCRUSHER 2000", 10, paddingTop + 5)

	gfx.fillRect(120, 220, 150, 20)
	gfx.setFont(font)
	gfx.drawText("PRESS A TO START", 134, 227)

	if playdate.buttonJustPressed("A") then
		initCutscene(1)
		currentGameState = GAME_STATES.HOMESCREEN_CUTSCENE
		GAME_STATE_TYPE = "CUTSCENE"
	end

	gfx.setColor(playdate.graphics.kColorBlack)
	-- drawSidePanel()
end

function displayGameOverScreen()
	gfx.setFont(minimonofont)
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(70, SCREEN_HEIGHT / 2 - 20 - 30, 200, 130)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawText("GAMEOVER!", 90, SCREEN_HEIGHT / 2 - 30)

	if playdate.buttonJustPressed("B") then
		restartGame()
	end

	drawSidePanel()
end

function displayTheEnd()
	gfx.setFont(minimonofont)
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(70, SCREEN_HEIGHT / 2 - 20 - 30, 200, 130)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawText("YOU HAVE WON!", 90, SCREEN_HEIGHT / 2 - 30)

	if playdate.buttonJustPressed("B") then
		restartGame()
	end

	drawSidePanel()
end

local xScroll = 1

function initCutscene(level)
	gfx.sprite.removeAll()
	xScroll = 1

	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			-- x,y,width,height is the updated area in sprite-local coordinates
			-- The clip rect is already set to this area, so we don't need to set it ourselves
			local slowerScroll = xScroll // 2 -- double slash is a rounded divide in Lua
			city1:draw(slowerScroll, 0)
			city1:draw(slowerScroll - ScreenWidth, 0)
		end
	)

	textbox:init(CUTSCENE_TEXT[level])
	textbox:add()

	GAME_STATE_TYPE = "CUTSCENE"
end

function displayCutScene(level)
	if playdate.buttonJustPressed("A") then
		if (textbox.finished) then
			textbox:remove()
			currentGameState += 1
			GAME_STATE_TYPE = "LEVEL"
		end
	end

	xScroll += 1
	if (xScroll < ScreenWidth * 2) then
		playdate.graphics.sprite.redrawBackground()
	end

	gfx.sprite.update()
end

function drawSidePanel()
	gfx.setFont(font)

	-- Draw Border
	gfx.setLineWidth(3)
	gfx.drawLine(PANEL_START, 0, PANEL_START, SCREEN_HEIGHT)

	-- Draw line where the paddle is
	-- gfx.setLineWidth(1)
	-- gfx.drawLine(0, TOP_OF_PADDLE_Y, PANEL_START, TOP_OF_PADDLE_Y)

	-- Draw collision boundaries manually for testing
	-- local x, y, width, height = paddle:getBounds()

	-- gfx.setLineWidth(1)
	-- gfx.drawLine(0, TOP_OF_PADDLE_Y, 300, TOP_OF_PADDLE_Y)
	-- gfx.drawLine(0, 10, 300, 10)
	-- gfx.drawLine(x, 0, x, SCREEN_HEIGHT)

	-- Draw Life Hearts
	local pad = heartImgFilled.width + 1
	local paddingTop = 6
	local paddingLeft = 10
	local linespacing = 16

	for i = 0, 3 do
		if (lives > i) then
			heartImgFilled:draw(PANEL_START + paddingLeft + pad * i, paddingTop)
		else
			heartImgEmpty:draw(PANEL_START + paddingLeft + pad * i, paddingTop)
		end
	end

	gfx.drawText('LEVEL: ' .. currentLevel, PANEL_START + 10, 32)

	gfx.drawText('SCORE: ' .. score, PANEL_START + 10, 32 + linespacing)

	gfx.drawText('BEST', PANEL_START + 10, 32 + linespacing * 2)
	gfx.drawText('COMBO: ' .. longestCombo, PANEL_START + 10, 32 + linespacing * 2 + 10)

	-- gfx.drawText('POW: '..currentPowerUP, PANEL_START + 10, 32 + linespacing * 2 + 10 + linespacing * 2)
	-- gfx.drawText('ACT: '..activeBalls, PANEL_START + 10, 32 + linespacing * 2 + 10 + linespacing * 2)

	-- gfx.drawText('LIVES: '..lives, PANEL_START + 10, 32 + linespacing * 2 + 10 + linespacing * 3)

	-- gfx.drawText('SPRITES: '..#gfx.sprite.getAllSprites(), PANEL_START + 10, 150+2)
	-- playdate.drawFPS(PANEL_START + 10, 170+2)

	-- gfx.drawText('BUL ON S: ' .. bulletsOnScreenCount, PANEL_START + 10, 32 + linespacing * 2 + 10  + linespacing * 2)
	gfx.drawText('SPEED: ', PANEL_START + 10, 32 + linespacing * 3 + 10)


	-- Draw Speed Gauge
	local x1 = PANEL_START + 10
	local y1 = 32 + linespacing * 4 + 5

	for i = 1, 5 do
		if (gameSpeed >= i) then
			gfx.setLineWidth(1)
			-- gfx.drawLine(x1, y1 + (5*5) - (i*5) , x1 + 10 + i*5, y1 + (5*5) - (i*5) )
			gfx.fillRect(x1, y1 + (5 * 5) - (i * 4) - 1, 10 + i * 4, 5)
		else
			gfx.setLineWidth(1)
			gfx.drawRect(x1, y1 + (5 * 5) - (i * 4) - 1, 10 + i * 4, 5)
		end
	end

	gfx.drawText('BRICKS: ' .. brickCount, PANEL_START + 10, 32 + linespacing * 7)

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
		gfx.drawText(currentPowerUP, paddle.x - 4, paddle.y - 25)
		powerUpMessageFadeTimer = powerUpMessageFadeTimer - 1
	end
end
