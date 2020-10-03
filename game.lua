local Camera = require("Camera")

local Map = require("map")
local Player = require("player")

game = {
  translate = {0, 0},
  scaling = 1,
  phase = "build",
}

function game:calculateScaling()
  local minEdge = love.graphics.getHeight()
  if minEdge < love.graphics.getWidth() then
    game.scaling = minEdge / 600
     game.translate = {(love.graphics.getWidth() - (800 * game.scaling)) / 2, 0}
  else
    game.scaling = love.graphics.getWidth() / 800
  end
end

function game:init() 
  -- Window setup
  love.window.setMode(800, 600)
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setFullscreen(true)

  game:calculateScaling()

  self.map = Map(self)

  self.camera = Camera(0, 0, 800, 600)
  self.camera:setFollowStyle('TOPDOWN_TIGHT')
  self.camera:setBounds(0, 0, self.map:getWidth(), self.map:getHeight())

  local playerStart = self.map:getPlayerStartPosition()

  print(self.map:getWorld())

  self.player = Player(self.map:getWorld(), playerStart.x, playerStart.y)
end

function game:resize()
  love.window.setMode(800, 600)
  game:calculateScaling()
end

function game:keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function game:mousepressed(x, y, button)
  if button ~= 1 then
    return
  end

  local mx, my = self:getMousePosition()

  if self.phase == "build" then
    if self.map:canBuild(mx, my) then
      self.map:addTrap(mx, my)
    end
  end
end

function game:update(dt)
  self.map:update(dt)
  self.player:update(dt)

  self.camera:update(dt)
  self.camera:follow(self.player:getX(), self.player:getY())
end

function game:getMousePosition() 
  local mx, my = love.mouse.getPosition()

  mx = (mx - self.translate[1]) / self.scaling
  my = (my - self.translate[2]) / self.scaling

  local cx, cy = self.camera:toWorldCoords(mx, my)

  return cx, cy
end

function game:draw()
  love.graphics.push()
  love.graphics.translate(game.translate[1], game.translate[2])
  love.graphics.scale(game.scaling)

  love.graphics.setColor(1, 1, 1)

  -- Draw game
  self.camera:attach()
  self.map:draw()
  self.player:draw()
  self.camera:detach()
  
  love.graphics.pop()

  -- -- Draw borders
  love.graphics.setColor(conf.borderColor[1], conf.borderColor[2], conf.borderColor[3])
  love.graphics.rectangle("fill", 0, 0, game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), game.translate[2])
  love.graphics.rectangle("fill", love.graphics.getWidth() - game.translate[1], 0, game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - game.translate[2], love.graphics.getWidth(), game.translate[2])
end
