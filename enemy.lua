local Class = require 'hump.class'
local conf = require 'conf'

local Enemy = Class{
  init = function(self, game, map, x, y)
    self.game = game
    self.map = map
    self.world = map:getWorld()

    -- Create collider
    self.object = self.world:newCircleCollider(x, y, 8)
    self.object:setCollisionClass('Enemy')
    self.object:setFixedRotation(true)
    self.object:setObject(self)
    self.object:setLinearDamping(1)

    self:calculatePath()

    if self.path then
      self:startMoving()
    end
  end,
  speed = 60000,
  path = nil,
  health = 100,
}

function Enemy:getX()
  return self.object:getX()
end

function Enemy:getY()
  return self.object:getY()
end

function Enemy:damage(health)
  self.health = self.health - health
  if self.health <= 0 then
    self.dead = true
    self.health = 0
    self.game:enemyKilled(20)
  end
end

function Enemy:calculatePath()
  path = self.map:getPathToGoal(self:getX(), self:getY())

  if path then
    self.path = path._nodes
  else
    print('No path :(')
  end
end

function Enemy:startMoving()
  self.isMoving = true
  self.cur = 1 -- Current index of path
  self.there = true -- Whether or not reached current step
end

function Enemy:setTilePosition()
  self.tileX = math.floor(self:getX() / 16)
  self.tileY = math.floor(self:getY() / 16)
end

function Enemy:move(dt)
  if self.isMoving then
    if not self.there then
      -- Walk to the current tile
      self:moveToTile(self.path[self.cur]:getX(), self.path[self.cur]:getY(), dt)
    else
      -- Start moving to the next tile
      if self.path[self.cur + 1] then
        self.cur = self.cur + 1
        self.there = false
        else
          -- Reached the goal
          self.isMoving = false
        end
    end
    -- TODO Can update frame here to only animate when moving
  end
end

function Enemy:moveToTile(x, y, dt)
  local goal_x = x * 16
  local goal_y = y * 16

  local dx = goal_x - self:getX()
  local dy = goal_y - self:getY()
  local theta = math.atan2(dy, dx)

  local vx = math.cos(theta)
  local vy = math.sin(theta)

  self.object:setLinearVelocity(
    dt * self.speed * self.object:getMass() * vx,
    dt * self.speed * self.object:getMass() * vy
  )

  -- Calculate distance to the next point
  local distance = math.sqrt(((goal_x - self:getX()) ^ 2) + ((goal_y - self:getY()) ^ 2))
  if distance < 8 then
    self.there = true
  end

end

function Enemy:destroy()
  self.object:destroy()
end

function Enemy:update(dt)
  self:setTilePosition()
  self:move(dt)

  -- Check if they're near the goal
  local goal = self.map.goal
  local distance = math.sqrt(((goal.x - self:getX()) ^ 2) + ((goal.y - self:getY()) ^ 2))
  if distance < 16 then
    self.game:removeLife()
    self.dead = true
  end

  -- Check if they're colliding with a trap
  colliders = self.world:queryCircleArea(self:getX(), self:getY(), 8, {'Trap'})
  for _, collider in ipairs(colliders) do
    collider:getObject():trigger(self, dt)
  end
end

function Enemy:draw()
  if self.dead then
    return
  end

  love.graphics.setColor(0, 0, 1)

  love.graphics.circle('fill', self.object:getX(), self.object:getY(), 8)

  -- Draw paths
  if conf.drawPaths then
    if self.path then
      line = {}
      for n=1, #self.path, 1 do
        table.insert(line, self.path[n]:getX() * 16)
        table.insert(line, self.path[n]:getY() * 16)
      end

      love.graphics.line(line)

      love.graphics.setColor(1, 1, 0)
      local cx = (self.path[self.cur]:getX()) * 16
      local cy = (self.path[self.cur]:getY()) * 16 
      love.graphics.circle("fill", cx, cy, 4)
    end
  end

  -- Draw health bar
  if self.health < 100 then
    love.graphics.setColor(conf.healthColor)
    local width = (self.health / 100) * 16
    love.graphics.rectangle("fill", self.object:getX() - (width / 2), self.object:getY() - 11, width, 2)
  end
end

return Enemy
