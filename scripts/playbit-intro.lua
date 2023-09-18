-- This is the Playbit intro sequence/splash. Use it in your project if you'd like to show that you've used Playbit!

module = {}
playbitIntro = module

local image = nil
local startupSfx = nil
local hasPlayedSfx = false

function module.isComplete()
  -- TODO: when (future) animation is implemented, return true when anim is done instead
  return hasPlayedSfx and not startupSfx:isPlaying()
end

function module.init()
  image = playdate.graphics.image.new("textures/playbit-logo")
  startupSfx = playdate.sound.sampleplayer.new("sounds/playbit-startup")
  hasPlayedSfx = false
end

function module.update()
  if not hasPlayedSfx then
    startupSfx:play()
    hasPlayedSfx = true
  end

  image:draw(0, 0)
end

function module.destroy()
  image = nil
  startupSfx = nil
end