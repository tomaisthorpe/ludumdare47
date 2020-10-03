local Camera = require("Camera")

local conf = require("conf")
local Map = require("map")
local Player = require("player")
local Enemy = require("enemy")
local WaveGen = require("waves")
local TrapSelector = require("trapselector")

game = {
  translate = {0, 0},
  scaling = 1,
  phase = "build",
  lastSpawn = 0,
  enemies = {},
  entities = {},
  startButton = {
    x1 = 800 - 138,
    y1 = 600 - 58,
    x2 = 800 - 10,
    y2 = 600 - 10,
  },
  wave = 1,
  waveSpawnComplete = false,
  lives = 10,
  money = 1000,
  images = {},
  activeTrap = nil
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

  -- Load assets
  self.images.button = love.graphics.newImage("assets/button.png")
  self.images.money = love.graphics.newImage("assets/money.png")
  self.images.lives = love.graphics.newImage("assets/lives.png")
  self.defaultFont = love.graphics.getFont()
  self.font = love.graphics.newFont("assets/font.otf", 16)
  self.fontLarge = love.graphics.newFont("assets/font.otf", 32)
  self.fontSmall = love.graphics.newFont("assets/veramono.ttf", 8)

  game:calculateScaling()

  self.map = Map(self)

  self.camera = Camera(0, 0, 800, 600)
  self.camera:setFollowStyle('TOPDOWN_TIGHT')
  self.camera:setBounds(0, 0, self.map:getWidth(), self.map:getHeight())

  local playerStart = self.map:getPlayerStartPosition()

  self.player = Player(self, self.map:getWorld(), playerStart.x, playerStart.y)
  self.waveGen = WaveGen(self, self.map.spawners)
  self.trapselector = TrapSelector(self)
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

    local selected = self.trapselector:mousepressed(mx, my)
    -- Returns true if something was clicked on
    if selected then
      return
    end

    if self.map:canBuild(cx, cy) then
      if self.money >= 10 then
        self.money = self.money - self.activeTrap.cost
        self.map:addTrap(cx, cy, self.activeTrap.class)
      end
    end
  else
    self.player:shoot()
  end
end

function game:mousemoved()
  if self.phase == "build" then
    local mx, my = self:getMousePosition()
    self.trapselector:mousemoved(mx, my)
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

function game:addEntity(entity)
  table.insert(self.entities, entity)
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

  for i, e in ipairs(self.entities) do
    if e.dead then
      table.remove(self.entities, i)
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

function game:enemyKilled(reward)
  self.money = self.money + reward
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
    if not self.enemies[e].dead then
      self.enemies[e]:draw()
    end
  end

  for e=1, #self.entities, 1 do
    if not self.entities[e].dead then
      self.entities[e]:draw()
    end
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

  local phaseName = "Wave " .. self.wave

  if self.phase == "build" then
    phaseName = "Build your traps!"

    -- Draw the start button
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.images.button, self.startButton.x1, self.startButton.y1)

    love.graphics.setFont(self.fontLarge)
    love.graphics.printf("Start", self.startButton.x1, self.startButton.y1 + 8, 128, "center")

    self.trapselector:draw()
  end

  love.graphics.setFont(self.fontLarge)
  love.graphics.setColor(conf.phaseNameShadowColor)
  love.graphics.printf(phaseName, 0, 34, 800, "center")

  love.graphics.setColor(conf.phaseNameColor)
  love.graphics.printf(phaseName, 0, 32, 800, "center")

  love.graphics.setFont(self.fontLarge)

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.images.lives, 10, 10)
  love.graphics.setColor(conf.livesShadowColor)
  love.graphics.printf(self.lives, 50, 10, 100, "left")
  love.graphics.setColor(conf.livesColor)
  love.graphics.printf(self.lives, 50, 8, 100, "left")

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.images.money, 800 - 42, 10)
  love.graphics.setColor(conf.moneyShadowColor)
  love.graphics.printf(self.money, 648, 10, 100, "right")
  love.graphics.setColor(conf.moneyColor)
  love.graphics.printf(self.money, 648, 8, 100, "right")
  love.graphics.pop()
end
