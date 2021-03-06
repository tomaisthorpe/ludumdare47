local Class = require 'hump.class'

local Bullet =  Class{
  init = function(self, game, world, x, y, theta)
    self.game = game
    self.object = world:newCircleCollider(x, y, 2)
    self.object:setLinearVelocity(math.cos(theta) * 500, math.sin(theta) * 500)
    self.object:setAngle(theta)
    self.object:setBullet(true)

    self.targetClass = 'Enemy'
    self.object:setCollisionClass('Bullet')
  end,
  dead = false,
  damage = 10
}

function Bullet:update(dt)
  if self.object:enter('Solid') then
    self:destroy()
  end

  if self.object:enter('BoxTrap') then
    self:destroy()
  end

  if self.object:enter(self.targetClass) then
    local collision = self.object:getEnterCollisionData(self.targetClass)
    local object = collision.collider:getObject()

    if object then
      object:damage(self.damage)
    end

    self.game:playSound('hit')

    self:destroy()
  end
end

function Bullet:destroy()
  self.object:destroy()
  self.dead = true
end

function Bullet:draw()
  love.graphics.setColor(1, 142 / 255, 0)
  love.graphics.circle('fill', self.object:getX(), self.object:getY(), 1)
end

return Bullet
