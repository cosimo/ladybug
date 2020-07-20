local st = {}

function st.init()
    st.ladybug = animation.newanim(animation.newtemplate("ladybug", 16, 0.16))
    st.ladybug_x = 60
    st.ladybug_y = 40
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
end

function st.leave()
end

function st.resume()
end

function st.process_input()
    if st.input:down("right") then
        st.ladybug_x = st.ladybug_x + 1
        st.ladybug_r = 0
    elseif st.input:down("left") then
        st.ladybug_x = st.ladybug_x - 1
        st.ladybug_r = -math.pi
    elseif st.input:down("up") then
        st.ladybug_y = st.ladybug_y - 1
        st.ladybug_r = -math.pi/2
    elseif st.input:down("down") then
        st.ladybug_y = st.ladybug_y + 1
        st.ladybug_r = math.pi/2
    end
end

function st.update(state, dt)
    lovebird.update()
    st.input:update()
    st.process_input()
    animation.animupdate(st.ladybug, dt)
end

function st.draw()
    push:start()
    animation.animdraw(st.ladybug, st.ladybug_x, st.ladybug_y, st.ladybug_r, 1, 1, 8, 8)
    push:finish()
end

return st
