local Class = require 'hump.class'

local Enemy = Class{
  init = function(self, map, x, y)
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
}

function Enemy:getX() 
  return self.object:getX()
end

function Enemy:getY() 
  return self.object:getY()
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
  local goal_x = ((x - 1) * 16) + 8
  local goal_y = ((y - 1) * 16) + 8

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
end

function Enemy:draw()
  love.graphics.setColor(1, 0, 0)

  love.graphics.circle('fill', self.object:getX(), self.object:getY(), 8)

  -- Draw paths
  if self.path then
    line = {}
    for n=1, #self.path, 1 do
      table.insert(line, ((self.path[n]:getX()) - 1) * 16 + 8)
      table.insert(line, ((self.path[n]:getY()) - 1) * 16 + 8)
    end

    love.graphics.line(line)

    local cx = (self.path[self.cur]:getX() - 1) * 16 + 8
    local cy = (self.path[self.cur]:getY() - 1) * 16 + 8
    love.graphics.circle("fill", cx, cy, 4)
  end
end

return Enemy
