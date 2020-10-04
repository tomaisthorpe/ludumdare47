local Class = require "hump.class"

local Trap = require "traps.trap"

local BoxTrap = Class{
  init = function(self, world, x, y)
    Trap.init(self, world, x, y)

    self.image = love.graphics.newImage("assets/box.png")

    self.object:setCollisionClass('BoxTrap')
  end,
  __includes = Trap,
  damage = 0,
  frame = 0,
  timer = 0,
  health = 100,
  dead = false,
  isBox = true,
}

function BoxTrap:update(dt)
  local colliders = self.world:queryRectangleArea(self.object:getX() - 18, self.object:getY() - 18, 36, 36, {'Enemy'})
  if #colliders > 0 then

    self.health = self.health - (15 * #colliders * dt)
    if self.health < 0 then
      self.health = 0
      self.dead = true
    end
  end
end

function BoxTrap:draw()
  love.graphics.setColor(1, 1, 1)

  love.graphics.draw(self.image, self:getX() - 16, self:getY() - 16)

  -- Draw health bar
  if self.health < 100 then
    love.graphics.setColor(conf.healthColor)
    local width = (self.health / 100) * 16
    love.graphics.rectangle("fill", self.object:getX() - (width / 2), self.object:getY() - 11, width, 2)
  end
end

return BoxTrap

