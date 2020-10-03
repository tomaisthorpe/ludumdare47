local Camera = require("Camera")

local Map = require("map")
local Player = require("player")
local Enemy = require("enemy")
local WaveGen = require("waves")

game = {
  translate = {0, 0},
  scaling = 1,
  phase = "build",
  lastSpawn = 0,
  enemies = {},
  startButton = {
    x1 = 800 - 110,
    y1 = 600 - 60,
    x2 = 800 - 10,
    y2 = 600 - 10,
  },
  wave = 1,
  waveSpawnComplete = false,
  lives = 10,
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

  self.player = Player(self.map:getWorld(), playerStart.x, playerStart.y)
  self.waveGen = WaveGen(self, self.map.spawners)
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

function game:removeLife()
  self.lives = self.lives - 1
  if self.lives < 0 then
    self.lives = 0
  end
end

function game:mousepressed(x, y, button)
  if button ~= 1 then
    return
  end

  local mx, my, cx, cy = self:getMousePosition()

  if self.phase == "build" then
    local button = self.startButton
    -- Check if the user pressed on the start button
    if mx >= button.x1 and mx <= button.x2 and my >= button.y1 and my <= button.y2 then
      self:startPhase("defend")
      return
    end

    if self.map:canBuild(cx, cy) then
      self.map:addTrap(cx, cy)
    end
  end
end

function game:startPhase(phase)
  self.phase = phase
  if phase == "defend" then
    self.waveSpawnComplete = false
    self.waveGen:startWave(self.wave)
  end
end

function game:spawnEnemyAt(spawner)
  table.insert(self.enemies, Enemy(
    self,
    self.map,
    spawner.x,
    spawner.y
  ))
end

function game:waveComplete()
  self.waveSpawnComplete = true
end

function game:update(dt)
  self.map:update(dt)
  self.player:update(dt)

  self.camera:update(dt)
  self.camera:follow(self.player:getX(), self.player:getY())

  self.waveGen:update(dt)

  -- check if the wave is over
  if self.phase == "defend" and self.waveSpawnComplete and #self.enemies == 0 then
    self.wave = self.wave + 1
    self:startPhase("build")
  end

  for i, e in ipairs(self.enemies) do
    if e.dead then
      e:destroy()
      table.remove(self.enemies, i)
    else
      e:update(dt)
    end
  end
end

function game:getMousePosition() 
  local mx, my = love.mouse.getPosition()

  mx = (mx - self.translate[1]) / self.scaling
  my = (my - self.translate[2]) / self.scaling

  local cx, cy = self.camera:toWorldCoords(mx, my)

  return mx, my, cx, cy
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

  -- Draw enemies
  for e=1, #self.enemies, 1 do
    self.enemies[e]:draw()
  end

  self.camera:detach()
  
  love.graphics.pop()

  game:drawUI()

  -- -- Draw borders
  love.graphics.setColor(conf.borderColor[1], conf.borderColor[2], conf.borderColor[3])
  love.graphics.rectangle("fill", 0, 0, game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), game.translate[2])
  love.graphics.rectangle("fill", love.graphics.getWidth() - game.translate[1], 0, game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - game.translate[2], love.graphics.getWidth(), game.translate[2])
end

function game:drawUI() 
  love.graphics.push()
  love.graphics.translate(game.translate[1], game.translate[2])
  love.graphics.scale(game.scaling)
  love.graphics.setColor(1, 1, 1)

  if self.phase == "build" then
    -- Draw the start button
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", self.startButton.x1, self.startButton.y1, self.startButton.x2 - self.startButton.x1, self.startButton.y2 - self.startButton.y1)
  end

  love.graphics.setColor(1, 0, 0)
  love.graphics.printf(self.lives, 10, 10, 100, "left")
  love.graphics.pop()
end
