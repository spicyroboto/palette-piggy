-- 2D Collision-detection library
local bump = require 'lib.bump'

local mapdata = require 'mapdata'

local world = bump.newWorld(50)

local currentMap = 'red' 
local walls = {}

-- image data
local imageData = { redSquare = nil }

local function drawBox(box, r,g,b)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
  love.graphics.setColor(255, 255, 255)
end
 
local function getCurrentColour(currentMap)
  if currentMap == 'red' then
    return imageData.redSquare
  elseif currentMap == 'blue' then
    return imageData.blueSquare
  elseif currentMap == 'yellow' then
    return imageData.yellowSquare
  elseif currentMap == 'green' then
    return imageData.greenSquare
  end
end

local function renderMap(currentMap)
  for mapx=1,mapdata.getMapWidth(currentMap) do
    for mapy=1,mapdata.getMapHeight(currentMap) do
     local tile = mapdata.getTileAt(currentMap, mapx, mapy)
      if tile == true then
        currentColour = getCurrentColour(currentMap)
        love.graphics.draw(currentColour, mapx * 32, mapy * 32) 
      end
     end
   end
 end
 
 local function addWalls()
  for mapx=1,(mapdata.getMapWidth(currentMap)) do
    for mapy=1,mapdata.getMapHeight(currentMap) do
     local tile = mapdata.getTileAt(currentMap, mapx, mapy)
     if tile == true then 
       local wall = {x= mapx*32, y= mapy*32, w=32, h=32}
       world:add(wall, wall.x, wall.y, wall.w, wall.h)
       table.insert(walls, wall)
    end
   end
 end
end

 
 local function removeMap()
  for i=1, #walls do
    local wall = walls[i]
    world:remove(wall)
  end
  walls = {}
 end
   
   local function nextMap(prevMap)
    if prevMap == 'red' then
     return 'blue'
    elseif prevMap == 'blue' then
      return 'yellow'
    elseif prevMap == 'yellow' then
      return 'green'
    elseif prevMap == 'green' then
      return 'red'
    end
  end  
 
 local function switchMap()
   removeMap()
   currentMap = nextMap(currentMap)
   addWalls()
  end
 
  
-- Player Stuff
local player = {x=50, y=50, w=20, h=20, speed=80}

local function updatePlayer(dt)
  local speed = player.speed
  
  local dx, dy = 0, 0
  if love.keyboard.isDown('right') then
    dx = speed * dt
  elseif love.keyboard.isDown('left') then
    dx = -speed * dt
  end
  if love.keyboard.isDown('down') then
    dy = speed * dt
  elseif love.keyboard.isDown('up') then
    dy = -speed * dt
  end
  
  deltaX, deltaY = world:move(player, player.x + dx, player.y + dy)
  player.x = deltaX
  player.y = deltaY
end

local function drawPlayer()
  drawBox(player, 0,255,0)
end

-- Main LÖVE functions
function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  world:add(player, player.x, player.y, player.w, player.h)
  
  addWalls()
  
  imageData.redSquare = love.graphics.newImage('asset/img/square_red.png')
  imageData.blueSquare = love.graphics.newImage('asset/img/square_blue.png')
  imageData.greenSquare = love.graphics.newImage('asset/img/square_green.png')
  imageData.yellowSquare = love.graphics.newImage('asset/img/square_yellow.png')
end

function love.update(dt)
  updatePlayer(dt)
end

function love.draw()
  love.graphics.setColor(0.1,0.1,0.1)
  renderMap(nextMap(currentMap))
  love.graphics.setColor(1,1,1)
  renderMap(currentMap)   
  drawPlayer()
end

function love.keypressed(key)
  if key == "space" then
    switchMap()
  end
end

  