--
-- Test runner configuration
--
-- The tests exercise plain Lua modules, so the runner needs no window,
-- graphics or sound.
--

function love.conf(t)
    t.identity = "ladybug-tests"
    t.window = false
    t.modules.window = false
    t.modules.graphics = false
    t.modules.audio = false
    t.modules.sound = false
    t.modules.joystick = false
end
