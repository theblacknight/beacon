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
local world
local objects = {}
function loadWorld()
    world = love.physics.newWorld(0, 9.81*64, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    love.physics.setMeter(64)
    local collisionLayer = map.layers["Fore"]
    for x, y, tile in collisionLayer:iterate() do
        x = x * tileSize + (tileSize / 2)
        y = y * tileSize + (tileSize / 2)
        body = love.physics.newBody(world, x, y, "static")
        shape = love.physics.newRectangleShape(tileSize, tileSize)
        fixture = love.physics.newFixture(body, shape, 2)
        fixture:setUserData("Tile: X="..x..", Y="..y)
        tileObject = { body = body, shape = shape}
        table.insert(objects, tileObject)
    end
    player.body = love.physics.newBody(world, player.x, player.y, "dynamic")
    player.shape = love.physics.newRectangleShape(player.width, player.height)
    fixture = love.physics.newFixture(player.body, player.shape, 2)
    fixture:setUserData("Player")
end

function beginContact(a, b, coll)
    x,y = coll:getNormal()
    debugText = debugText.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y
end


function endContact(a, b, coll)
    persisting = 0    -- reset since they're no longer touching
    debugText = debugText.."\n"..a:getUserData().." uncolliding with "..b:getUserData()
end

function preSolve(a, b, coll)
    if persisting == 0 then    -- only say when they first start touching
        debugText = debugText.."\n"..a:getUserData().." touching "..b:getUserData()
    elseif persisting < 20 then    -- then just start counting
        debugText = debugText.." "..persisting
    end
    persisting = persisting + 1    -- keep track of how many updates they've been touching for
end

function postSolve(a, b, coll)
-- we won't do anything with this function
end

-- ################ Lighting ################
local ligtPos = { x = player.x, y = player.y }

-- ################ Shaders ################
local beaconEffect

local function updateLight (dt) 
   y = 600 - player.body:getY()
   beaconEffect:send("light_pos", {player.body:getX(), y, 0})
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
    world:update(dt)
    updateLight(dt)
    updatePlayer(dt)

    if debug and string.len(debugText) > 1024 then
        debugText = string.sub(debugText, 100)
    end
end

function love.draw()
    map:draw()
    x, y = player.body:getWorldPoints(player.shape:getPoints())
    player.anim:draw(x, y)
    love.graphics.setPixelEffect(beaconEffect)
    --love.graphics.draw(smog, 0, 0)
    love.graphics.setPixelEffect()

    if debug then
        for i=1, #objects do
            x, y = objects[i].body:getWorldPoints(objects[i].shape:getPoints())
            love.graphics.rectangle('fill', x, y, tileSize, tileSize)
        end
        love.graphics.setColor(255, 0, 0)
        x, y = player.body:getWorldPoints(player.shape:getPoints())
        love.graphics.rectangle('line', x, y,
                                player.width, player.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(debugText, 10, 10)
        love.graphics.setColor(255, 255, 255)
    end
end

-- ################ Keyboard Input ################
function handleInput(dt)
    if state == PLAY then
        xSpeed, ySpeed = player.body:getLinearVelocity()
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            player.body:setLinearVelocity(player.speed, 0)
            player.anim:setSequence(1, 30)
        elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            player.body:setLinearVelocity(-player.speed, 0)
            player.anim:setSequence(1, 30)
        else
            player.body:setLinearVelocity(0, ySpeed)
            player.anim:setSequence(3, 3)
        end

    end
end

function love.keypressed( key, unicode )
    if key == "1" then
        debug = not debug
    end

    if love.keyboard.isDown("r") then
        player.body:setPosition(player.x, player.y)
    end
end