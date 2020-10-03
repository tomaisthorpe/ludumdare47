local wf = require "windfield"
local Class = require "hump.class"

local data = require "mapdata"

local Map = Class{
  init = function(self)
    self.data = data

    -- Create a canvas so not having to redraw the tiles each frame
    self.canvas = love.graphics.newCanvas(data.width * 16, data.height * 16)

    -- Setup the world for physics
    love.physics.setMeter(32)
    self.world = wf.newWorld(0, 0, true)
    self.world:addCollisionClass('Solid')

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
  end,
  hasCanvas = false
}

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

function Map:updateCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.setColorMask()
  love.graphics.setColor(1, 1, 1)

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

          love.graphics.draw(self.tiles[tile].image, self.tiles[tile].quad, col * 16, row * 16)
        end
      end
      love.graphics.pop()
    end
  end

  height = self.data.height * 16

  love.graphics.setCanvas()

  self.hasCanvas = true
end

function Map:update(dt) 
  if self.hasCanvas == false then
    self:updateCanvas()
  end
end

function Map:draw()
  love.graphics.setColorMask()
  love.graphics.setColor(255, 255, 255)

  love.graphics.draw(self.canvas, 0, 0)

  -- Draw debug 
  self.world:draw()
end

return Map
