local st = {}

function st.init()
    st.waited = 0.0
    st.next_state = states.attractmode -- states.demogame

    st.input = baton.new {
        controls = {
            left = {"key:left", "key:a", "axis:leftx-", "button:dpleft"},
            right = {"key:right", "key:d", "axis:leftx+", "button:dpright"},
            up = {"key:up", "key:w", "axis:lefty-", "button:dpup"},
            down = {"key:down", "key:s", "axis:lefty+", "button:dpdown"},
            slash = {"key:c", "button:a"},
            place = {"key:z", "button:b"},
            zoop = {"key:x", "button:x"}
        },
        pairs = {
            move = {"left", "right", "up", "down"}
        },
        joystick = love.joystick.getJoysticks()[1],
    }
end

function st.enter(prev)
    em.clear()
    st.turnstile = em.init("turnstile")
end

function st.leave()
end

function st.resume()
end

function st.process_input()
end

function st.update(self, dt)
    lovebird.update()
    self.waited = self.waited + dt
    if self.waited > 5.0 then
        gs.switch(self.next_state)
    end
    self.input:update()
    self.process_input()
    em.update(dt)
end

function st.draw()
    push:start()

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("INSTRUCTIONS", 56, 204);

    em.draw()
    push:finish()
end

return st
