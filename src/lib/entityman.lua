-- From firekatana/lib/entityman.lua, https://dps2004.itch.io/firekatana

local definitions = require "obj.definitions"

local em = {
    deep = deeper.init(),
    entities = {}
}

function em.clear()
    while #em.entities ~= 0 do
        rawset(em.entities, #em.entities, nil)
    end
end

-- Returns a new entity built from its definition in obj/definitions.lua.
-- kind fills in the %s of the sheet, the "s" in "obj/letters/%s".
local function new_entity(name, kind, x, y)
    local definition = definitions[name]
    assert(definition, "no entity named " .. tostring(name) .. " in obj/definitions.lua")

    local entity = {
        name = name,
        layer = definition.layer,
        uplayer = definition.uplayer,
        x = x or definition.x or 0,
        y = y or definition.y or 0,
        angle = definition.angle or 0,
        delete = false,
    }

    if definition.image then
        entity.image = animation.image(definition.image)
        return entity
    end

    local sheet = string.format(definition.sheet, kind)
    local loop = definition.loop and animation.loop[definition.loop]
    local template = animation.newtemplate(sheet, definition.frame_width, definition.frame_seconds, 0, loop)

    entity.anim = animation.newanim(template)
    entity.origin_x, entity.origin_y = definition.origin[1], definition.origin[2]

    return entity
end

function em.init(name, x, y)
    local entity = new_entity(name, nil, x, y)
    table.insert(em.entities, entity)
    return entity
end

function em.init_with_type(name, kind, x, y)
    local entity = new_entity(name, kind, x, y)
    table.insert(em.entities, entity)
    return entity
end

-- Advances the animation of an entity. Static images have nothing to do.
function em.update_entity(entity, dt)
    if entity.anim then
        animation.animupdate(entity.anim, dt)
    end
end

function em.draw_entity(entity)
    if entity.image then
        love.graphics.draw(entity.image, entity.x, entity.y, entity.angle)
        return
    end

    animation.animdraw(entity.anim, entity.x, entity.y, entity.angle, 1, 1, entity.origin_x, entity.origin_y)
end

-- No pause check needed here, lib/gamestate.lua doesn't call the state
-- update() at all while the game is paused
function em.update(dt)
    for i, entity in ipairs(em.entities) do
        em.deep.queue(entity.uplayer, em.update_entity, entity, dt)
    end
    em.deep.execute()
end

function em.draw()
    for i, entity in ipairs(em.entities) do
        em.deep.queue(entity.layer, em.draw_entity, entity)
    end

    em.deep.execute()

    -- Walk backwards, so removing an entity doesn't skip the one after it
    for i = #em.entities, 1, -1 do
        if em.entities[i].delete then
            table.remove(em.entities, i)
        end
    end
end

return em
