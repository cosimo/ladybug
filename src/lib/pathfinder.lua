local pathfinder = {
    paths = {}
}

function pathfinder.new_path(entity, steps, move_callback)
    --
    -- Each element of the steps array is expected to be a tuple
    -- of {time, direction, speed}, with the following meaning:
    --
    -- {2, "↓", 0.5} => until time reaches 2.0s, move down with speed 0.5
    --
    local path = {
        entity = entity,
        x = entity.x,
        y = entity.y,
        angle = entity.angle,
        steps = steps,
        current_step = 1,
        time = 0,
        callback = move_callback,
    }
    table.insert(pathfinder.paths, path)
    -- TODO perhaps we should start a path in a separate step
    pathfinder.restart(path)
    return path
end

function pathfinder.clear()
    while #pathfinder.paths ~= 0 do
        rawset(pathfinder.paths, #pathfinder.paths, nil)
    end
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
        if interval_end ~= nil and path.time > interval_end then
            pathfinder.advance(path)
        else
            pathfinder.move(path)
        end
    end
end

function pathfinder.advance(path)
    local step = path.steps[path.current_step]
    local end_callback = step[5]

    if end_callback ~= nil then
        end_callback()
    end

    path.current_step = path.current_step + 1
    if path.current_step > #path.steps then
        pathfinder.restart(path)
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

function pathfinder.stop(path)
    local step = path.steps[path.current_step]
    if step[4] ~= nil and type(step[4]) == "table" then
        return step[4][1], step[4][2]
    else
        return nil, nil
    end
end

function pathfinder.move(path)
    local speed = pathfinder.speed(path)
    local action = pathfinder.action(path)

    local new_x = path.x
    local new_y = path.y
    local new_angle = path.angle

    local advance = false
    local stop_x, stop_y = pathfinder.stop(path)

    -- Move left
    if action == "←" then
        new_x = new_x - speed
        new_angle = -math.pi
        if stop_x ~= nil and new_x <= stop_x then
            new_x = stop_x
            advance = true
        end

    -- Move right
    elseif action == "→" then
        new_x = new_x + speed
        new_angle = 0
        if stop_x ~= nil and new_x >= stop_x then
            new_x = stop_x
            advance = true
        end

    -- Move upward
    elseif action == "↑" then
        new_y = new_y - speed
        new_angle = -math.pi/2
        if stop_y ~= nil and new_y <= stop_y then
            new_y = stop_y
            advance = true
        end

    -- Move downward
    elseif action == "↓" then
        new_y = new_y + speed
        new_angle = math.pi/2
        if stop_y ~= nil and new_y >= stop_y then
            new_y = stop_y
            advance = true
        end

    -- Lightning bolt: teleport to position
    elseif action == "⚡" then
        new_x, new_y = pathfinder.position(path)

    -- Stop sign: do nothing
    elseif action == "🛑" then
    end

    -- Keep fractional x, y positions separated
    -- to avoid sprite subpixel position artifacts

    path.x = new_x
    path.y = new_y
    path.angle = new_angle

    local prev_x = path.entity.x
    local prev_y = path.entity.y

    path.entity.x = math.floor(new_x)
    path.entity.y = math.floor(new_y)

    path.entity.angle = new_angle

    local changed_position = (prev_x ~= path.entity.x or prev_y ~= path.entity.y)
    if path.callback and (action == "🛑" or changed_position) then
        path.callback(path.entity, path.entity.x, path.entity.y, prev_x, prev_y)
    end

    if advance then
        pathfinder.advance(path)
    end
end

return pathfinder
