local st = {}

function st.init()
  st.waited = 0
end

function st.enter(prev)
end

function st.leave()
end

function st.resume()
end

function st.update(dt)
  st.waited = st.waited + 1
end

function st.draw()
  push:start()
  love.graphics.setColor(0xfc/255, 0xb2/255, 0xf2/255)
  love.graphics.print("ATTRACT", 60, 40)
  push:finish()
end

return st
