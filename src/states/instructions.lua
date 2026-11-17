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

function st.initialize_state()
    st.extra_lit = gameboard.all_unlit("EXTRA")
    st.special_lit = gameboard.all_unlit("SPECIAL")
    st.bonus_lit = gameboard.all_unlit("235")

    st.credits = 0
    st.waited = 0.0
    st.current_bonus_points = ""

    st.next_state = states.playdemo
end

function st.initialize_sprites()
    st.playfield = em.init("playfield")

    local y_start = 65
    local x_start = 48
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
        st.dot(x_start, y_start),
        st.letter("x", x_start, y_start + 24)
    }
    st.insect = em.init("insect", 16, 232)

    y_start = 65
    x_start = 48
    x_step = 16

    st.ladybug = em.init("ladybug", 16, y_start - 1)
    st.ladybug.path = pathfinder.new_path(st.ladybug, {

        -- first row: EXTRA

        {2, "🛑"},
        {nil, "→", 1, {x_start},
         function()
             st.extra_row[1].delete = true
             st.extra_lit["E"] = true
         end
        },
        {3.5, "🛑"},
        {nil, "→", 1, {x_start + x_step},
         function()
             st.extra_row[2].delete = true
             st.extra_lit["X"] = true
         end
        },
        {5, "🛑"},
        {nil, "→", 1, {x_start + 2 * x_step},
         function()
             st.extra_row[3].delete = true
             st.extra_lit["T"] = true
         end
        },
        {6.5, "🛑"},
        {nil, "→", 1, {x_start + 3 * x_step},
         function()
             st.extra_row[4].delete = true
             st.extra_lit["R"] = true
         end
        },
        {8, "🛑"},
        {nil, "→", 1, {x_start + 4 * x_step},
         function()
             st.extra_row[5].delete = true
             st.extra_lit["A"] = true
             st.extra_ladybug = em.init("ladybug", x_start + 7.5 * x_step, y_start - 1)
         end
        },
        {9.5, "🛑"},

        -- second row: SPECIAL

        {12, "⚡", 16, y_start + (3 * 8) - 1},
        {nil, "→", 1, {x_start},
         function()
             st.special_row[1].delete = true
             st.special_lit["S"] = true
         end
        },
        {13.5, "🛑"},
        {nil, "→", 1, {x_start + x_step},
         function()
             st.special_row[2].delete = true
             st.special_lit["P"] = true
         end
        },
        {15, "🛑"},
        {nil, "→", 1, {x_start + 2 * x_step},
         function()
             st.special_row[3].delete = true
             st.special_lit["E"] = true
         end
        },
        {16.5, "🛑"},
        {nil, "→", 1, {x_start + 3 * x_step},
         function()
             st.special_row[4].delete = true
             st.special_lit["C"] = true
         end
        },
        {18, "🛑"},
        {nil, "→", 1, {x_start + 4 * x_step},
         function()
             st.special_row[5].delete = true
             st.special_lit["I"] = true
         end
        },
        {19.5, "🛑"},
        {nil, "→", 1, {x_start + 5 * x_step},
         function()
             st.special_row[6].delete = true
             st.special_lit["A"] = true
         end
        },
        {21, "🛑"},
        {nil, "→", 1, {x_start + 6 * x_step},
         function()
             st.special_row[7].delete = true
             st.special_lit["L"] = true
             st.special_dollar = em.init("coin",
                     x_start + 7.5 * x_step, y_start + 24 - 1)
         end
        },

        -- third row: hearts

        {23.5, "⚡", 16, y_start + (6 * 8) - 1},
        {nil, "→", 1, {x_start},
         function()
             st.hearts_row[1].delete = true
             st.bonus_lit["2"] = true
         end
        },

        {25, "🛑"},
        {nil, "→", 1, {x_start + 2 * x_step},
         function()
             st.hearts_row[2].delete = true
             st.bonus_lit["3"] = true
         end
        },

        {26.5, "🛑"},
        {nil, "→", 1, {x_start + 4 * x_step},
         function()
             st.hearts_row[3].delete = true
             st.bonus_lit["5"] = true
         end
        },

        {28, "🛑"},
        {nil, "→", 1, {x_start + 7.5 * x_step},
         function()
             st.ladybug.delete = true
             st.hearts_row[4].delete = true   -- skull
             st.ladybug_ghost = em.init("ghost", x_start + 7.5 * x_step, y_start + 48)
         end
        },
    })
end

function st.enter(prev)
    em.clear()
    pathfinder.clear()

    st.initialize_state()
    st.initialize_sprites()
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
    self.waited = self.waited + dt

    local points_by_time = {"800", "300", "100"}
    self.current_bonus_points = points_by_time[math.floor(self.waited * 2) % 3 + 1]

    self.input:update()
    self.process_input()

    pathfinder.update(dt)

    em.update(dt)

    if self.waited > 30.3 then
        gs.switch(self.next_state)
    end
end

function st.draw()
    push:start()

    gameboard.draw_special_letters(st.special_lit)
    gameboard.draw_extra_letters(st.extra_lit)
    gameboard.draw_bonus_multipliers(st.bonus_lit)

    love.graphics.print("1ST      0", 112, 209)

    love.graphics.setColor(1, 80/255, 2/255)
    love.graphics.print("TOP  UNIVERSAL  10000", 24, 225)

    love.graphics.setColor(0, 253/255, 3/255)
    love.graphics.print("=9500", 24, 233)

    love.graphics.setColor(6/255, 175/255, 1)
    love.graphics.print("PART91", 72, 233)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("CREDIT " .. st.credits, 128, 233)

    love.graphics.print("INSTRUCTION", 56, 41)

    local points_mult = " POINTS"
    if st.bonus_lit["5"] then
        points_mult = points_mult .. " ×5"
    elseif st.bonus_lit["3"] then
        points_mult = points_mult .. " ×3"
    elseif st.bonus_lit["2"] then
        points_mult = points_mult .. " ×2"
    end

    love.graphics.print(" 10" .. points_mult, 64, 137)
    love.graphics.print(st.current_bonus_points .. points_mult, 64, 161)

    em.draw()
    push:finish()
end

return st
