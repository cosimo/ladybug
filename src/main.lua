function love.load()
    windowWidth, windowHeight = 192, 240
    
    -- graphics helper
    push = require "lib.push"

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
    
    push:setBorderColor{0,0,0}
    love.window.setTitle("Ladybug")

    paused = false
end

function love.draw()
    love.graphics.print('LADYBUG', 20, 50)
end

function love.update()
end

function love.keypressed(k)    
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
end

function love.resize(w, h)
    push:resize(w, h)
end
