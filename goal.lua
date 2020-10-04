local Class = require 'hump.class'

local Goal = Class{
  init = function(self, x, y)
    self.timer = 0
    self.frame = 0
    self.x = x
    self.y = y

    self.image = love.graphics.newImage("assets/portal.png")
  end,
  fps = 10,
}

function Goal:update(dt)
  self.timer = self.timer + dt
  
  if self.timer > 1 / self.fps then
    self.frame = self.frame + 1
    if self.frame > 3 then self.frame = 0 end

    self.timer = 0
  end
end

function Goal:draw()
  love.graphics.setColor(1, 1, 1)

  local quad = love.graphics.newQuad(self.frame * 32, 0, 32, 32, self.image:getWidth(), self.image:getHeight())
  love.graphics.draw(self.image, quad, self.x - 16, self.y - 16)


end

return Goal
