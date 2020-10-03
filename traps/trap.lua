local Class = require "hump.class"

local Trap = Class{
  init = function(self, world, x, y)
    self.world = world

    self.object = world:newRectangleCollider(x, y, 32, 32)
    self.object:setCollisionClass('Trap')
    self.object:setType('static')
    self.object:setObject(self)
  end,
  damage = 10,
}

function Trap:getX()
  return self.object:getX()
end

function Trap:getY()
  return self.object:getY()
end

function Trap:trigger(enemies, dt)
  for _, enemy in ipairs(enemies) do
    enemy:damage(self.damage * dt)
  end
end

function Trap:update(dt)
  -- Check if we are colliding with any enemies
  local colliders = self.world:queryRectangleArea(self:getX(), self:getY(), 32, 32, {'Enemy'})
  if #colliders > 0 then
    local enemies = {}
    for _, collider in ipairs(colliders) do
      table.insert(enemies, collider:getObject())
    end

    self:trigger(enemies, dt)
  end
end

function Trap:draw()
  love.graphics.setColor(1, 1, 1)

  love.graphics.rectangle('fill', self.object:getX() - 16, self.object:getY() - 16, 32, 32)
end

return Trap
