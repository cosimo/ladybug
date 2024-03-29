function love.load()
    windowWidth, windowHeight = 192, 240

    -- game state management
    gs = require "lib.gamestate"

    -- good quality:tm: functions, snippets, etc
    helpers = require "lib.helpers"

    -- deep queue management
    deeper = require "lib.deeper"

    -- entity manager
    em = require "lib.entityman"

    -- pathfinder library
    pathfinder = require "lib.pathfinder"

    -- baton input from keyboard, joysticks
    baton = require "lib.baton"

    -- graphics helper
    push = require "lib.push"

    -- debugging console
    lovebird = require "lib.lovebird"
    lovebird.port = 4444

    -- pretty printer
    inspect = require "lib.inspect"

    -- animation library
    animation = require "lib.animation"

    -- ladybug board logic
    gameboard = require "lib.gameboard"

    -- timer blocks frame
    timeblocks = require "lib.timeblocks"

    -- collision detection library
    collision = require "lib.collision"

    -- set filter
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- The awesome font used here is a recreation of the original
    -- Universal font used in the Ladybug arcade courtesy Patrick H. Lauke
    -- https://fontstruct.com/fontstructions/show/764098/lady_bug_2
    love.graphics.setFont(love.graphics.newFont("assets/fonts/lady-bug.ttf", 8))

    -- set game canvas size
    gameWidth, gameHeight = windowWidth, windowHeight

    -- send these arguments to push
    push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
        fullscreen = false,
        resizable = true,
        pixelperfect = true
    })

    push:setBorderColor{0, 0, 0}
    love.window.setTitle("Ladybug")

    paused = false

    states = {
      diagnostics = require "states.diagnostics",
      attractmode = require "states.attractmode",
      instructions = require "states.instructions",
      playdemo = require "states.playdemo",
      playdemo2 = require "states.playdemo2",
      test = require "states.test",
    }

    gs.registerEvents()
    gs.switch(states.diagnostics)
end

function love.update(dt)
    lovebird.update()
end

function love.keypressed(k)
    -- Pressing 'ESC' will quit the game
    if k == "escape" then
        love.event.quit()
    end

    -- Pressing 'P' will toggle pause for the game, regardless of the state
    if k == "p" then
        paused = not paused
    end
end

function love.resize(w, h)
    push:resize(w, h)
end
