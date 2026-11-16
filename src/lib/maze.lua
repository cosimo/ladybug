--
-- Maze model
--
-- The walls of a level, and who can move where. Plain data and functions,
-- with no LÖVE calls and no globals, so tests/ can run them without a
-- window.
--
-- A maze is parsed from ASCII art, as in src/levels/level1.lua. Each cell
-- is three characters wide, and the lines between cells hold the walls:
--
--     +---+---+
--     |   |   |    '|' is a wall between two cells side by side
--     +   +---+    '-' is a wall between two cells one above the other
--     |       |
--     +---+---+
--
-- Cells are numbered from (1, 1) at the top left, x to the right and y
-- down, like the gameboard grid.
--

local maze = {}

-- Cell offsets for each direction, the same arrows the pathfinder uses
maze.STEPS = {
    ["↑"] = {0, -1},
    ["↓"] = {0, 1},
    ["←"] = {-1, 0},
    ["→"] = {1, 0},
}

-- Returns the key of the edge crossed moving from cell (x, y) in direction.
-- "v x,y" is the vertical edge on the right of cell (x, y), "h x,y" the
-- horizontal edge below it.
local function edge_key(x, y, direction)
    if direction == "→" then
        return "v " .. x .. "," .. y

    elseif direction == "←" then
        return "v " .. (x - 1) .. "," .. y

    elseif direction == "↓" then
        return "h " .. x .. "," .. y

    elseif direction == "↑" then
        return "h " .. x .. "," .. (y - 1)
    end

    error("unknown direction " .. tostring(direction) .. ", valid ones are ↑ ↓ ← →")
end

-- Returns the lines of the art, without the trailing empty ones
local function art_lines(art)
    local lines = {}
    for line in art:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    return lines
end

-- Returns the character at a 0 based column of a line, or a space past
-- its end
local function char_at(line, column)
    local char = line:sub(column + 1, column + 1)
    if char == "" then
        return " "
    end
    return char
end

function maze.parse(art)
    local lines = art_lines(art)
    local width = (#lines[1] - 1) / 4
    local height = (#lines - 1) / 2

    local walls = {}

    for y = 1, height do
        local cells_line = lines[2 * y]
        local below_line = lines[2 * y + 1]

        for x = 1, width do
            if char_at(cells_line, 4 * x) == "|" then
                walls[edge_key(x, y, "→")] = true
            end

            if char_at(below_line, 4 * x - 2) == "-" then
                walls[edge_key(x, y, "↓")] = true
            end
        end
    end

    return {
        width = width,
        height = height,
        walls = walls,
    }
end

-- Returns what stops a move from cell (x, y) in direction: "border",
-- "wall", or nil when the way is free
function maze.blocker(m, x, y, direction)
    local step = maze.STEPS[direction]
    local next_x, next_y = x + step[1], y + step[2]

    local is_outside = next_x < 1 or next_x > m.width or next_y < 1 or next_y > m.height
    if is_outside then
        return "border"
    end

    if m.walls[edge_key(x, y, direction)] then
        return "wall"
    end

    return nil
end

return maze
