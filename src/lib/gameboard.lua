local gameboard = {
    size = {x=11, y=11, w=16, h=16},
    offset = {x=2, y=19},
    grid = {},
    entities = {},
    gates = {},
    gate_entities = {},

    EMPTY = 0,
    DOT = 1,
    SKULL = 2,
    BONUS = 3,
    TURNSTILE_H = 4,
    TURNSTILE_V = 5,

    LETTER_S = 10,
    LETTER_P = 11,
    LETTER_E = 12,
    LETTER_C = 13,
    LETTER_I = 14,
    LETTER_A = 15,
    LETTER_L = 16,
    LETTER_X = 17,
    LETTER_T = 18,
    LETTER_R = 19,

    BEETLE = 20,
}

function gameboard.clear()
    while #gameboard.grid ~= 0 do
        rawset(gameboard.grid, #gameboard.grid, nil)
    end
    while #gameboard.entities ~= 0 do
        rawset(gameboard.entities, #gameboard.entities, nil)
    end
    while #gameboard.gates ~= 0 do
        rawset(gameboard.gates, #gameboard.gates, nil)
    end
end

function gameboard.random_initialize()
    local grid = gameboard.grid
    local gates = gameboard.gates

    for x = 1, gameboard.size.x do
        grid[x] = {}
        for y = 1, gameboard.size.y do
            grid[x][y] = gameboard.DOT
        end
    end

    for x = 1, gameboard.size.x - 1 do
        gates[x] = {}
        for y = 1, gameboard.size.y - 1 do
            gates[x][y] = nil
        end
    end

    -- Play demo bonuses, skulls, etc...
    grid[5][1] = gameboard.SKULL
    grid[3][9] = gameboard.SKULL

    grid[6][1] = gameboard.LETTER_E
    grid[1][6] = gameboard.LETTER_P
    grid[11][8] = gameboard.LETTER_T

    grid[6][4] = gameboard.BONUS
    grid[5][6] = gameboard.BONUS
    grid[9][5] = gameboard.BONUS

    -- Central enemy insect home
    grid[6][6] = gameboard.BEETLE

    -- Initial parading corridor
    grid[6][9] = gameboard.EMPTY
    grid[6][10] = gameboard.EMPTY
    grid[6][11] = gameboard.EMPTY

    -- Turnstile states
    gates[2][1] = gameboard.TURNSTILE_H
    gates[1][3] = gameboard.TURNSTILE_V
    gates[3][3] = gameboard.TURNSTILE_H
    gates[4][2] = gameboard.TURNSTILE_V
    gates[4][4] = gameboard.TURNSTILE_H
    gates[7][2] = gameboard.TURNSTILE_H
    gates[9][1] = gameboard.TURNSTILE_H

    gameboard.render()
end

function gameboard.render()
    local pos, ent
    for x = 1, gameboard.size.x do
        gameboard.entities[x] = {}
        for y = 1, gameboard.size.y do
            pos = gameboard.grid[x][y]
            ent = nil
            if pos == gameboard.DOT then
                ent = gameboard.dot(x, y)
            elseif pos == gameboard.SKULL then
                ent = gameboard.skull(x, y)
            elseif pos == gameboard.BONUS then
                ent = gameboard.bonus(x, y)
            elseif pos == gameboard.LETTER_E then
                ent = gameboard.letter("e", x, y)
            elseif pos == gameboard.LETTER_P then
                ent = gameboard.letter("p", x, y)
            elseif pos == gameboard.LETTER_T then
                ent = gameboard.letter("t", x, y)
            elseif pos == gameboard.BEETLE then
                ent = gameboard.enemy("beetle", x, y)
            end
            if ent ~= nil then
                gameboard.entities[x][y] = ent
            end
        end
    end

    for x = 1, gameboard.size.x - 1 do
        if gameboard.gates[x] == nil then
            gameboard.gates[x] = {}
        end
        for y = 1, gameboard.size.y - 1 do
            local turnstile_direction = gameboard.gates[x][y]
            if turnstile_direction ~= nil then
                gameboard.place_turnstile(turnstile_direction, x, y)
            end
        end
    end
end

function gameboard.place_turnstile(direction, x, y)
    local screen_x, screen_y
    screen_x, screen_y = gameboard.screen_xy(x, y, "turnstile")
    local ent = em.init("turnstile", screen_x, screen_y)
    if direction == gameboard.TURNSTILE_V then
        ent.angle = -math.pi/2
        ent.y = ent.y + 16
    end
    ent.anim.temp.speed = 0
    if gameboard.gate_entities[x] == nil then
        gameboard.gate_entities[x] = {}
    end
    gameboard.gate_entities[x][y] = ent
    return ent
end

function gameboard.place_entity(entity_name, x, y)
    local screen_x, screen_y
    screen_x, screen_y = gameboard.screen_xy(x, y, entity_name)
    gameboard.grid[x][y] = em.init(entity_name, screen_x, screen_y)
    gameboard.grid[x][y].anim.temp.speed = 0
    return gameboard.grid[x][y]
end

function gameboard.place_bonus(x, y)
    local screen_x, screen_y
    screen_x, screen_y = gameboard.screen_xy(x, y, "heart")
    gameboard.grid[x][y] = em.init("heart", screen_x, screen_y)
    gameboard.grid[x][y].anim.temp.speed = 0
    gameboard.grid[x][y].anim.frame = 2
end

function gameboard.place_letter(letter, x, y)
    local screen_x, screen_y
    screen_x, screen_y = gameboard.screen_xy(x, y, "letter")
    gameboard.grid[x][y] = em.init_with_type("letter", letter, screen_x, screen_y)
    gameboard.grid[x][y].anim.temp.speed = 0
    gameboard.grid[x][y].anim.frame = 2
end

function gameboard.bonus(x, y)
    gameboard.place_bonus(x, y)
end

function gameboard.letter(letter, x, y)
    gameboard.place_letter(letter, x, y)
end

function gameboard.dot(x, y)
    gameboard.place_entity("dot", x, y)
end

function gameboard.skull(x, y)
    gameboard.place_entity("skull", x, y)
end

function gameboard.enemy(entity_name, x, y)
    local enemy = gameboard.place_entity(entity_name, x, y)
    enemy.angle = -math.pi/2
end

function gameboard.screen_xy(board_x, board_y, entity_name)
    local screen_x = gameboard.offset.x + board_x * gameboard.size.w
    local screen_y = gameboard.offset.y + board_y * gameboard.size.h
    if entity_name == "beetle" then
        screen_x = screen_x - 2
        screen_y = screen_y - 2
    elseif entity_name == "turnstile" then
        screen_x = screen_x - 2
        screen_y = screen_y - 2
    elseif entity_name ~= "dot" then
        screen_x = screen_x + 2
        screen_y = screen_y + 2
    end
    return screen_x, screen_y
end

return gameboard
