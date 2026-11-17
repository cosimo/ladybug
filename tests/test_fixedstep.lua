--
-- Fixed step: how many 1/60s game updates each displayed frame runs
--

local fixedstep = require "lib.fixedstep"

local STEP = fixedstep.UPDATE_SECONDS

-- Runs frames of the given lengths in seconds through updates_due(), as
-- love.run does, and returns the number of updates of each frame
local function updates_of_frames(frame_seconds)
    local update_counts = {}
    local pending_seconds = 0

    for _, seconds in ipairs(frame_seconds) do
        local update_count
        update_count, pending_seconds = fixedstep.updates_due(pending_seconds + seconds)
        table.insert(update_counts, update_count)
    end

    return update_counts
end

-- Returns the lengths of the frames shown in total_seconds at a refresh rate
local function frames_at(frames_per_second, total_seconds)
    local frame_seconds = {}
    for _ = 1, math.floor(frames_per_second * total_seconds) do
        table.insert(frame_seconds, 1 / frames_per_second)
    end
    return frame_seconds
end

local function sum(numbers)
    local total = 0
    for _, number in ipairs(numbers) do
        total = total + number
    end
    return total
end

local tests = {}

function tests.test_no_update_until_a_step_has_passed()
    local update_count, pending_seconds = fixedstep.updates_due(STEP / 4)

    assert(update_count == 0, "a quarter step ran " .. update_count .. " updates")
    assert(pending_seconds == STEP / 4, "the quarter step was lost, " .. pending_seconds .. " left")
end

function tests.test_one_update_per_step()
    local update_count = fixedstep.updates_due(STEP)

    assert(update_count == 1, "one step ran " .. update_count .. " updates")
end

-- The demo ran almost 6x too fast at 343 fps, with one update per frame
function tests.test_60_updates_per_second_at_any_refresh_rate()
    for _, frames_per_second in ipairs({30, 60, 75, 144, 343}) do
        local update_count = sum(updates_of_frames(frames_at(frames_per_second, 10)))

        local is_60_per_second = math.abs(update_count - 600) <= 1
        assert(is_60_per_second, frames_per_second .. " fps ran " .. update_count .. " updates in 10s")
    end
end

-- On a vsynced 60Hz display each frame lasts a little more or less than
-- 1/60s. Without some slack, a slightly short frame runs no update and the
-- next one two, and the sprites stutter.
function tests.test_60hz_jitter_runs_one_update_every_frame()
    local jittery_frames = {}
    for _ = 1, 100 do
        table.insert(jittery_frames, STEP * 0.98)
        table.insert(jittery_frames, STEP * 1.02)
    end

    local update_counts = updates_of_frames(jittery_frames)

    for frame, update_count in ipairs(update_counts) do
        assert(update_count == 1, "frame " .. frame .. " ran " .. update_count .. " updates")
    end
end

-- After a stall, like a window being dragged, the game shouldn't fast
-- forward through all the time it missed
function tests.test_a_long_stall_drops_the_missed_time()
    local update_count, pending_seconds = fixedstep.updates_due(2)

    assert(update_count == fixedstep.MAX_UPDATES, "a 2s stall ran " .. update_count .. " updates")
    assert(pending_seconds == 0, pending_seconds .. "s of the stall still pending")
end

return tests
