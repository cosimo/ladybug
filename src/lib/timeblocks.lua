local timeblocks = {
    -- Blocks are numbered from 1, where the first block that
    -- turns on after the timer starts is the top center block
    blocks = {},
    size = 92,
    start_time = 0,
    last_dt = 0,

    -- Block states
    OFF = 0,
    ON = 1,

    -- Block shapes
    HORIZONTAL = 2,
    VERTICAL = 3,
    UPPER_LEFT_CORNER = 4,
    UPPER_RIGHT_CORNER = 5,
    LOWER_LEFT_CORNER = 6,
    LOWER_RIGHT_CORNER = 7,
}

function timeblocks.clear()
    while #timeblocks.blocks ~= 0 do
        rawset(timeblocks.blocks, #timeblocks.blocks, nil)
    end
end

function timeblocks.initialize()
    timeblocks.clear()

    local blocks = timeblocks.blocks

    for i = 1, timeblocks.size do
        blocks[i] = timeblocks.OFF
    end
end

function timeblocks.update(dt)
    if timeblocks.start_time == 0 then
        timeblocks.start_time = dt
        timeblocks.last_dt = dt
    else
        timeblocks.last_dt = timeblocks.last_dt + dt * 10
    end

    local block_index = (math.floor(timeblocks.last_dt) % timeblocks.size) + 1

    if block_index ~= timeblocks.last_block then
        local current_state = timeblocks.blocks[block_index]
        local next_state = current_state == timeblocks.OFF and timeblocks.ON or timeblocks.OFF

        timeblocks.blocks[block_index] = next_state
        timeblocks.last_block = block_index
    end
end

function timeblocks.render()
    local i
    for i = 1, timeblocks.size do
        timeblocks.render_block(i)
    end
end

function timeblocks.render_block(index)
    local block_state = timeblocks.blocks[index]

    if block_state == timeblocks.OFF then
        return
    end

    local shape = timeblocks.get_block_shape(index)

    if shape == timeblocks.HORIZONTAL then
        timeblocks.render_block_horizontal(index)
    elseif shape == timeblocks.VERTICAL then
        timeblocks.render_block_vertical(index)
    else
        timeblocks.render_block_corner(index, shape)
    end
end

function timeblocks.render_block_horizontal(index)
    local x1 = 7
    local y1 = 19

    if index < 12 then      -- 1..11
        x1 = x1 + 80 + 8 * index
    elseif index > 81 then  -- 82..96
        x1 = x1 + 8 * (index - 82)
    elseif index > 35 then  -- 36..57
        x1 = x1 + 8 * (57 - index)
        y1 = 203
    end

    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('fill', x1 + 1, y1, 7, 4)
end

function timeblocks.render_block_vertical(index)
    local x1 = 2
    local y1 = 17

    if index > 58 then
        y1 = y1 + 8 * (81 - index)
    elseif index > 12 then
        y1 = y1 + 8 * (index - 12)
        x1 = 186
    end

    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('fill', x1, y1, 4, 7)
end

function timeblocks.render_block_corner(index, shape)
    local x1, y1, x2, y2
    local x3, y3, x4, y4

    love.graphics.setColor(0, 1, 0)

    if shape == timeblocks.UPPER_LEFT_CORNER then
        love.graphics.rectangle('fill', 2, 19, 5, 4)
        love.graphics.rectangle('fill', 2, 19, 4, 5)
    elseif shape == timeblocks.UPPER_RIGHT_CORNER then
        love.graphics.rectangle('fill', 184, 19, 5, 4)
        love.graphics.rectangle('fill', 186, 19, 4, 5)
    elseif shape == timeblocks.LOWER_RIGHT_CORNER then
        love.graphics.rectangle('fill', 184, 203, 5, 4)
        love.graphics.rectangle('fill', 186, 201, 4, 6)
    elseif shape == timeblocks.LOWER_LEFT_CORNER then
        love.graphics.rectangle('fill', 2, 203, 5, 4)
        love.graphics.rectangle('fill', 2, 201, 4, 5)
    end

end

function timeblocks.get_block_shape(index)
    local shape
    if index == 12 then
        shape = timeblocks.UPPER_RIGHT_CORNER
    elseif index == 35 then
        shape = timeblocks.LOWER_RIGHT_CORNER
    elseif index == 58 then
        shape = timeblocks.LOWER_LEFT_CORNER
    elseif index == 81 then
        shape = timeblocks.UPPER_LEFT_CORNER
    elseif (index > 12 and index < 35) or (index > 58 and index < 81) then
        shape = timeblocks.VERTICAL
    else
        shape = timeblocks.HORIZONTAL
    end
    return shape
end

return timeblocks
