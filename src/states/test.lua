local st = {}

function st.init()
    st.input = baton.new {
        controls = {
            coin = {"key:5"},
            start = {"key:1", "key:2"},
        }
    }
end

function st.enter(prev)
    em.clear()
    st.waited = 0.0
    st.ladybug = em.init("ladybug", 64, 100)
    st.ladybug_path = pathfinder.new_path(st.ladybug, {
        {nil, "→", 0.5, {96, nil}},
        {nil, "↑", 0.5, {nil, 68}},
        {nil, "←", 0.5, {64, nil}},
        {nil, "↓", 0.5, {nil, 100}},
    })
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
    self.input:update()
    self.process_input()
    pathfinder.update(dt)
    em.update(dt)
end

function st.draw()
    push:start()

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("PATHFINDER.LIB", 32, 9);

    em.draw()

    push:finish()
end

return st
