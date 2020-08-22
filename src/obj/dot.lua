-- Dot static sprite code

local obj = {
    layer = -4,
    uplayer = 4,
    initialized = false,
    delete = false,
    image = love.graphics.newImage("assets/obj/dot.png"),
    x = 0,
    y = 0,
    speed = 0,
    angle = 0
}

function obj.init()
    obj.initialized = true
end

function obj.update(dt)
end

function obj.draw()
    -- Draw the dot centered around the coordinates
    love.graphics.draw(obj.image, obj.x - 1, obj.y - 1, obj.angle)
end

return obj
