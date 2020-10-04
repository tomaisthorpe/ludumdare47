local Class = require 'hump.class'
local Bullet = require 'bullet'

local Player = Class{
  init = function(self, game, world, x, y)
    self.game = game
    self.world = world
  
    -- Create collider
    self.object = world:newRectangleCollider(x - 11, y - 32, 22, 32)
    self.object:setCollisionClass('Player')
    self.object:setFixedRotation(true)
    self.object:setObject(self)
    self.object:setLinearDamping(15)

    self.image = love.graphics.newImage("assets/player.png")
  end,
  speed = 3000,

  fireRate = 0.2,
  lastShot = 0,
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

function Player:shoot()
  -- Check the user can actually shoot
  if self.lastShot >= love.timer.getTime() - self.fireRate then
    return
  end

  self.lastShot = love.timer.getTime()

  local _, _, cx, cy = self.game:getMousePosition()

  local dx = cx - self:getX()
  local dy = cy - self:getY()
  local theta = math.atan2(dy, dx)

  local bullet = Bullet(self.game, self.world, self:getX(), self:getY(), theta)
  self.game:addEntity(bullet)

  self.game:playSound('shoot')
end

function Player:draw()
  love.graphics.setColor(1, 1, 1)

  local direction = -1
  local mx = self.game:getMousePosition()
  if mx > self:getX() then
    direction = 1
  end

  love.graphics.draw(self.image, self.object:getX() + 11 * direction, self.object:getY() - 16, 0, -direction, 1)
end

return Player
