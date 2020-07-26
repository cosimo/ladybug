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

    entities = {}

    states = {
      diagnostics = require "states.diagnostics",
      attractmode = require "states.attractmode",
    }

    gs.registerEvents()
    -- gs.switch(states.diagnostics)
    gs.switch(states.attractmode)
end

function love.update(dt)
    lovebird.update()
end

function love.keypressed(k)
    if k == "escape" then
        love.event.quit()
    end
end

function love.resize(w, h)
    push:resize(w, h)
end
