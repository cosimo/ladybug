local pi = math.pi
local pi2 = pi / 2

local st = {}

function st.init()
    st.waited = 0.0
    st.next_state = states.instructions

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

    st.title = em.init("title")
    st.ladybug = em.init("ladybug")
    st.beetle = em.init("beetle")
    st.hummer = em.init("hummer")
    st.mantis = em.init("mantis")
    st.scarab = em.init("scarab")
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

function st.update(self, dt)
    lovebird.update()
    self.waited = self.waited + dt
    if self.waited > 5.0 then
        gs.switch(self.next_state)
    end
    self.input:update()
    self.process_input()
    self.check_boundaries(st.ladybug)
    em.update(dt)
end

function st.draw()
    push:start()

    love.graphics.setColor(0xfc/255, 0xb2/255, 0xf2/255)
    love.graphics.print("INSERT COIN", 56, 180);

    love.graphics.setColor(1, 1, 0)
    love.graphics.print("1       1", 40, 204);

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("COIN    PLAY", 56, 204);

    em.draw()
    push:finish()
end

return st
