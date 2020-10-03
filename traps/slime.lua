local Class = require "hump.class"

local Trap = require "traps.trap"

local SlimeTrap = Class{
  init = function(self, world, x, y)
    Trap.init(self, world, x, y)


  end,
  __includes = Trap,
  damage = 5,
}

function SlimeTrap:draw()
  love.graphics.setColor(189 / 255, 163 / 255, 199 / 255)

  love.graphics.rectangle('fill', self.object:getX() - 16, self.object:getY() - 16, 32, 32)
end

return SlimeTrap

