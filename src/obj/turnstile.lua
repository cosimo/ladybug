-- Turnstile sprite code

local obj = {
    layer = -2,
    uplayer = 2,
    anim = animation.newanim(animation.newtemplate("obj/turnstile", 32, 0.5, 0, false)),
    initialized = false,
    delete = false,
    speed = 1,
    x = 70,
    y = 60,
    angle = 0
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
