local pi = math.pi
local pi2 = pi / 2

local st = {}

function st.init()
    st.ladybug = em.init("ladybug", 8, 8)
    st.title = em.init("title")
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

function st.on_grid_x(obj)
    local grid_offset = obj.y % 16
    local snap_point = 8
    local tolerance = 4
    local can_snap = grid_offset >= (snap_point - tolerance)
            and grid_offset <= (snap_point + tolerance)

    if can_snap then
        obj.y = obj.y - (grid_offset - snap_point)
        return true
    else
        return false
    end
end

function st.on_grid_y(obj)
    local grid_offset = obj.x % 16
    local snap_point = 8
    local tolerance = 4
    local can_snap = grid_offset >= snap_point - tolerance
        and grid_offset <= snap_point + tolerance

    if can_snap then
        obj.x = obj.x - (grid_offset - snap_point)
        return true
    else
        return false
    end
end

function st.process_input()
    if st.input:get("move") then
        local step = 1
        local ladybug = st.ladybug
        if st.input:down("right") and st.on_grid_x(ladybug) then
            ladybug.x = ladybug.x + step
            ladybug.angle = 0
        elseif st.input:down("left") and st.on_grid_x(ladybug) then
            ladybug.x = ladybug.x - step
            ladybug.angle = -pi
        elseif st.input:down("down") and st.on_grid_y(ladybug) then
            ladybug.y = ladybug.y + step
            ladybug.angle = pi2
        elseif st.input:down("up") and st.on_grid_y(ladybug) then
            ladybug.y = ladybug.y - step
            ladybug.angle = -pi2
        end
    end
end

function st.check_boundaries(obj)
    local width = 8
    local height = width

    if obj.x < width then
        obj.x = width
    elseif obj.x > windowWidth - width then
        obj.x = windowWidth - width
    end

    if obj.y < height then
        obj.y = height
    elseif obj.y > windowHeight - height then
        obj.y = windowHeight - height
    end
end

function st.update(state, dt)
    lovebird.update()
    st.input:update()
    st.process_input()
    st.check_boundaries(st.ladybug)
    em.update(dt)
end

function st.draw()
    push:start()
    love.graphics.rectangle("line", 0, 0, windowWidth, windowHeight)
    em.draw()
    push:finish()
end

return st
