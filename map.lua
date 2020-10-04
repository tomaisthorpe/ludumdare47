local wf = require "windfield"
local Class = require "hump.class"
local JGrid = require "jumper.grid"
local JPathfinder = require "jumper.pathfinder"

local Goal = require "goal"
local data = require "mapdata"

local Map = Class{
  init = function(self, game)
    self.data = data
    self.game = game

    -- Create a canvas so not having to redraw the tiles each frame
    self.width = data.width * 16
    self.height = data.height * 16
    self.canvas = love.graphics.newCanvas(width, height)

    -- Setup the world for physics
    love.physics.setMeter(32)
    self.world = wf.newWorld(0, 0, true)
    self.world:addCollisionClass('Solid')
    self.world:addCollisionClass('Trap')
    self.world:addCollisionClass('Bullet', {ignores={'Trap'}})
    self.world:addCollisionClass('Player', {ignores={'Trap', 'Bullet'}})
    self.world:addCollisionClass('Enemy', {ignores={'Trap', 'Enemy'}})

    -- self.world:setQueryDebugDrawing(true)

    -- Load the tiles
    self.tiles = {}

    for t=1, #data.tilesets, 1 do
      -- Load the image
      local image = love.graphics.newImage(data.tilesets[t].image)
      local firstID = data.tilesets[t].firstgid
      local count = data.tilesets[t].tilecount
      local columns = data.tilesets[t].columns

      for s=1, count, 1 do
        local col = (s - 1) % columns
        local row = math.floor((s - 1) / columns)

        table.insert(self.tiles, {
          image = image,
          quad = love.graphics.newQuad(16 * col, 16 * row, 16, 32, image.getDimensions(image)),
        })
      end

      table.insert(self.tiles, tileset)
    end

    self.colliders = {}
    self:updateColliders()
    self:updateObjects()

    self:updateCanvas()
  end,
  hasCanvas = false,
  playerStartPosition = {x = 0, y = 0},
  cursor = nil,
  traps = {}, 
  spawners = {},
  goal = {},
}

function Map:getWidth() 
  return self.width
end

function Map:getHeight() 
  return self.height
end

function Map:getWorld() 
  return self.world
end

function Map:getPlayerStartPosition() 
  return self.playerStartPosition
end

function Map:updateColliders()
  -- Destory existing coliders
  for c=1, #self.colliders, 1 do
    self.colliders[c]:destroy()
  end

  self.colliders = {}
  for l=1, #self.data.layers, 1 do
    local layer = self.data.layers[l]
    if layer.properties.isCollision then
      -- Each option refers to a collider
      for o=1, #layer.objects, 1 do
        local object = layer.objects[o]
        if object.shape == "rectangle" then
          local collider = self.world:newRectangleCollider(object.x, object.y, object.width, object.height)
          collider:setCollisionClass('Solid')

          collider:setType('static')
          table.insert(self.colliders, collider)
        end
      end
    end
  end
end

function Map:updateObjects()
  for l = 1, #self.data.layers, 1 do
    local layer = self.data.layers[l]
    if layer.type == "objectgroup" then
      for o=1, #layer.objects, 1 do
        local object = layer.objects[o]
        if object.type == "playerStart" then
          self.playerStartPosition = {
            x = object.x,
            y = object.y,
          }
        end

        if object.type == "spawner" then
          table.insert(self.spawners, {
            x = object.x,
            y = object.y,
          })
        end

        if object.type == "goal" then
          self.goal = Goal(object.x, object.y)
        end
      end
    end
  end
end

function Map:updateCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.setColorMask()
  love.graphics.setColor(1, 1, 1)

  self.grid = {}
  for l=1, #self.data.layers, 1 do
    local layer = self.data.layers[l]

    if layer.type == "tilelayer" then
      local x, y, width = layer.x, layer.y, layer.width

      love.graphics.push()
      love.graphics.translate(x, y)

      for t=1, #layer.data, 1 do
        local tile = layer.data[t]
        if tile > 0 then

          local col = (t - 1) % width 
          local row = math.floor((t - 1) / layer.width)

          if tile == 1 then
            table.insert(self.grid, 0)
          else 
            table.insert(self.grid, 1)
          end

          love.graphics.draw(self.tiles[tile].image, self.tiles[tile].quad, col * 16, row * 16)
        end
      end
      love.graphics.pop()
    end
  end

  height = self.data.height * 16

  love.graphics.setCanvas()

  self.hasCanvas = true

  local grid = JGrid(self:getCollisionGrid())
  self.finder = JPathfinder(grid, 'ASTAR', 0)
  self.finder:annotateGrid()
  self.finder:setHeuristic(function (a, b)
    return self:heuristic(a, b)
  end)
end

function Map:heuristic(nodeA, nodeB)
  local dx = math.abs(nodeA._x - nodeB._x)
  local dy = math.abs(nodeA._y - nodeB._y)

  local weight = 1
  -- Is there a trap here?
  colliders = self.world:queryRectangleArea(nodeA._x * 16, nodeA._y * 16, 32, 32, {'Trap'})
  if #colliders > 0 then
    weight = 100
  end

  weight = weight * ((math.random() + 1 / 2))

  return (dx + dy) * weight
end

function Map:canBuild(mx, my)
    local x = math.floor(mx / 16)
    local y = math.floor(my / 16)

    -- Check this is a valid space
    if self:isFloor(x, y) and self:isFloor(x + 1, y) and self:isFloor(x, y + 1) and self:isFloor(x + 1, y + 1) then
      -- Check there's no trap here already
      local colliders = self.world:queryRectangleArea(x * 16 + 1, y * 16 + 1, 30, 30, {'Trap'})
      if #colliders == 0 then

        -- Check there isn't a trap exactly at this point
        -- The above doesn't work for some reason
        for _, trap in ipairs(self.traps) do
          if trap:getX() - 16 == x * 16 and trap:getY() - 16 == y * 16 then
            return false
          end
        end
        return true
      end

      return false
    end

    return false
end

function Map:addTrap(mx, my, trap)
  local x = math.floor(mx / 16)
  local y = math.floor(my / 16)

  table.insert(self.traps, trap(self.world, x * 16, y * 16))
end

function Map:isFloor(x, y)
  return self.grid[y * (self.width / 16) + (x + 1)] == 0
end

function Map:getCollisionGrid()
  local grid = {}
  for r = 1, self.height / 16, 1 do
    local row = {}
    for c = 1, self.width / 16, 1 do
      table.insert(row, self.grid[(r - 1) * (self.width / 16) + (c)])
    end

    if #row > 0 then
      table.insert(grid, row)
    end
  end

  return grid
end

function Map:getPathToGoal(x, y)
  -- Convert to grid space
  local sx = math.floor(x / 16)
  local sy = math.floor(y / 16)

  local gx = math.floor(self.goal.x / 16)
  local gy = math.floor(self.goal.y / 16)

  local path = self.finder:getPath(sx, sy, gx, gy, 2)
  return path
end

function Map:update(dt) 
  if self.hasCanvas == false then
    self:updateCanvas()
  end

  self.world:update(dt)

  -- If game is in build phase, then display the cursor on the map
  if self.game.phase == "build" then
    -- Figure out which cell the mouse is on
    local _, _ , cx, cy = self.game:getMousePosition()
    local x = math.floor(cx / 16)
    local y = math.floor(cy / 16)

    -- Check this is a valid space
    if self:isFloor(x, y) and self:isFloor(x + 1, y) and self:isFloor(x, y + 1) and self:isFloor(x + 1, y + 1) then
      self.cursor = {x = x, y = y}
    else
      self.cursor = nil
    end
  else
    self.cursor = nil
  end

  for _, trap in ipairs(self.traps) do
    trap:update(dt)
  end

  self.goal:update(dt)
end

function Map:draw()
  love.graphics.setColorMask()
  love.graphics.setColor(255, 255, 255)

  love.graphics.draw(self.canvas, 0, 0)

  -- Draw all the traps
  for t=1, #self.traps, 1 do
    self.traps[t]:draw()
  end

  self.goal:draw()
  
  -- Draw the cursor if applicable
  if self.cursor ~= nil then
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", self.cursor.x * 16, self.cursor.y * 16, 32, 32)
  end

  -- Draw debug 
  -- self.world:draw()

  -- Draw clearance
  -- love.graphics.setFont(self.game.defaultFont)
  -- local grid = self:getCollisionGrid()
  -- for r=1, #grid, 1 do
  --   for c=1, #grid[r], 1 do
  --     local node = self.finder:getGrid():getNodeAt(c, r)
  --     love.graphics.setColor(255, 255, 255)
  --     love.graphics.printf(node:getClearance(0), (c - 1) * 16, (r - 1) * 16, 16, "center", 0, 0.5, 0.5)
  --   end
  -- end
end

return Map
