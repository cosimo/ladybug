-- From firekatana/lib/entityman.lua, https://dps2004.itch.io/firekatana

local em = {
    deep = deeper.init(),
    entities = {}
}

function em.init(en,x,y)
    local path = "obj/" .. en .. ".lua"
    local new = dofile(path)
    new.x = x
    new.y = y
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
