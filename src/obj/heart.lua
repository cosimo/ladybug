-- Heart sprite code

local obj = {
    layer = -4,
    uplayer = 4,
    anim = animation.newanim(animation.newtemplate("obj/heart", 9, 0)),
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
    animation.animdraw(obj.anim, obj.x, obj.y, obj.angle, 1, 1, 9, 9)
end

return obj
