local pathfinder = {
    paths = {}
}

function pathfinder.new_path(entity, steps)
    --
    -- Each element of the steps array is expected to be a tuple
    -- of {time, direction, speed}, with the following meaning:
    --
    -- {2, "↓", 0.5} => until time reaches 2.0s, move down with speed 0.5
    --
    local path = {
        steps = steps,
        current_step = 1,
        time = 0,
        x = entity.x,
        y = entity.y,
        angle = entity.angle
    }
    table.insert(pathfinder.paths, path)
    -- TODO perhaps we should start a path in a separate step
    pathfinder.restart(path)
    return path
end

function pathfinder.restart(path)
    path.time = 0
    path.current_step = 1
end

function pathfinder.update(dt)
    for i, path in ipairs(pathfinder.paths) do
        path.time = path.time + dt
        local step = path.steps[path.current_step]
        local interval_end = step[1]
        if path.time > interval_end then
            path.current_step = path.current_step + 1
            if path.current_step > #path.steps then
                pathfinder.restart(path)
            end
        end
    end
end

function pathfinder.action(path)
    return path.steps[path.current_step][2]
end

function pathfinder.speed(path)
    return path.steps[path.current_step][3]
end

function pathfinder.position(path)
    return path.steps[path.current_step][3],
           path.steps[path.current_step][4]
end

function pathfinder.move(path, entity)
    local speed = pathfinder.speed(path)
    local action = pathfinder.action(path)

    -- Move left
    if action == "←" then
        path.x = path.x - speed
        entity.angle = -math.pi

    -- Move right
    elseif action == "→" then
        path.x = path.x + speed
        entity.angle = 0

    -- Move upward
    elseif action == "↑" then
        path.y = path.y - speed
        entity.angle = -math.pi/2

    -- Move downward
    elseif action == "↓" then
        path.y = path.y + speed
        entity.angle = math.pi/2

    -- Lightning bolt: teleport to position
    elseif action == "⚡" then
        path.x, path.y = pathfinder.position(path)

    -- Stop sign: do nothing
    elseif action == "🛑" then
    end

    -- Keep fractional x, y positions separated
    -- to avoid sprite subpixel position artifacts
    entity.x = math.floor(path.x)
    entity.y = math.floor(path.y)

end

return pathfinder