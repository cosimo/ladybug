-- Playfield sprite code

local obj = {
    layer = -9,
    uplayer = 9,
    image = animation.image("obj/playfield-level1"),
    initialized = false,
    delete = false,
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
    love.graphics.draw(obj.image, obj.x, obj.y, obj.angle)
end

return obj
