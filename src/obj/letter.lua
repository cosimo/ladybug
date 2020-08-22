-- Letter generic sprite code
-- wants to be called as dofile("...")("s") for the letter "s"
-- the extra argument will be available as `...`

local param = ...

local obj = {
    layer = -4,
    uplayer = 4,
    anim = animation.newanim(animation.newtemplate("obj/letters/" .. param, 9, 0)),
    initialized = false,
    delete = false,
    speed = 0,
    x = 32,
    y = 32,
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
