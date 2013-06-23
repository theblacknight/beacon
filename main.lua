-- Animation
require('AnAL')

-- Settings
local debug = false
local debugText = "No collisions yet"
local persisting = 0

-- Player
local JUMPING = 0
local STANDING = 1
local RUNNING = 2
local LANDING = 3
local player = { x = 50, y = 10, speed = 150, 
            velocity = { x = 0, y = 0}, state = STANDING,
            width = 40, height = 48, direction = 1
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
        x = x * tileSize
        y = y * tileSize
        t = collider:addRectangle(x, y, 16, 16)
        t.type = 'tile'
        collider:setPassive(t)
        table.insert(objects, t)
    end
    p = collider:addRectangle(player.x, player.y, player.width, player.height)
    player.bbox = p
end

function on_collision(dt, shape_a, shape_b, mtv_x, mtv_y)
    if mtv_y < 0 and player.velocity.y > 0 then
        player.bbox:move(0, mtv_y)
        player.velocity.y = 0

        if player.state == JUMPING then
            if player.velocity.x ~= 0 then
                player.state = LANDING
            else
                player.state = STANDING
            end
        end
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
    x, y = player.bbox:bbox()
    y = 600 - y
    beaconEffect:send("light_pos", {x + player.width / 2, y - player.height / 2, 0})
end

-- ################ Global Images ################
local smog

-- ################ Love functions ################
function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)
    smog = love.graphics.newImage("assets/smog.png")
    beaconEffect = love.graphics.newPixelEffect("beacon.glsl")

    local playerImg = love.graphics.newImage("assets/player.png")
    player.anim = newAnimation(playerImg, player.width, player.height, 0.1, 27)

    map = tileLoader.load("lvl1.tmx")
    loadWorld()
    updateLight()
end

function love.update(dt)
    updatePlayer(dt)
    handleInput(dt)
    applyGravity(dt)
    collider:update(dt)
    player.bbox:move(player.velocity.x, player.velocity.y)
    updateLight(dt)
end

function love.draw()
    map:draw()
    love.graphics.setPixelEffect(beaconEffect)
    love.graphics.draw(smog, 0, 0)
    love.graphics.setPixelEffect()

    if debug then
        for i=1, #objects do
            x, y = objects[i]:bbox()
            love.graphics.rectangle('fill', x, y, tileSize, tileSize)
        end
        love.graphics.setColor(255, 0, 0)
        x, y, w, h = player.bbox:bbox()
        love.graphics.rectangle('line', x, y,
                                player.width, player.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(debugText, 10, 10)
        love.graphics.setColor(255, 255, 255)
    end
    x, y = player.bbox:bbox()
    offset = 0
    if player.direction == -1 then
        offset = player.width
    end
    player.anim:draw(x, y, 0, player.direction, 1, offset, 0)
end

-- ################ Keyboard Input ################
function handleInput(dt)
    if love.keyboard.isDown("left") then
        player.velocity.x = -5
        player.direction = -1
        if player.state == STANDING or player.state == LANDING then
            player.anim:setSequence(10, 17)
            player.state = RUNNING
        end
    elseif love.keyboard.isDown("right") then
        player.velocity.x = 5
        player.direction = 1
        if player.state == STANDING or player.state == LANDING then
            player.anim:setSequence(10, 17)
            player.state = RUNNING
        end
    end
    
    if player.state ~= JUMPING then
        if not love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
            player.velocity.x = 0
            player.anim:setSequence(1, 3)
            player.state = STANDING
        end
    end
end

function applyGravity(dt)
    player.velocity.y = player.velocity.y + 0.5
    if player.velocity.y > 10 then
        player.velocity.y = 10
    end
end

function love.keypressed( key, unicode )
    if key == "1" then
        debug = not debug
    end

    if love.keyboard.isDown("r") then
        player.bbox:setPosition(player.x, player.y)
    end

    if love.keyboard.isDown(" ") and player.state ~= JUMPING then
        player.velocity.y = -8
        player.anim:setSequence(22, 22)
        player.state = JUMPING
    end
end