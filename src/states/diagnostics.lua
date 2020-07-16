local st = {}

function st.init()
  st.waited = 0.0
  st.next_state = states.attractmode
end

function st.enter(prev)
end

function st.leave()
end

function st.resume()
end

function st.update(self, dt)
  self.waited = st.waited + dt
  if self.waited > 4 then
    gs.switch(self.next_state)
  end
end

function st.draw()
  memory_check()
end

function memory_check()
  push:start()
  love.graphics.setColor(0xfc/255, 0xb2/255, 0xf2/255)
  love.graphics.print("ROM OK", 60, 40)
  love.graphics.print("RAM OK", 60, 64)
  push:finish()
end

return st
