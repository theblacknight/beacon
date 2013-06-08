-- Lighting
local ligtPos = { x = 400, y = 300 }

-- Shaders
local beaconEffect

local function updateLight ()
   local x, y = love.mouse.getPosition()
   y = 600 - y
   z = 0
   beaconEffect:send("light_pos", {x, y, z})
end

-- Global Images
local smog

function love.load()
    smog = love.graphics.newImage("assets/smog.png")
    bg = love.graphics.newImage("assets/lovely_bg.bmp")
    beaconEffect = love.graphics.newPixelEffect("beacon.glsl")
    updateLight()
end

function love.update()
    updateLight()
end

function love.draw()
    love.graphics.draw(bg, 0, 0)
    love.graphics.setPixelEffect(beaconEffect)
    love.graphics.draw(smog, 0, 0)
    love.graphics.setPixelEffect()
end

