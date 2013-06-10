-- Animation
require('AnAL')

-- Settings
local debug = false
local debugText = "No collisions yet"
local persisting = 0

-- Player
local player = { x = 680, y = 200, speed = 200,
            width = 38.22, height = 61.8
        }

local function updatePlayer (dt)
    player.anim:update(dt)
end

-- ################ Tile Loader ################
local tileLoader = require("AdvTiledLoader.Loader")
tileLoader.path = "maps/"
local map
local tileSize = 16

-- ################ Physics ################
local HC = require 'hardoncollider'
local collider
local objects = {}
function loadWorld()
    collider = HC(100, on_collision, collision_stop)
    local collisionLayer = map.layers["Fore"]
    for x, y, tile in collisionLayer:iterate() do
        x = x * tileSize + (tileSize / 2)
        y = y * tileSize + (tileSize / 2)
        t = collider:addRectangle(x, y, 16, 16)
        collider:setPassive(t)
        table.insert(objects, t)
    end
    p = collider:addRectangle(player.x, player.y, player.width, player.height)
    collider:setPassive(p)
    player.bbox = p
end

function on_collision(dt, shapeA, shapeB, mtvX, mtvY)
    if (shapeA == player.bbox or shapeB == player.bbox) and state == PLAY then
        player.bbox:move(mtvX, mtvY)
    end
end

-- this is called when two shapes stop colliding
function collision_stop(dt, shape_a, shape_b)
end

-- ################ Lighting ################
local ligtPos = { x = player.x, y = player.y }

-- ################ Shaders ################
local beaconEffect

local function updateLight (dt) 
   y = 600 - player.y
   beaconEffect:send("light_pos", {player.x, y, 0})
end

-- ################ Global Images ################
local smog

-- ################ Love functions ################
function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)
    smog = love.graphics.newImage("assets/smog.png")
    beaconEffect = love.graphics.newPixelEffect("beacon.glsl")

    local playerImg = love.graphics.newImage("assets/player.png")
    player.anim = newAnimation(playerImg, player.width, player.height, 0.03, 30)

    map = tileLoader.load("lvl1.tmx")
    loadWorld()
    updateLight()
end

function love.update(dt)
    handleInput(dt)
    collider:update(dt)
    updateLight(dt)
    updatePlayer(dt)

    if debug and string.len(debugText) > 1024 then
        debugText = string.sub(debugText, 100)
    end
end

function love.draw()
    map:draw()
    love.graphics.setPixelEffect(beaconEffect)
    --love.graphics.draw(smog, 0, 0)
    love.graphics.setPixelEffect()

    if debug then
        for i=1, #objects do
            x, y = objects[i]:bbox()
            love.graphics.rectangle('fill', x - tileSize/2, y - tileSize/2, tileSize, tileSize)
        end
        love.graphics.setColor(255, 0, 0)
        x, y = player.bbox:bbox()
        love.graphics.rectangle('line', x - player.width/2, y - player.height/2,
                                player.width, player.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(debugText, 10, 10)
        love.graphics.setColor(255, 255, 255)
    end
    x, y = player.bbox:bbox()
    player.anim:draw(100, 100)
end

-- ################ Keyboard Input ################
function handleInput(dt)
    if state == PLAY then
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            player.x = player.x + (dt * player.speed)
            player.anim:setSequence(1, 30)
        elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            player.x = player.x + dt * -player.speed
            player.anim:setSequence(1, 30)
        else
            player.anim:setSequence(3, 3)
        end
        player.bbox:move(player.x, player.y)
    end
end

function love.keypressed( key, unicode )
    if key == "1" then
        debug = not debug
    end

    if love.keyboard.isDown("r") then
        player.body:setPosition(player.x, player.y)
    end

    if love.keyboard.isDown(" ") then
        player.body:setLinearVelocity(0, -500)
    end
end