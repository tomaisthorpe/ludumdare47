local Class = require "hump.class"

local Trap = require "traps.trap"

local AcidTrap = Class{
  init = function(self, world, x, y)
    Trap.init(self, world, x, y)

    self.image = love.graphics.newImage("assets/acid.png")
  end,
  __includes = Trap,
  damage = 5,
  fps = 10,
  frame = 0,
  timer = 0,
}

function AcidTrap:update(dt)
  Trap.update(self, dt)

  self.timer = self.timer + dt
  
  if self.timer > 1 / self.fps then
    self.frame = self.frame + 1
    if self.frame > 31 then self.frame = 0 end

    self.timer = 0
  end
end

function AcidTrap:draw()
  love.graphics.setColor(1, 1, 1)

  local quad = love.graphics.newQuad(self.frame * 32, 0, 32, 32, self.image:getWidth(), self.image:getHeight())
  love.graphics.draw(self.image, quad, self:getX() - 16, self:getY() - 16)
end

return AcidTrap

