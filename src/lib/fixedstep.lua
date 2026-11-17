--
-- Fixed step
--
-- The arcade runs its game logic once per 60Hz video frame, and so does the
-- game here: sprites move whole pixels per update, the pathfinder speeds are
-- in pixels per update and the collision checks run on every pixel moved.
-- love.run in main.lua asks updates_due() how many 1/60s updates to run for
-- the real time that passed, whatever the refresh rate of the display.
--
-- With one update per displayed frame, the game only runs at the right
-- speed on a vsynced 60Hz display. WSLg ignores vsync, and there the demo
-- ran at 343 fps, almost 6 times too fast.
--
-- No LÖVE calls here, so tests/ can run it.
--

local fixedstep = {
    -- Game time of one update, one frame of the arcade video
    UPDATE_SECONDS = 1 / 60,

    -- After a stall, like a window being dragged, catch up with at most
    -- this many updates and drop the rest of the missed time
    MAX_UPDATES = 4,
}

-- An update runs up to this fraction of a step early. On a vsynced 60Hz
-- display a frame lasts a bit more or less than 1/60s, and without the slack
-- a slightly short frame would run no update and the next one two. The time
-- borrowed comes back as negative pending time, so the rate stays at 60
-- updates per second.
local EARLY_FRACTION = 0.1

-- Returns how many updates are due for pending_seconds of real time, and the
-- seconds left pending for the next frame
function fixedstep.updates_due(pending_seconds)
    local step = fixedstep.UPDATE_SECONDS
    local update_count = math.floor(pending_seconds / step + EARLY_FRACTION)

    if update_count > fixedstep.MAX_UPDATES then
        return fixedstep.MAX_UPDATES, 0
    end

    return update_count, pending_seconds - update_count * step
end

return fixedstep
