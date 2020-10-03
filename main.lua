Gamestate = require "hump.gamestate"

require "game"

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(game)

  love.window.setTitle("Ludum Dare 47")
end

function setupWindow()
  love.window.setMode(800, 600)
end
