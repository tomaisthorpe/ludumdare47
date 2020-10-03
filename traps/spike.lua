local Class = require "hump.class"

local Trap = require "traps.trap"

local SpikeTrap = Class{
  init = function(self, world, x, y)
    Trap.init(self, world, x, y)
  end,
  __includes = Trap,
  damage = 40,
  lastTrigger = 0,
  triggerRate = 5, -- How often this trap can trigger
}

function SpikeTrap:trigger(enemies, dt)
  if self.lastTrigger >= love.timer.getTime() - self.triggerRate then
    return
  end

  self.lastTrigger = love.timer.getTime()

  for _, enemy in ipairs(enemies) do
    enemy:damage(self.damage)
  end
end

function SpikeTrap:draw()
  love.graphics.setColor(117 / 255, 111 / 255, 103 / 255)

  love.graphics.rectangle('fill', self.object:getX() - 16, self.object:getY() - 16, 32, 32)
end

return SpikeTrap

