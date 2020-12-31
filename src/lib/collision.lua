local collision = {}

function collision.detect(entity, curr_screen_x, curr_screen_y, prev_screen_x, prev_screen_y)
    local board_x, board_y = gameboard.board_xy(curr_screen_x, curr_screen_y, entity.name)
    local board_element = gameboard.grid[board_x][board_y]
    if board_element ~= 0 then
        print(curr_screen_x, curr_screen_y, board_element.x, board_element.y)
        if math.abs(curr_screen_x - board_element.x) <= 2
                and math.abs(curr_screen_y - board_element.y) <= 2 then
            collision.between(entity, board_element, curr_screen_x, curr_screen_y)
        end
    end
end

function collision.between(entity1, entity2, x, y)
    if entity1.name == "ladybug" and entity2.delete == false then
        entity2.delete = true
        gameboard.player_score = gameboard.player_score + 10
    end
end

-- Just for debugging
function collision.noop(entity, curr_screen_x, curr_screen_y, prev_screen_x, prev_screen_y)
    local board_x, board_y = gameboard.board_xy(curr_screen_x, curr_screen_y, entity.name)
    print(entity.name, board_x, board_y)
end

return collision
