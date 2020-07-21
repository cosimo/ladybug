local pi = math.pi
local pi2 = pi / 2

local st = {}

function st.init()
    st.ladybug = animation.newanim(animation.newtemplate("ladybug", 16, 0.16))
    st.ladybug_x = 8
    st.ladybug_y = 8
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

function st.on_grid_x()
    local grid_offset = st.ladybug_y % 16
    local snap_point = 8
    local tolerance = 4
    local can_snap = grid_offset >= (snap_point - tolerance)
            and grid_offset <= (snap_point + tolerance)

    if can_snap then
        st.ladybug_y = st.ladybug_y - (grid_offset - snap_point)
        return true
    else
        return false
    end
end

function st.on_grid_y()
    local grid_offset = st.ladybug_x % 16
    local snap_point = 8
    local tolerance = 4
    local can_snap = grid_offset >= snap_point - tolerance
        and grid_offset <= snap_point + tolerance

    if can_snap then
        st.ladybug_x = st.ladybug_x - (grid_offset - snap_point)
        return true
    else
        return false
    end
end

function st.process_input()
    if st.input:get("move") then
        local step = 1
        if st.input:down("right") and st.on_grid_x() then
            st.ladybug_x = st.ladybug_x + step
            st.ladybug_r = 0
        elseif st.input:down("left") and st.on_grid_x() then
            st.ladybug_x = st.ladybug_x - step
            st.ladybug_r = -pi
        elseif st.input:down("down") and st.on_grid_y() then
            st.ladybug_y = st.ladybug_y + step
            st.ladybug_r = pi2
        elseif st.input:down("up") and st.on_grid_y() then
            st.ladybug_y = st.ladybug_y - step
            st.ladybug_r = -pi2
        end
    end
end

function st.check_boundaries()
    local ladybug_width = 8
    local ladybug_height = ladybug_width

    if st.ladybug_x < ladybug_width then
        st.ladybug_x = ladybug_width
    elseif st.ladybug_x > windowWidth - ladybug_width then
        st.ladybug_x = windowWidth - ladybug_width
    end

    if st.ladybug_y < ladybug_height then
        st.ladybug_y = ladybug_height
    elseif st.ladybug_y > windowHeight - ladybug_height then
        st.ladybug_y = windowHeight - ladybug_height
    end
end

function st.update(state, dt)
    lovebird.update()
    st.input:update()
    st.process_input()
    st.check_boundaries()
    animation.animupdate(st.ladybug, dt)
end

function st.draw()
    push:start()
    love.graphics.rectangle("line", 0, 0, windowWidth, windowHeight)
    animation.animdraw(st.ladybug, st.ladybug_x, st.ladybug_y, st.ladybug_r, 1, 1, 8, 8)
    push:finish()
end

return st
