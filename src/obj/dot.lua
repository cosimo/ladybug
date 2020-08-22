-- Dot sprite code

local obj = {
    layer = -5,
    uplayer = 5,
    anim = animation.newanim(animation.newtemplate("obj/dot", 3, 0)),
    initialized = false,
    delete = false,
    speed = 0,
    x = 0,
    y = 0,
    angle = 0
}

function obj.init()
    obj.initialized = true
end

function obj.update(dt)
    animation.animupdate(obj.anim, dt)
end

function obj.draw()
    animation.animdraw(obj.anim, obj.x, obj.y, obj.angle, 1, 1, 3, 3)
end

return obj
