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

-- Three cells wide, two high, with a horizontal turnstile pivoting on the
-- corner shared by (1, 1), (2, 1), (1, 2) and (2, 2). Its arms lie below
-- (1, 1) and below (2, 1).
local TURNSTILE_MAZE = [[
+---+---+---+
|           |
+===H===+   +
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

function tests.test_parse_reads_turnstile_pivots()
    local small = maze.parse(TURNSTILE_MAZE)

    assert(small.turnstiles[1][1] == "H", "horizontal turnstile at (1, 1)")
    assert(small.turnstiles[2][1] == nil, "no turnstile at (2, 1)")
end

function tests.test_turnstile_arms_block_the_edges_they_lie_on()
    local small = maze.parse(TURNSTILE_MAZE)

    assert(maze.blocker(small, 1, 1, "↓") == "turnstile", "left arm, below (1, 1)")
    assert(maze.blocker(small, 2, 2, "↑") == "turnstile", "right arm, above (2, 2)")
    assert(maze.blocker(small, 3, 1, "↓") == nil, "nothing below (3, 1)")
    assert(maze.blocker(small, 1, 1, "→") == nil, "a horizontal turnstile leaves (1, 1) to (2, 1) open")
end

function tests.test_push_turns_the_turnstile_a_quarter_turn()
    local small = maze.parse(TURNSTILE_MAZE)

    local pushed = maze.push(small, 1, 1, "↓")

    assert(pushed.turnstiles[1][1] == "V", "pushed turnstile is now vertical")
    assert(small.turnstiles[1][1] == "H", "push() changed the original maze")
end

function tests.test_turned_turnstile_blocks_the_other_two_edges()
    local pushed = maze.push(maze.parse(TURNSTILE_MAZE), 1, 1, "↓")

    assert(maze.blocker(pushed, 1, 1, "↓") == nil, "the edge pushed through is open")
    assert(maze.blocker(pushed, 2, 1, "↓") == nil, "the other horizontal arm moved away")
    assert(maze.blocker(pushed, 1, 1, "→") == "turnstile", "upper arm, right of (1, 1)")
    assert(maze.blocker(pushed, 2, 2, "←") == "turnstile", "lower arm, left of (2, 2)")
end

function tests.test_push_without_a_turnstile_in_the_way_changes_nothing()
    local small = maze.parse(TURNSTILE_MAZE)

    local pushed = maze.push(small, 3, 1, "↓")

    assert(pushed.turnstiles[1][1] == "H", "turnstile turned by a push elsewhere")
end

function tests.test_only_the_ladybug_moves_through_turnstiles()
    local small = maze.parse(TURNSTILE_MAZE)
    local ladybug_can_push = true
    local enemy_can_push = false

    assert(maze.can_move(small, 1, 1, "↓", ladybug_can_push), "the ladybug pushes the turnstile")
    assert(not maze.can_move(small, 1, 1, "↓", enemy_can_push), "enemies can't push turnstiles")
end

function tests.test_nobody_moves_through_walls_or_the_border()
    local small = maze.parse(SMALL_MAZE)

    assert(not maze.can_move(small, 1, 1, "→", true), "the ladybug went through a wall")
    assert(not maze.can_move(small, 1, 1, "↑", true), "the ladybug left the maze")
    assert(maze.can_move(small, 1, 1, "↓", false), "open edge refused to an enemy")
end

-- Lanes every 16 pixels from 8, as on the attract mode screen, and a
-- sprite snaps onto one from up to 4 pixels away
local FIRST_LANE, LANE_SPACING, SNAP_TOLERANCE = 8, 16, 4

function tests.test_snap_to_lane_keeps_a_value_on_a_lane()
    assert(maze.snap_to_lane(8, FIRST_LANE, LANE_SPACING, SNAP_TOLERANCE) == 8, "first lane")
    assert(maze.snap_to_lane(40, FIRST_LANE, LANE_SPACING, SNAP_TOLERANCE) == 40, "third lane")
end

function tests.test_snap_to_lane_pulls_a_close_value_onto_the_lane()
    assert(maze.snap_to_lane(44, FIRST_LANE, LANE_SPACING, SNAP_TOLERANCE) == 40, "4 pixels past the lane")
    assert(maze.snap_to_lane(36, FIRST_LANE, LANE_SPACING, SNAP_TOLERANCE) == 40, "4 pixels before the lane")
    assert(maze.snap_to_lane(5, FIRST_LANE, LANE_SPACING, SNAP_TOLERANCE) == 8, "before the first lane")
end

function tests.test_snap_to_lane_refuses_a_value_between_lanes()
    local between_lanes = 45

    local snapped = maze.snap_to_lane(between_lanes, FIRST_LANE, LANE_SPACING, SNAP_TOLERANCE)

    assert(snapped == nil, "45 is 5 pixels from both lanes, snapped to " .. tostring(snapped))
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
