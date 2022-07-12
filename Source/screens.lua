local gfx <const> = playdate.graphics

local heartImgFilled = gfx.image.new('images/heartFilled.png')
local heartImgEmpty = gfx.image.new('images/heartEmpty.png')

local font = gfx.font.new('images/font/blocky')
local minimonofont = gfx.font.new('images/font/Mini Mono 2X')


function displayHomeScreen()
	gfx.setFont(minimonofont)
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(70, SCREEN_HEIGHT / 2 - 20 - 30, 200, 130)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawText("HOME SCREEN!", 90, SCREEN_HEIGHT / 2 - 30)

	if playdate.buttonJustPressed("B") then
		currentGameState = GAME_STATES.LEVEL1
	end

	drawSidePanel()
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


function displayCutScene( level )
	gfx.setFont(minimonofont)
	gfx.setColor(playdate.graphics.kColorWhite)
	gfx.fillRect(70, SCREEN_HEIGHT / 2 - 20 - 30, 200, 130)
	gfx.setColor(playdate.graphics.kColorBlack)
	gfx.drawText("CUTSCENE LEVEL:" .. level, 20, SCREEN_HEIGHT / 2 - 30)

	if playdate.buttonJustPressed("B") then
		currentGameState += 1
	end

	drawSidePanel()
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

	for i=0,3 do
		if (lives > i) then
			heartImgFilled:draw(PANEL_START + paddingLeft + pad*i,paddingTop)
		else
			heartImgEmpty:draw(PANEL_START + paddingLeft + pad*i,paddingTop)
		end
	end

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
	gfx.drawText('SPEED: ', PANEL_START + 10, 32 + linespacing * 3 + 10)


	-- Draw Speed Gauge
	local x1 = PANEL_START + 10
	local y1 = 32 + linespacing * 4 + 5

	for i=1,5 do
		if (gameSpeed >= i) then
			gfx.setLineWidth(1)
			-- gfx.drawLine(x1, y1 + (5*5) - (i*5) , x1 + 10 + i*5, y1 + (5*5) - (i*5) )
			gfx.fillRect(x1, y1 + (5*5) - (i*4) - 1, 10 + i*4, 5)
		else
			gfx.setLineWidth(1)
			gfx.drawRect(x1, y1 + (5*5) - (i*4) - 1, 10 + i*4, 5)
		end
	end

	gfx.drawText('BRICKS: '.. brickCount, PANEL_START + 10, 32 + linespacing * 7)

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

end