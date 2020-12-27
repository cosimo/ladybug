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

    st.bonus_lit = {}
    st.bonus_lit["2"] = false
    st.bonus_lit["3"] = false
    st.bonus_lit["5"] = false

    st.credits = 0
    st.waited = 0.0
    st.current_bonus_points = ""

    st.is_player_dead = false

    st.next_state = states.attractmode
end

function st.initialize_sprites()
    st.playfield = em.init("playfield_level1")

    gameboard.random_initialize()

    st.low_hanging_fruit = {
        em.init("cucumber", 8, 224)
    }

    st.player_lives = {
        st.player_life(7, 208),
        st.player_life(23, 208),
        st.player_life(39, 208)
    }
end

function st.enter(prev)
    em.clear()
    pathfinder.clear()
    timeblocks.initialize()

    st.initialize_state()
    st.initialize_sprites()
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

    local points_by_time = {"800", "300", "100"}
    self.current_bonus_points = points_by_time[math.floor(self.waited * 2) % 3 + 1]

    self.input:update()
    self.process_input()

    pathfinder.update(dt)
    em.update(dt)
    timeblocks.update(dt)

    if self.is_player_dead then
        gs.switch(self.next_state)
    end
end

function st.draw()
    push:start()

    st.draw_special_letters()
    st.draw_extra_letters()
    st.draw_bonus_multipliers()

    love.graphics.print("1ST      0", 112, 209)

    love.graphics.setColor(1, 80/255, 0)
    love.graphics.print("TOP  UNIVERSAL  10000", 24, 225)

    love.graphics.setColor(0, 253/255, 3/255)
    love.graphics.print("=1000", 24, 233)

    love.graphics.setColor(6/255, 175/255, 1)
    love.graphics.print("PART 1", 72, 233)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("CREDIT " .. st.credits, 128, 233)

    em.draw()

    -- After em.draw() or the playfield static graphics will overwrite
    -- the timing block colors
    timeblocks.render()

    push:finish()
end

function st.letter(l, x_pos, y_pos)
    local letter = em.init_with_type('letter', l, x_pos, y_pos)

    -- Letters are presented as static, no animation
    letter.anim.temp.loop = animation.loop.NONE

    return letter
end

function st.skull(x_pos, y_pos)
    return em.init("skull", x_pos, y_pos)
end

function st.heart(x_pos, y_pos)
    local heart = em.init("heart", x_pos, y_pos)

    -- All heart bonus icons are also static, no animation
    heart.anim.temp.loop = animation.loop.NONE

    return heart
end

function st.player_life(x_pos, y_pos)
    return em.init("life", x_pos, y_pos)
end

function st.draw_bonus_multipliers()
    local x = 137
    local y = 9

    local multipliers = {"2", "3", "5"}
    for i, mul in ipairs(multipliers) do
        if st.bonus_lit[mul] == true then
            love.graphics.setColor(0.25, 0.6, 1)
        else
            love.graphics.setColor(0xae/255, 0xab/255, 0xae/255)
        end
        love.graphics.print("×" .. mul, x + 16 * (i - 1), y)
    end
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
