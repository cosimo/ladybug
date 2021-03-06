-- Mantis sprite code

local obj = {
    layer = -3,
    uplayer = 3,
    anim = animation.newanim(animation.newtemplate("obj/mantis", 16, 0.125)),
    initialized = false,
    delete = false,
    speed = 1,
    x = 104,
    y = 88,
    angle = -math.pi/2
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
