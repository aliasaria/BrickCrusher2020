local build = require("playbit.build")

build.build({
  assert = true,
  debug = true,
  platform = "love2d",
  output = "_love2d",
  clearBuildFolder = true,
  fileProcessors = {
    lua = build.luaProcessor,
    fnt = build.fntProcessor,
    aseprite = build.asepriteProcessor,
  },
  files = {
    -- essential playbit files for love2d
    { "playbit/conf.lua",      "conf.lua" },
    { "playbit/playbit",       "playbit" },
    { "playbit/playdate",      "playdate" },
    { "playbit/json/json.lua", "json/json.lua" },
    -- project
    { "Source/images/font",    "fonts" },
    { "scripts",               "scripts" },
    { "Source/",               "./" },
    { "Source/sounds",         "sounds" },
    { "Source/main.lua",       "main.lua" },
    { "Source/metadata.json", "pdxinfo",
      {
        json = { build.pdxinfoProcessor, { incrementBuildNumber = false } }
      }
    }
  },
})
