-- Animation
require('AnAL')

-- Player
local playerAnim
local playerBody
local playerX = 500
local playerY = 500

local function updatePlayer (dt)
    playerAnim:update(dt)
end

-- ################ Tile Loader ################
local tileLoader = require("AdvTiledLoader.Loader")
tileLoader.path = "maps/"
local map

-- ################ Physics ################
local world
local objects = {}
function loadWorld()
    world = love.physics.newWorld(0, 9.81*64, true)
    love.physics.setMeter(64)
    local collisionLayer = map.layers["Fore"]
    for x, y, tile in collisionLayer:iterate() do
        x = x * 16
        y = y * 16
        body = love.physics.newBody(world, x, y, "static")
        shape = love.physics.newRectangleShape(16, 16)
        love.physics.newFixture(body, shape, 2)
        table.insert(objects, body)
    end
    body = love.physics.newBody(world, playerX, y, "dynamic")
    shape = love.physics.newRectangleShape(0, 0, 38, 61)
    love.physics.newFixture(body, shape, 2)
    playerBody = body
end

-- ################ Lighting ################
local ligtPos = { x = playerX, y = playerY }

-- ################ Shaders ################
local beaconEffect

local function updateLight (dt) 
   y = 600 - playerBody:getY()
   beaconEffect:send("light_pos", {playerBody:getX(), y, 0})
end

-- ################ Global Images ################
local smog

-- ################ Love functions ################
function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)
    smog = love.graphics.newImage("assets/smog.png")
    beaconEffect = love.graphics.newPixelEffect("beacon.glsl")

    player = love.graphics.newImage("assets/player.png")
    playerAnim = newAnimation(player, 38.33, 61.8, 0.03, 30)

    map = tileLoader.load("lvl1.tmx")
    loadWorld()
    updateLight()
end

function love.update(dt)
    handleInput(dt)
    world:update(dt)
    updateLight(dt)
    updatePlayer(dt)
end

function love.draw()
    map:draw()
    playerAnim:draw(playerBody:getX(), playerBody:getY())
    love.graphics.setPixelEffect(beaconEffect)
    love.graphics.draw(smog, 0, 0)
    love.graphics.setPixelEffect()

    for i=1, table.getn(objects) do
        love.graphics.rectangle('fill', objects[i]:getX(), objects[i]:getY(), 16, 16)
    end
end

-- ################ Keyboard Input ################
function handleInput(dt)
    if state == PLAY then
        if love.keyboard.isDown("right") then
            playerBody:applyForce(400, 0)
            playerAnim:setSequence(1, 30)
        elseif love.keyboard.isDown("left") then
            playerBody:applyForce(-400, 0)
            playerAnim:setSequence(1, 30)
        elseif love.keyboard.isDown(" ") then
            
        else
            playerAnim:setSequence(3, 3)
        end
    end
end