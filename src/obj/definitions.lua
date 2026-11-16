--
-- Entity definitions
--
-- em.init(name, x, y) builds a new entity from the definition with that
-- name. An entity is either animated, with its frames cut from a horizontal
-- strip in assets/<sheet>.png, or a static image drawn from its top left
-- corner.
--
--   layer          draw order, lowest first
--   uplayer        update order, lowest first
--   sheet          sprite sheet of an animated entity, under assets/
--   frame_width    width of one frame in the sheet, in pixels
--   frame_seconds  how long each frame shows, 0 to never change frame
--   loop           "FORWARDS", or by default "PENDULUM" (forwards then back)
--   origin         the pixel of the frame that is drawn at x, y
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
        x = 16, y = 160,
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
        origin = {10, 10},
    },

    --
    -- --- Board items ---
    --

    dot = {
        layer = -5, uplayer = 5,
        sheet = "obj/dot", frame_width = 3, frame_seconds = 0,
        origin = {3, 3},
    },

    heart = {
        layer = -4, uplayer = 4,
        sheet = "obj/heart", frame_width = 9, frame_seconds = 0.5, loop = "FORWARDS",
        origin = {9, 9},
    },

    letter = {
        layer = -4, uplayer = 4,
        sheet = "obj/letters/%s", frame_width = 9, frame_seconds = 0.5, loop = "FORWARDS",
        origin = {9, 9},
        x = 32, y = 32,
    },

    skull = {
        layer = -2, uplayer = 2,
        sheet = "obj/skull", frame_width = 9, frame_seconds = 0,
        origin = {9, 9},
    },

    turnstile = {
        layer = -2, uplayer = 2,
        sheet = "obj/turnstile", frame_width = 32, frame_seconds = 0.1, loop = "FORWARDS",
        origin = {8, 8},
        x = 70, y = 60,
    },

    -- Dollar coin
    coin = {
        layer = -4, uplayer = 4,
        image = "obj/coin",
        x = 8, y = 8,
    },

    cucumber = {
        layer = -4, uplayer = 4,
        image = "obj/cucumber",
        x = 8, y = 8,
    },

    --
    -- --- Screens ---
    --

    title = {
        layer = -4, uplayer = 4,
        image = "obj/title",
        x = 8, y = 112,
    },

    playfield = {
        layer = -9, uplayer = 9,
        image = "obj/playfield",
    },

    playfield_level1 = {
        layer = -9, uplayer = 9,
        image = "obj/playfield-level1",
    },
}
