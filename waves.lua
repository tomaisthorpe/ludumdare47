local Class = require "hump.class"

local WaveController = Class{
  init = function (self, game, spawners)
    self.game = game
    self.spawners = spawners
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
  self.totalEnemies = wave * 3
  self.spawnedEnemies = 0

  self.running = true
  self.lastSpawn = 0
end

function WaveController:update(dt)
  if running == false then
    return
  end

  self.lastSpawn = self.lastSpawn + dt

  if self.lastSpawn > self.spawnRate and self.spawnedEnemies < self.totalEnemies then
    self.game:spawnEnemyAt(self.spawners[1])

    self.spawnedEnemies = self.spawnedEnemies + 1

    if self.spawnedEnemies == self.totalEnemies then
      self.game:waveComplete()
    end

    self.lastSpawn = 0
  end
end

return WaveController
