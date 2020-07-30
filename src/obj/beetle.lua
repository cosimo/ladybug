-- Beetle sprite code

local obj = {
    layer = -3,
    uplayer = 3,
    anim = animation.newanim(animation.newtemplate("obj/beetle", 16, 0.16)),
    initialized = false,
    delete = false,
    speed = 1,
    x = 160,
    y = 40,
    angle = -math.pi
}

function obj.init()
    obj.initialized = true
end

function obj.update(dt)
    animation.animupdate(obj.anim, dt)
end

function obj.draw()
    animation.animdraw(obj.anim, obj.x, obj.y, obj.angle, 1, 1, 8, 8)
end

return obj
