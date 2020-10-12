-- Cucumber fruit

local obj = {
    layer = -4,
    uplayer = 4,
    initialized = false,
    delete = false,
    image = love.graphics.newImage("assets/obj/cucumber.png"),
    x = 8,
    y = 8,
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
