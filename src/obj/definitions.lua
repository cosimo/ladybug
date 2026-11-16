--
-- Entity definitions
--
-- em.init(name, x, y) builds a new entity from the definition with that
-- name. An entity is either animated, with its frames cut from a horizontal
-- strip in assets/<sheet>.png, or a static image.
--
-- Every sprite is anchored on its center: x, y is the middle of the sprite,
-- and on the board it is the center of the cell, from gameboard.cell_center().
-- The 9 pixel items (hearts, letters, skulls) have their origin at 5, 5
-- rather than 4, 4. The arcade draws them one pixel up and left of the 3
-- pixel dots, which I checked against the MAME capture.
--
--   layer          draw order, lowest first
--   uplayer        update order, lowest first
--   sheet          sprite sheet of an animated entity, under assets/
--   frame_width    width of one frame in the sheet, in pixels
--   frame_seconds  how long each frame shows, 0 to never change frame
--   loop           "FORWARDS", or by default "PENDULUM" (forwards then back)
--   origin         the point of the sprite that is drawn at x, y
--   image          static image, under assets/
--   x, y, angle    where the entity starts, when em.init() gets no x, y
--
-- The letter sheet has a %s for the letter, filled in by
-- em.init_with_type("letter", "s", x, y).
--

return {

    --
    -- --- Ladybug ---
    --

    ladybug = {
        layer = -3, uplayer = 3,
        sheet = "obj/ladybug", frame_width = 16, frame_seconds = 0.125,
        origin = {8, 8},
        x = 24, y = 180,
    },

    -- Ladybug death animation
    ghost = {
        layer = -3, uplayer = 3,
        sheet = "obj/ghost", frame_width = 16, frame_seconds = 0.125, loop = "FORWARDS",
        origin = {8, 8},
        x = 24, y = 180,
    },

    -- Player life, the static ladybugs at the bottom left
    life = {
        layer = -4, uplayer = 4,
        image = "obj/life",
        origin = {8, 8},
        x = 24, y = 168,
    },

    --
    -- --- Enemies ---
    --

    beetle = {
        layer = -3, uplayer = 3,
        sheet = "obj/beetle", frame_width = 16, frame_seconds = 0.125,
        origin = {8, 8},
        x = 160, y = 40, angle = -math.pi,
    },

    hummer = {
        layer = -3, uplayer = 3,
        sheet = "obj/hummer", frame_width = 16, frame_seconds = 0.125,
        origin = {8, 8},
        x = 32, y = 80,
    },

    mantis = {
        layer = -3, uplayer = 3,
        sheet = "obj/mantis", frame_width = 16, frame_seconds = 0.125,
        origin = {8, 8},
        x = 104, y = 88, angle = -math.pi / 2,
    },

    scarab = {
        layer = -3, uplayer = 3,
        sheet = "obj/scarab", frame_width = 16, frame_seconds = 0.125,
        origin = {8, 8},
        x = 72, y = 24, angle = -math.pi / 2,
    },

    -- Funny one-time appearance insect
    insect = {
        layer = -5, uplayer = 5,
        sheet = "obj/insect", frame_width = 10, frame_seconds = 0,
        origin = {5, 5},
    },

    --
    -- --- Board items ---
    --

    dot = {
        layer = -5, uplayer = 5,
        sheet = "obj/dot", frame_width = 3, frame_seconds = 0,
        origin = {1, 1},
    },

    heart = {
        layer = -4, uplayer = 4,
        sheet = "obj/heart", frame_width = 9, frame_seconds = 0.5, loop = "FORWARDS",
        origin = {5, 5},
    },

    letter = {
        layer = -4, uplayer = 4,
        sheet = "obj/letters/%s", frame_width = 9, frame_seconds = 0.5, loop = "FORWARDS",
        origin = {5, 5},
        x = 28, y = 28,
    },

    skull = {
        layer = -2, uplayer = 2,
        sheet = "obj/skull", frame_width = 9, frame_seconds = 0,
        origin = {5, 5},
    },

    turnstile = {
        layer = -2, uplayer = 2,
        sheet = "obj/turnstile", frame_width = 32, frame_seconds = 0.1, loop = "FORWARDS",
        origin = {16, 16},
        x = 78, y = 68,
    },

    -- Dollar coin
    coin = {
        layer = -4, uplayer = 4,
        image = "obj/coin",
        origin = {8, 8},
        x = 16, y = 16,
    },

    cucumber = {
        layer = -4, uplayer = 4,
        image = "obj/cucumber",
        origin = {8, 8},
        x = 16, y = 16,
    },

    --
    -- --- Screens ---
    --

    title = {
        layer = -4, uplayer = 4,
        image = "obj/title",
        origin = {90, 22},
        x = 98, y = 134,
    },

    playfield = {
        layer = -9, uplayer = 9,
        image = "obj/playfield",
        origin = {96, 120},
        x = 96, y = 120,
    },

    playfield_level1 = {
        layer = -9, uplayer = 9,
        image = "obj/playfield-level1",
        origin = {96, 120},
        x = 96, y = 120,
    },
}
