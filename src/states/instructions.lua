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

    local y_start = 69
    local x_start = 52
    local x_step = 16

    st.ladybug = em.init("ladybug", 16, y_start - 5)

    st.extra_row = {
        st.letter("e", x_start, y_start),
        st.letter("x", x_start + x_step, y_start),
        st.letter("t", x_start + 2 * x_step, y_start),
        st.letter("r", x_start + 3 * x_step, y_start),
        st.letter("a", x_start + 4 * x_step, y_start),
    }

    y_start = y_start + 3 * 8

    st.special_row = {
        st.letter("s", x_start, y_start),
        st.letter("p", x_start + x_step, y_start),
        st.letter("e", x_start + 2 * x_step, y_start),
        st.letter("c", x_start + 3 * x_step, y_start),
        st.letter("i", x_start + 4 * x_step, y_start),
        st.letter("a", x_start + 5 * x_step, y_start),
        st.letter("l", x_start + 6 * x_step, y_start),
    }

    y_start = y_start + 3 * 8

    st.hearts_row = {
        st.heart(x_start, y_start),
        st.heart(x_start + 2 * x_step, y_start),
        st.heart(x_start + 4 * x_step, y_start),
        st.skull(x_start + 7.5 * x_step, y_start),
    }

    y_start = y_start + 3 * 8

    st.others = {
        -- The dot has a weird placement: it's smaller than the other sprites
        st.dot(x_start - 4, y_start - 4),
        st.letter("x", x_start, y_start + 24)
    }
end

function st.heart(x_pos, y_pos)
    local heart = em.init("heart", x_pos, y_pos)

    -- All heart bonus icons also start red as the letters
    heart.anim.frame = 2

    return heart
end

function st.dot(x_pos, y_pos)
    return em.init("dot", x_pos, y_pos)
end

function st.skull(x_pos, y_pos)
    return em.init("skull", x_pos, y_pos)
end

function st.letter(l, x_pos, y_pos)
    local letter = em.init_with_type('letter', l, x_pos, y_pos)

    -- All letters start colored red (third anim frame)
    letter.anim.frame = 2

    return letter
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

    love.graphics.setColor(0.66, 0.66, 0.66)
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
