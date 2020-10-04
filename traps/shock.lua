local Class = require "hump.class"

local Trap = require "traps.trap"
local conf = require "conf"

local ShockTrap = Class{
  init = function(self, world, x, y)
    Trap.init(self, world, x, y)

    self.image = love.graphics.newImage("assets/shock.png")
  end,
  __includes = Trap,
  damage = 5,
  lastTrigger = 0,
  triggerRate = 2, -- How often this trap can trigger
  fps = 20,
  frame = 0,
  timer = 0,
  playing = false,
}

function ShockTrap:trigger(enemies, dt)
  if self.lastTrigger >= love.timer.getTime() - self.triggerRate then
    return
  end

  self.playing = true

  self.lastTrigger = love.timer.getTime()

  for _, enemy in ipairs(enemies) do
    enemy:damage(self.damage)
    enemy:slowdown(conf.slowdownLength)
  end
end


function ShockTrap:update(dt)
  Trap.update(self, dt)

  if self.playing then
    self.timer = self.timer + dt

    if self.timer > 1 / self.fps then
      self.frame = self.frame + 1
      if self.frame > 6 then
        self.frame = 0
        self.playing = false
      end

      self.timer = 0
    end
  end
end

function ShockTrap:draw()
  love.graphics.setColor(1, 1, 1)

  local quad = love.graphics.newQuad(self.frame * 32, 0, 32, 32, self.image:getWidth(), self.image:getHeight())
  love.graphics.draw(self.image, quad, self:getX() - 16, self:getY() - 16)
end

return ShockTrap

