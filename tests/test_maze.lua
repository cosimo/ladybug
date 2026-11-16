--
-- Maze model: walls, turnstiles and who can move where
--

local maze = require "lib.maze"

-- Three cells wide, two high:
--   - a wall between (1, 1) and (2, 1)
--   - a wall between (2, 1) and (2, 2)
local SMALL_MAZE = [[
+---+---+---+
|   |       |
+   +---+   +
|           |
+---+---+---+
]]

local tests = {}

function tests.test_wall_blocks_the_move_across_it()
    local small = maze.parse(SMALL_MAZE)

    assert(maze.blocker(small, 1, 1, "→") == "wall", "wall on the right of (1, 1)")
    assert(maze.blocker(small, 2, 1, "←") == "wall", "same wall, from (2, 1)")
    assert(maze.blocker(small, 2, 1, "↓") == "wall", "wall below (2, 1)")
    assert(maze.blocker(small, 2, 2, "↑") == "wall", "same wall, from (2, 2)")
end

function tests.test_open_edge_blocks_nothing()
    local small = maze.parse(SMALL_MAZE)

    assert(maze.blocker(small, 1, 1, "↓") == nil, "open edge below (1, 1)")
    assert(maze.blocker(small, 2, 1, "→") == nil, "open edge right of (2, 1)")
    assert(maze.blocker(small, 1, 2, "→") == nil, "open edge right of (1, 2)")
end

function tests.test_border_blocks_moves_out_of_the_maze()
    local small = maze.parse(SMALL_MAZE)

    assert(maze.blocker(small, 1, 1, "↑") == "border", "above the top row")
    assert(maze.blocker(small, 1, 1, "←") == "border", "left of the first column")
    assert(maze.blocker(small, 3, 2, "→") == "border", "right of the last column")
    assert(maze.blocker(small, 3, 2, "↓") == "border", "below the bottom row")
end

function tests.test_parse_reads_the_size_from_the_art()
    local small = maze.parse(SMALL_MAZE)

    assert(small.width == 3, "width " .. tostring(small.width))
    assert(small.height == 2, "height " .. tostring(small.height))
end

function tests.test_level1_is_11_by_11()
    local level1 = maze.parse(require "levels.level1")

    assert(level1.width == 11, "width " .. tostring(level1.width))
    assert(level1.height == 11, "height " .. tostring(level1.height))
end

function tests.test_level1_center_box_opens_only_upwards()
    local level1 = maze.parse(require "levels.level1")

    assert(maze.blocker(level1, 6, 6, "←") == "wall", "left side of the center box")
    assert(maze.blocker(level1, 6, 6, "→") == "wall", "right side of the center box")
    assert(maze.blocker(level1, 6, 6, "↓") == "wall", "bottom of the center box")
    assert(maze.blocker(level1, 6, 6, "↑") == nil, "the enemies leave the center box upwards")
end

function tests.test_level1_top_row_is_open_end_to_end()
    local level1 = maze.parse(require "levels.level1")

    for x = 1, 10 do
        assert(maze.blocker(level1, x, 1, "→") == nil, "wall right of (" .. x .. ", 1)")
    end
end

return tests
