local Class = require 'hump.class'

local Trap = require 'trap'

local TrapSelector = Class{
  init = function(self, game)
    self.game = game

    self:selectTrap(1)
  end,
  traps = {
    {
      name = 'Slime?',
      class = Trap,
      cost = 20,
      description = 'Damages enemies as long as they are stood on it',
    },
    {
      name = 'Slime!',
      class = Trap,
      cost = 30,
      description = 'Damages enemies',
    },
  },
  currentTrap = 1,
  tooltip = nil,
}

function TrapSelector:mousemoved(mx, my)
  for i = 1, #self.traps, 1 do
    local x1 = 10 + (58 * (i - 1))
    local y1 = 600 - 74
    local x2 = x1 + 48
    local y2 = y1 + 64

    if mx >= x1 and mx <= x2 and my >= y1 and my <= y2 then
      self.tooltip = {
        x = x1,
        y = y1 - 18,
        text = self.traps[i].description,
      }
      return
    end
  end

  self.tooltip = nil
end

function TrapSelector:mousepressed(mx, my)
  for i = 1, #self.traps, 1 do
    local x1 = 10 + (58 * (i - 1))
    local y1 = 600 - 74
    local x2 = x1 + 48
    local y2 = y1 + 64

    if mx >= x1 and mx <= x2 and my >= y1 and my <= y2 then
      self:selectTrap(i)
      return true
    end
  end
  return false
end

function TrapSelector:selectTrap(index)
  if index > #self.traps or index <= 0 then
    return
  end

  self.currentTrap = index
  self.game.activeTrap = self.traps[index]
end

function TrapSelector:draw()
  love.graphics.push()
  love.graphics.translate(10, 600 - 74)
  
  for i, trap in ipairs(self.traps) do
    love.graphics.push()
    love.graphics.translate((i - 1) * 58, 0)

    local opacity = 0.8
    if i == self.currentTrap then
      opacity = 1
    end

    love.graphics.setColor(1, 1, 1, opacity)
    love.graphics.rectangle("fill", 0, 0, 48, 72, 4, 4)

    if i == self.currentTrap then
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.rectangle("line", 0, 0, 48, 72, 4, 4)
    end

    love.graphics.setColor(0.6, 0.6, 0.6, opacity)
    love.graphics.rectangle("fill", 8, 4, 32, 32, 2, 2)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(self.game.fontSmall)
    love.graphics.printf(trap.name, 4, 42, 38, "left")

    love.graphics.push()
    love.graphics.setColor(1, 1, 1)
    love.graphics.scale(0.35, 0.35)
    love.graphics.draw(self.game.images.money, 10, 154)
    love.graphics.pop()

    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.printf(trap.cost, 16, 55, 38, "left")

    love.graphics.pop()
  end

  love.graphics.pop()

  if self.tooltip then
    love.graphics.setColor(0.5, 0.5, 0.5)

    local width = self.game.fontSmall:getWidth(self.tooltip.text)
    love.graphics.rectangle("fill", self.tooltip.x, self.tooltip.y, width + 10, 16, 4, 4)

    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("line", self.tooltip.x, self.tooltip.y, width + 10, 16, 4, 4)

    love.graphics.setFont(self.game.fontSmall)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.tooltip.text, self.tooltip.x + 5, self.tooltip.y + 3)
  end
end

return TrapSelector
