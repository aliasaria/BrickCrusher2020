-- This script will only rebuild lua scripts. Requires you did a full build first!
-- Useful for when you need to do a quick rebuild when tweaking values and haven't made changes to assets.

local build = require("playbit.build")

build.build({ 
  assert = true,
  debug = true,
  platform = "love2d",
  output = "_love2d",
  clearBuildFolder = false,
  fileProcessors = {
    lua = build.luaProcessor,
  },
  files = {
    { "src/scripts", "scripts" },
    { "src/main.lua", "main.lua" },
  },
})