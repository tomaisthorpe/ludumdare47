local Class = require "hump.class"

local Trap = Class{
  init = function(self, world, x, y)
    self.world = world

    self.object = world:newRectangleCollider(x, y, 32, 32)
    self.object:setCollisionClass('Trap')
    self.object:setType('static')
    self.object:setObject(self)
  end,
  damage = 75,
}

function Trap:trigger(enemy, dt)
  enemy:damage(self.damage * dt)
end

function Trap:draw()
  love.graphics.setColor(189 / 255, 163 / 255, 199 / 255)

  love.graphics.rectangle('fill', self.object:getX() - 16, self.object:getY() - 16, 32, 32)
end

return Trap
