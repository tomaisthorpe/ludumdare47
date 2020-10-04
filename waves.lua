local Class = require "hump.class"

local WaveController = Class{
  init = function (self, game, spawners)
    self.game = game
    self.spawners = spawners

    self.standard = {
      modifier = 1,
      speed = 1,
      colorMask = {1, 1, 1},
    }

    self.speedy = {
      modifier = 0.5,
      speed = 1.25,
      colorMask = {0, 1, 0},
    }

    self.big = {
      modifier = 1.5,
      speed = 0.5,
      colorMask = {0, 0, 1},
    }

  end,
  wave = 0,
  spawnedEnemies = 0,
  totalEnemies = 0,
  lastSpawn = 0,
  spawnRate = 2,
  running = false,
}

function WaveController:startWave(wave) 
  self.wave = wave
  self.totalEnemies = wave * 10
  self.spawnedEnemies = 0

  self.enemies = {}
  for i=1, self.totalEnemies, 1 do
    local num = math.random(0, wave * 10)

    if num <= 15 or (num > 20 and num < 30) then
      table.insert(self.enemies, self.standard)
    end

    if num >= 16 and num <= 20 then
      table.insert(self.enemies, self.speedy)
    end

    if num >= 30 then
      table.insert(self.enemies, self.big)
    end
  end

  self.spawnRate = math.max(0.5, 2 - ((self.wave - 1) * 0.25))

  self.running = true
  self.lastSpawn = 0
  self:calculatePaths()
end

function WaveController:getPath(s)
  local spawner = self.spawners[s]
  return self.paths[s][math.random(#self.paths[s])]
end

function WaveController:calculatePaths()
  self.paths = {}

  for s, spawner in ipairs(self.spawners) do
    local paths = {}
    for i=1, 10, 1 do 

      local x = spawner.x + spawner.width / 2
      local y = spawner.y + spawner.height / 2

      local path = self.game.map:getPathToGoal(x, y, 2)
      table.insert(paths, path._nodes)
    end

    self.paths[s] = paths
  end
end

function WaveController:update(dt)
  if running == false then
    return
  end

  self.lastSpawn = self.lastSpawn + dt

  if self.lastSpawn > self.spawnRate and self.spawnedEnemies < self.totalEnemies then
    local enemy = table.remove(self.enemies)

    local spawner = math.random(1, math.min(self.wave, #self.spawners))

    local path = self:getPath(spawner)

    self.game:spawnEnemyAt(self.spawners[spawner], enemy.modifier, enemy.speed, enemy.colorMask, path)

    self.spawnedEnemies = self.spawnedEnemies + 1

    if self.spawnedEnemies == self.totalEnemies then
      self.game:waveComplete()
    end

    self.lastSpawn = 0
  end
end

return WaveController
