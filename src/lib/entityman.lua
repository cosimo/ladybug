-- From firekatana/lib/entityman.lua, https://dps2004.itch.io/firekatana

local em = {
    deep = deeper.init(),
    entities = {}
}

function em.clear()
    while #em.entities ~= 0 do
        rawset(em.entities, #em.entities, nil)
    end
end

function em.init(en, x, y)
    local path = "obj/" .. en .. ".lua"
    local new = dofile(path)

    if x then
        new.x = x
    end
    if y then
        new.y = y
    end

    new.name = en

    table.insert(em.entities, new)
    return em.entities[#em.entities]
end

function em.init_with_type(en, type_, x, y)
    local path = "obj/" .. en .. ".lua"

    -- https://stackoverflow.com/questions/9744693/how-can-i-pass-parameters
    local new = assert(loadfile(path))(type_)

    if x then
        new.x = x
    end
    if y then
        new.y = y
    end

    new.name = en

    table.insert(em.entities, new)
    return em.entities[#em.entities]
end

function em.update(dt)
    if not paused then
        for i, v in ipairs(em.entities) do
            em.deep.queue(v.uplayer, em.update2, v, dt)
        end
    end
end

function em.draw()
  for i, v in ipairs(em.entities) do
      em.deep.queue(v.layer, v.draw)
  end

  em.deep.execute()

  for i,v in ipairs(em.entities) do
      if v.delete then
          table.remove(em.entities, i)
      end
  end
end

function em.update2(v,dt)
    v.update(dt)
end

return em
