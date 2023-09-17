-- From  Neven Mrgan on playdate devforum
-- This page writes a text box sprite to the screen, and animates it as if it's being typed.
local gfx <const> = playdate.graphics

PANEL_START = 310

local WIDTH = PANEL_START - 15
local HEIGHT = 120

textbox = gfx.sprite.new()
textbox:setSize(WIDTH, HEIGHT)
textbox:setCenter(0, 0)
textbox:moveTo(10, 10)
textbox:setZIndex(2000)
textbox.text = ""       -- this is blank for now; we can set it at any point
textbox.currentChar = 1 -- we'll use these for the animation
textbox.currentText = ""
textbox.typing = true
textbox.currentPageNumber = 1
textbox.pages = {}
textbox.finished = false

local font = gfx.font.new('images/font/Mini Mono 2X')
local smallfont = gfx.font.new('images/font/Mini Mono')

--Advance Menu Button
--If this is true, then either A or the Downbutton is being pressed
local function advanceMenu()
    if (playdate.buttonJustPressed("A") or playdate.buttonJustPressed("DOWN")) then
        return true
    end
    return false
end

function textbox:init(text)
    -- self.text = text
    self.currentChar = 1
    self.currentText = ""
    self.typing = true
    self.finished = false


    -- split the text into pages based on \f delimeter
    self.pages = {}
    self.currentPage = ""
    for line in string.gmatch(text, "[^\f]+") do
        table.insert(self.pages, line)
    end
    self.text = self.pages[1]
    self.currentPageNumber = 1

    -- printTable(self.pages)
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
        if (self.currentPageNumber < #self.pages) then
            self.typing = false
        else
            self.currentChar = 1
            self.typing = false
            self.finished = true
        end
    end

    if advanceMenu() then
        if (self.typing == false and self.finished == false) then
            -- If at page end, wait for press of A
            self.currentPageNumber = self.currentPageNumber + 1
            self.text = self.pages[self.currentPageNumber]
            self.currentChar = 1
            self.typing = true
        else
            if (self.typing == true) then
                -- If typing, skip to end of text
                self.currentChar = #self.text
            end
        end
    end
end

-- this function defines how this sprite is drawn
function textbox:draw()
    -- pushing context means, limit all the drawing config to JUST this block
    -- that way, the colors we set etc. won't be stuck
    gfx.pushContext()

    -- draw the box				
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, WIDTH, HEIGHT)

    -- border
    gfx.setLineWidth(4)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(0, 0, WIDTH, HEIGHT)

    -- draw the text!
    gfx.setFont(font)
    gfx.drawTextInRect(self.currentText, 10, 10, WIDTH - 20, HEIGHT - 20)
    -- print("drawing")

    gfx.setFont(smallfont)
    if (self.typing) then
        gfx.drawText("(A) >", 250, HEIGHT - 12)
    elseif self.finished == false then
        gfx.drawText("(A) Next page...", 160, HEIGHT - 12)
    else
        gfx.drawText("(A) to continue", 163, HEIGHT - 12)
    end

    gfx.popContext()
end
