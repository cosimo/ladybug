local st = {}

function st.init()
    st.input = baton.new {
        controls = {
            coin = {"key:5"},
            start = {"key:1", "key:2"},
        },
        -- TODO make some use of the joysticks
        joystick = love.joystick.getJoysticks()[1],
    }
end

function st.wipe(entity)
    return function()
        entity.delete = true;
    end
end

function st.enter(prev)
    em.clear()

    st.waited = 0.0
    st.next_state = states.attractmode

    st.playfield = em.init("playfield")

    local y_start = 69
    local x_start = 52
    local x_step = 16

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
        st.dot(x_start - 2, y_start - 2),
        st.letter("x", x_start, y_start + 24)
    }
    st.insect = em.init("insect", 21, 237)

    y_start = 69
    x_start = 52
    x_step = 16

    st.ladybug = em.init("ladybug", 16, y_start - 5)
    st.ladybug.path = pathfinder.new_path(st.ladybug, {
        {2, "🛑"},
        {nil, "→", 1, {x_start - 4},
             function()
                 st.extra_row[1].delete = true
                 st.extra_lit["E"] = true
             end
        },
        {3.5, "🛑"},
        {nil, "→", 1, {x_start + x_step - 4},
            function()
                st.extra_row[2].delete = true
                st.extra_lit["X"] = true
            end
        },
        {5, "🛑"},
        {nil, "→", 1, {x_start + 2 * x_step - 4},
            function()
                st.extra_row[3].delete = true
                st.extra_lit["T"] = true
            end
        },
        {6.5, "🛑"},
        {nil, "→", 1, {x_start + 3 * x_step - 4},
            function()
                st.extra_row[4].delete = true
                st.extra_lit["R"] = true
            end
        },
        {8, "🛑"},
        {nil, "→", 0.66, {x_start + 4 * x_step - 4},
            function()
                st.extra_row[5].delete = true
                st.extra_lit["A"] = true
                st.extra_ladybug = em.init("ladybug", x_start + 7.5 * x_step - 4, 69 - 5)
            end
        },
        {10, "🛑"},
        {12, "⚡", 16, y_start + (3 * 8) - 5},
        {13, "🛑"},
        {nil, "→", 1, {x_start - 4},
            function()
                st.special_row[1].delete = true
                st.special_lit["S"] = true
            end
        },
        {14.5, "🛑"},
        {nil, "→", 1, {x_start + x_step - 4}, st.wipe(st.special_row[2])},
        {16, "🛑"},
        {nil, "→", 1, {x_start + 2 * x_step - 4}, st.wipe(st.special_row[3])},
        {17.5, "🛑"},
        {nil, "→", 1, {x_start + 3 * x_step - 4}, st.wipe(st.special_row[4])},
    })

    st.extra_lit = {
        E = false,
        X = false,
        T = false,
        R = false,
        A = false,
    }

    st.special_lit = {
        S = false,
        P = false,
        E = false,
        C = false,
        I = false,
        A = false,
        L = false,
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

    pathfinder.update(dt)

    em.update(dt)
end

function st.draw()
    push:start()

    st.draw_special_letters()
    st.draw_extra_letters()

    love.graphics.setColor(0xae/255, 0xab/255, 0xae/255)
    love.graphics.print("                ×2×3×5", 8, 9)
    love.graphics.print("1ST      0", 112, 209);

    love.graphics.setColor(1, 80/255, 2/255);
    love.graphics.print("TOP  UNIVERSAL  10000", 24, 225)

    love.graphics.setColor(0, 253/255, 3/255);
    love.graphics.print("=9500", 24, 233);

    love.graphics.setColor(6/255, 175/255, 1);
    love.graphics.print("PART91", 72, 233);

    love.graphics.setColor(1, 1, 1);
    love.graphics.print("CREDIT 0", 128, 233);

    love.graphics.print("INSTRUCTION", 56, 41);

    love.graphics.print(" 10 POINTS", 64, 137);
    love.graphics.print("800 POINTS", 64, 161);

    em.draw()
    push:finish()
end

function st.draw_extra_letters()
    local x = 80
    local y = 9

    local letters = {"E", "X", "T", "R", "A"}
    for i, letter in ipairs(letters) do
        if st.extra_lit[letter] == true then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(0xae/255, 0xab/255, 0xae/255)
        end
        love.graphics.print(letter, x + 8 * (i - 1), y)
    end
end

function st.draw_special_letters()
    local x = 8
    local y = 9

    local letters = {"S", "P", "E", "C", "I", "A", "L"}
    for i, letter in ipairs(letters) do
        if st.special_lit[letter] == true then
            love.graphics.setColor(1, 0, 0)
        else
            love.graphics.setColor(0xae/255, 0xab/255, 0xae/255)
        end
        love.graphics.print(letter, x + 8 * (i - 1), y)
    end
end

return st
