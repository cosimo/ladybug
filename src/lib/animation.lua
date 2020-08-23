-- From firekatana/lib/ezanim.lua, https://dps2004.itch.io/firekatana

local ezanim = {
    loop = {
        NONE = 0,
        FORWARDS = 1,
        PENDULUM = 3,
    }
}

function ezanim.newtemplate(png, width, speed, border, loop)
  local t = {}

  t.width = width
  t.speed = speed
  t.border = border or 0

  if loop == nil then
    t.loop = ezanim.loop.PENDULUM
  else
    t.loop = loop
  end

  t.img = love.graphics.newImage("assets/" .. png .. ".png")
  t.height = t.img:getHeight()
  t.frames = t.img:getWidth()/(width + t.border)
  t.quads = {}

  local offset = 0
  for i = 0, t.frames - 1 do
    quad = love.graphics.newQuad(i * t.width + offset, 0 , t.width, t.height, t.img:getWidth(), t.img:getHeight())
    table.insert(t.quads, quad)
    offset = offset + t.border
  end

  if t.loop == ezanim.loop.PENDULUM then
      for i = t.frames - 2, 1, -1 do
        quad = love.graphics.newQuad(i * t.width + offset, 0 , t.width, t.height, t.img:getWidth(), t.img:getHeight())
        table.insert(t.quads, quad)
        offset = offset - t.border
        t.frames = t.frames + 1
      end
  end

  t.type = "normal"
  return t
end

function ezanim.newanim(temp)
  local a = {}
  a.temp = temp
  a.frame = 1
  a.time = 0
  return a
end

function ezanim.animupdate(a,dt)
  a.time = a.time + dt
  if a.temp.speed ~= 0 then
    if a.time >= a.temp.speed then
      framesmissed = math.floor(a.time / a.temp.speed)
      a.frame = a.frame + framesmissed
      a.time = a.time - framesmissed * a.temp.speed
      
    end
    while a.frame >= a.temp.frames + 1 do
      if a.temp.loop then
        a.frame = a.frame - a.temp.frames
      else
        a.frame = a.temp.frames
      end
    end 
  else
  end
end

function ezanim.animdraw(a,x,y,r,sx,sy,ox,oy,kx,ky)
  x = x or 0
  y = y or 0
  r = r or 0
  sx = sx or 1
  sy = sy or sx
  ox = ox or 0
  oy = oy or 0
  kx = kx or 0
  ky = ky or 0
  quad = a.temp.quads[a.frame]
  if a.temp.type == "4color" then
    for i=1,4 do
      love.graphics.setColor(colors[i])
      love.graphics.draw(a.temp.img[i],quad,x,y,r,sx,sy,ox,oy,kx,ky)
    end
  else
    love.graphics.draw(a.temp.img,quad,x,y,r,sx,sy,ox,oy,kx,ky)
  end
end

function ezanim.resetanim(a)
  a.frame = 1
  a.time = 0
end

return ezanim
