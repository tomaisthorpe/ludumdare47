local Class = require 'hump.class'

local Player = Class{
  init = function(self, world, x, y)
    self.world = world
  
    -- Create collider
    self.object = world:newRectangleCollider(x - 16, y - 32, 32, 32)
    self.object:setCollisionClass('Player')
    self.object:setFixedRotation(true)
    self.object:setObject(self)
    self.object:setLinearDamping(15)
  end,
  speed = 3000,
}

function Player:getX() 
  return self.object:getX()
end

function Player:getY() 
  return self.object:getY()
end

function Player:update(dt)
  if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
    self.object:applyForce(-self.speed * self.object:getMass(), 0)
  end

  if love.keyboard.isDown('right') or love.keyboard.isDown('d')  then
    self.object:applyForce(self.speed * self.object:getMass(), 0)
  end

  if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
    self.object:applyForce(0, -self.speed * self.object:getMass())
  end

  if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
    self.object:applyForce(0, self.speed * self.object:getMass())
  end
end

function Player:draw()
  love.graphics.setColor(1, 1, 0)

  love.graphics.rectangle('fill', self.object:getX() - 16, self.object:getY() - 16, 32, 32)
end

return Player
