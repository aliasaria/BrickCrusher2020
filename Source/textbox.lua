-- From  Neven Mrgan on playdate devforum
local gfx <const> = playdate.graphics

local WIDTH = 320
local HEIGHT = 140

textbox = gfx.sprite.new()
textbox:setSize(WIDTH, HEIGHT)
textbox:setCenter(0, 0)
textbox:moveTo(10, 10)
textbox:setZIndex(900)
textbox.text = ""       -- this is blank for now; we can set it at any point
textbox.currentChar = 1 -- we'll use these for the animation
textbox.currentText = ""
textbox.typing = true

local font = gfx.font.new('images/font/Mini Mono 2X')
local smallfont = gfx.font.new('images/font/Mini Mono')

function textbox:init(text)
    self.text = text
    self.currentChar = 1
    self.currentText = ""
    self.typing = true
end

-- this function will calculate the string to be used.
-- it won't actually draw it; the following draw() function will.
function textbox:update()
    self.currentChar = self.currentChar + 1
    if self.currentChar > #self.text then
        self.currentChar = #self.text
    end

    if self.typing and self.currentChar <= #self.text then
        textbox.currentText = string.sub(self.text, 1, self.currentChar)
        self:markDirty() -- this tells the sprite that it needs to redraw
    end

    -- end typing
    if self.currentChar == #self.text then
        self.currentChar = 1
        self.typing = false
    end
end

-- this function defines how this sprite is drawn
function textbox:draw()
    -- pushing context means, limit all the drawing config to JUST this block
    -- that way, the colors we set etc. won't be stuck
    gfx.pushContext()

    -- draw the box				
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, WIDTH, HEIGHT - 20)

    -- border
    gfx.setLineWidth(4)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0, 0, WIDTH, HEIGHT - 20)

    -- draw the text!
    gfx.setFont(font)
    gfx.drawTextInRect(self.currentText, 10, 10, WIDTH - 20, HEIGHT - 20 - 20)
    -- print("drawing")

    gfx.setFont(smallfont)
    if (self.typing == false) then
        gfx.drawText("Press (A) to continue...", 10, HEIGHT - 14)
    end

    gfx.popContext()
end
