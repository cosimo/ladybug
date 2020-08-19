local st = {}

function st.init()
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
    st.waited = 0.0
    st.next_state = states.attractmode

    st.playfield = em.init("playfield")
    st.ladybug = em.init("ladybug", 16, 72)
end

function st.leave()
end

function st.resume()
    st.enter()
end

function st.process_input()
end

function st.update(self, dt)
    lovebird.update()
    self.waited = self.waited + dt
    if self.waited > 20.0 then
        gs.switch(self.next_state)
    end
    self.input:update()
    self.process_input()
    em.update(dt)
end

function st.draw()
    push:start()

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("SPECIAL  EXTRA  ×2×3×5", 8, 9);
    love.graphics.print("1ST      0", 112, 209);

    love.graphics.setColor(1, 0, 0);
    love.graphics.print("TOP  UNIVERSAL  10000", 24, 225);

    love.graphics.setColor(0, 1, 0);
    love.graphics.print("=9500", 24, 233);

    love.graphics.setColor(0, 0.5, 1);
    love.graphics.print("PART91", 72, 233);

    love.graphics.setColor(1, 1, 1);
    love.graphics.print("CREDIT 0", 128, 233);

    love.graphics.print("INSTRUCTION", 56, 41);

    love.graphics.print(" 10 POINTS", 64, 137);
    love.graphics.print("800 POINTS", 64, 161);

    em.draw()
    push:finish()
end

return st
