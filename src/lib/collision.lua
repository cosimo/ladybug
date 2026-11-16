local collision = {}

-- Two sprites touch when their centers are this close, in pixels, on both
-- axes. With the ladybug moving one pixel per frame, it touches a dot on two
-- consecutive positions.
local TOUCH_DISTANCE = 0.5

function collision.detect(entity, curr_screen_x, curr_screen_y, prev_screen_x, prev_screen_y)
    local board_x, board_y = gameboard.board_xy(curr_screen_x, curr_screen_y)
    local board_element = gameboard.grid[board_x][board_y]
    if board_element == 0 then
        return
    end

    local entity_x, entity_y = em.center(entity)
    local element_x, element_y = em.center(board_element)
    local is_touching = math.abs(entity_x - element_x) <= TOUCH_DISTANCE
        and math.abs(entity_y - element_y) <= TOUCH_DISTANCE

    if is_touching then
        collision.between(entity, board_element, curr_screen_x, curr_screen_y)
    end
end

function collision.between(entity1, entity2, x, y)
    if entity1.name ~= "ladybug" or entity2.delete then
        return
    end

    if entity2.name == "dot" then
        entity2.delete = true
        gameboard.player_score = gameboard.player_score + 10
        return
    end

    -- TODO the ladybug walks over everything else for now. It should:
    --   - die on a skull or an enemy
    --   - collect a heart or a letter for bonus points, lighting up a
    --     multiplier or a SPECIAL or EXTRA letter
end

-- Just for debugging
function collision.noop(entity, curr_screen_x, curr_screen_y, prev_screen_x, prev_screen_y)
    local board_x, board_y = gameboard.board_xy(curr_screen_x, curr_screen_y)
    print(entity.name, board_x, board_y)
end

return collision
