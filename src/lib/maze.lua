--
-- Maze model
--
-- The walls and turnstiles of a level, and who can move where. Plain data
-- and functions, with no LÖVE calls and no globals, so tests/ can run them
-- without a window.
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
-- A turnstile is a bar two cells long, pivoting on the corner shared by
-- four cells. Turnstile (x, y) pivots on the bottom right corner of cell
-- (x, y), and its orientation is 'H' or 'V' at that corner in the art:
--
--     +---+---+
--     |       |    a horizontal turnstile has its arms below (1, 1) and
--     +===H===+    below (2, 1), drawn with '=' only for readability
--     |       |
--     +---+---+
--
-- A vertical one has its arms right of (1, 1) and right of (1, 2), drawn
-- with ':'. The ladybug can push an arm, and the turnstile turns a quarter
-- turn around its pivot. Enemies can't push turnstiles.
--

local maze = {}

-- Cell offsets for each direction, the same arrows the pathfinder uses
maze.STEPS = {
    ["↑"] = {0, -1},
    ["↓"] = {0, 1},
    ["←"] = {-1, 0},
    ["→"] = {1, 0},
}

-- What a horizontal or vertical turnstile becomes, after a push
local TURNED = {H = "V", V = "H"}

-- Returns the edge crossed moving from cell (x, y) in direction: "v" for
-- the vertical edge on the right of the returned cell, or "h" for the
-- horizontal edge below it
local function crossed_edge(x, y, direction)
    if direction == "→" then
        return "v", x, y

    elseif direction == "←" then
        return "v", x - 1, y

    elseif direction == "↓" then
        return "h", x, y

    elseif direction == "↑" then
        return "h", x, y - 1
    end

    error("unknown direction " .. tostring(direction) .. ", valid ones are ↑ ↓ ← →")
end

-- Returns the key of an edge in the walls set, as in "v 6,7"
local function edge_key(kind, x, y)
    return kind .. " " .. x .. "," .. y
end

-- Returns the orientation of turnstile (x, y), nil if there is none
local function turnstile_at(m, x, y)
    local column = m.turnstiles[x]
    if column == nil then
        return nil
    end
    return column[y]
end

-- Returns the pivot of the turnstile with an arm on an edge, if any.
-- A horizontal turnstile (x, y) has arms on the "h" edges of (x, y) and
-- (x + 1, y), a vertical one on the "v" edges of (x, y) and (x, y + 1).
local function turnstile_on_edge(m, kind, x, y)
    if kind == "h" then
        if turnstile_at(m, x, y) == "H" then
            return x, y
        end
        if turnstile_at(m, x - 1, y) == "H" then
            return x - 1, y
        end
        return nil
    end

    if turnstile_at(m, x, y) == "V" then
        return x, y
    end
    if turnstile_at(m, x, y - 1) == "V" then
        return x, y - 1
    end
    return nil
end

-- Returns a copy of the turnstiles table, x then y
local function copy_turnstiles(turnstiles)
    local copy = {}

    for x, column in pairs(turnstiles) do
        copy[x] = {}
        for y, orientation in pairs(column) do
            copy[x][y] = orientation
        end
    end

    return copy
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
    local turnstiles = {}

    for x = 1, width - 1 do
        turnstiles[x] = {}
    end

    for y = 1, height do
        local cells_line = lines[2 * y]
        local below_line = lines[2 * y + 1]

        for x = 1, width do
            if char_at(cells_line, 4 * x) == "|" then
                walls[edge_key("v", x, y)] = true
            end

            if char_at(below_line, 4 * x - 2) == "-" then
                walls[edge_key("h", x, y)] = true
            end

            local corner = char_at(below_line, 4 * x)
            if corner == "H" or corner == "V" then
                turnstiles[x][y] = corner
            end
        end
    end

    return {
        width = width,
        height = height,
        walls = walls,
        turnstiles = turnstiles,
    }
end

-- Returns what stops a move from cell (x, y) in direction: "border",
-- "wall", "turnstile", or nil when the way is free
function maze.blocker(m, x, y, direction)
    local kind, edge_x, edge_y = crossed_edge(x, y, direction)
    local step = maze.STEPS[direction]
    local next_x, next_y = x + step[1], y + step[2]

    local is_outside = next_x < 1 or next_x > m.width or next_y < 1 or next_y > m.height
    if is_outside then
        return "border"
    end

    if m.walls[edge_key(kind, edge_x, edge_y)] then
        return "wall"
    end

    if turnstile_on_edge(m, kind, edge_x, edge_y) then
        return "turnstile"
    end

    return nil
end

-- Returns whether a move from cell (x, y) in direction is possible. Only
-- who can push turnstiles, the ladybug, moves through their arms.
function maze.can_move(m, x, y, direction, can_push)
    local blocked_by = maze.blocker(m, x, y, direction)
    if blocked_by == nil then
        return true
    end

    return blocked_by == "turnstile" and can_push == true
end

-- Returns the maze after moving from cell (x, y) in direction. A turnstile
-- in the way turns a quarter turn, the maze passed in stays as it is.
function maze.push(m, x, y, direction)
    local kind, edge_x, edge_y = crossed_edge(x, y, direction)
    local pivot_x, pivot_y = turnstile_on_edge(m, kind, edge_x, edge_y)
    if pivot_x == nil then
        return m
    end

    local turnstiles = copy_turnstiles(m.turnstiles)
    turnstiles[pivot_x][pivot_y] = TURNED[turnstiles[pivot_x][pivot_y]]

    return {
        width = m.width,
        height = m.height,
        walls = m.walls,
        turnstiles = turnstiles,
    }
end

return maze
