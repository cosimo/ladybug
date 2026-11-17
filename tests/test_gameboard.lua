--
-- Gameboard: cell coordinates, and the scripted walks of the play demo
--

local gameboard = require "lib.gameboard"
local maze = require "lib.maze"

-- Returns the cell moves of a scripted walk, as a list of {x, y, direction}
-- with the cell each move starts from. Steps without a direction, like the
-- 🛑 waits, have no moves.
local function walk_moves(walk, start_x, start_y)
    local moves = {}
    local x, y = start_x, start_y

    for _, step in ipairs(walk) do
        local direction = step[2]
        local stop = step[4]
        local cell_step = maze.STEPS[direction]

        if cell_step ~= nil then
            local stop_x, stop_y = gameboard.board_xy(stop[1], stop[2])

            while x ~= stop_x or y ~= stop_y do
                table.insert(moves, {x, y, direction})
                x, y = x + cell_step[1], y + cell_step[2]
            end
        end
    end

    return moves
end

-- Returns the moves of a walk that the maze doesn't allow, as text
local function illegal_moves(level, moves, can_push)
    local refused = {}

    for _, move in ipairs(moves) do
        local x, y, direction = move[1], move[2], move[3]
        if not maze.can_move(level, x, y, direction, can_push) then
            local blocked_by = maze.blocker(level, x, y, direction)
            table.insert(refused, string.format("(%d, %d) %s: %s", x, y, direction, blocked_by))
        end
    end

    return table.concat(refused, "; ")
end

local tests = {}

function tests.test_board_xy_finds_the_cell_of_its_center()
    for x = 1, gameboard.size.x do
        for y = 1, gameboard.size.y do
            local found_x, found_y = gameboard.board_xy(gameboard.cell_center(x, y))
            local where = string.format("cell (%d, %d) came back as (%d, %d)", x, y, found_x, found_y)
            assert(found_x == x and found_y == y, where)
        end
    end
end

function tests.test_board_xy_covers_the_whole_cell()
    local center_x, center_y = gameboard.cell_center(3, 4)
    local half = gameboard.size.w / 2

    local left_x = gameboard.board_xy(center_x - half, center_y)
    local right_x = gameboard.board_xy(center_x + half - 1, center_y)

    assert(left_x == 3, "left edge of cell (3, 4) is in column " .. left_x)
    assert(right_x == 3, "right edge of cell (3, 4) is in column " .. right_x)
end

function tests.test_demo_ladybug_walk_follows_level1_corridors()
    local level1 = maze.parse(require "levels.level1")
    local ladybug_can_push = true

    local moves = walk_moves(gameboard.random_walk_from(6, 9), 6, 9)
    local refused = illegal_moves(level1, moves, ladybug_can_push)

    assert(#moves > 0, "no moves in the ladybug walk")
    assert(refused == "", "the ladybug walks through " .. refused)
end

function tests.test_demo_beetle_walk_follows_level1_corridors()
    local level1 = maze.parse(require "levels.level1")
    local enemy_can_push = false

    local moves = walk_moves(gameboard.random_monster_walk_from(6, 6), 6, 6)
    local refused = illegal_moves(level1, moves, enemy_can_push)

    assert(#moves > 0, "no moves in the beetle walk")
    assert(refused == "", "the beetle walks through " .. refused)
end

return tests
