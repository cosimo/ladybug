local ezanim = {}

function ezanim.newtemplate(png,w,s,b,l)
  local t = {}
  t.w = w
  t.s = s
  t.b = b or 0
  if l == nil then
    t.l = true
  else
    t.l = l
  end
  t.img = love.graphics.newImage("assets/" .. png .. ".png")
  t.h = t.img:getHeight()
  t.frames = t.img:getWidth()/(w+t.b)
  t.quads = {}
  local offset = 0
  for i=0,t.frames - 1 do
    
    quad = love.graphics.newQuad(i * t.w + offset, 0 , t.w, t.h, t.img:getWidth(), t.img:getHeight())
    table.insert(t.quads, quad)
    offset = offset + t.b
  end
  t.type = "normal"
  return t
end

function ezanim.newanim(temp)
  local a = {}
  a.temp = temp
  a.f = 1
  a.time = 0
  return a
end

function ezanim.animupdate(a,dt)
  a.time = a.time + dt
  if a.temp.s ~= 0 then
    if a.time >= a.temp.s then
      framesmissed = math.floor(a.time / a.temp.s)
      a.f = a.f + framesmissed
      a.time = a.time - framesmissed * a.temp.s
      
    end
    while a.f >= a.temp.frames + 1 do
      if a.temp.l then
        a.f = a.f - a.temp.frames
      else
        a.f = a.temp.frames
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
  quad = a.temp.quads[a.f]
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
  a.f=1
  a.time=0
end

return ezanim
