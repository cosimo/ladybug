--
-- Frame recorder
--
-- Runs the game at a fixed 1/60s step per frame, and writes the md5 of every
-- frame's pixels to hashes.txt. Two runs of the same code give the same
-- hashes, so comparing the hashes of two revisions shows which frames a
-- change affects, and none at all for a pure refactor.
--
-- record.sh sets this up: it copies the game into a run directory, renames
-- the game's main.lua to game_main.lua, and puts this file in its place.
--
-- Settings, from the environment:
--
--   RECORD_OUT           output directory, absolute (record.sh sets it)
--   RECORD_FRAMES        number of frames to run, 4200 by default, about
--                        the whole demo sequence until playdemo2
--   RECORD_DUMP          frames to save as PNG and raw RGBA: "1200,1201"
--   RECORD_KEYS          keys to press: "500:p,600:p" presses p at frames
--                        500 and 600, one key per frame at most
--   RECORD_AT            Lua code to run before the update of a frame:
--                        "3000=gs.switch(states.playdemo2)", several of them
--                        separated by ";", so the code itself can't use ";"
--   RECORD_PROBE         a Lua expression logged to probe.txt, as in
--                        "#pathfinder.paths"
--   RECORD_PROBE_EVERY   log the probe every this many frames, 60 by default
--   RECORD_GLOBALS       "1" logs to globals.txt the globals created by
--                        love.load(), then every global set or undefined
--                        global read while the game runs
--
-- RECORD_KEYS only calls love.keypressed, so it reaches the keys handled in
-- main.lua (p, escape) but not baton, which polls the keyboard state.
--

-- No lovebird server, it would clash on port 4444 with a game already
-- running
package.loaded["lib.lovebird"] = { update = function() end }

local globals_before_game = {}
for name in pairs(_G) do
    globals_before_game[name] = true
end

love.filesystem.load("game_main.lua")()

-- Nobody clicks away the error screen of a recording, and it would wait
-- forever. Print the error and quit with status 1 instead.
function love.errorhandler(message)
    print(debug.traceback("Error: " .. tostring(message), 2))
    return nil
end

-- One update per frame, as on a 60Hz display
local FRAME_SECONDS = 1 / 60

local out_dir = assert(os.getenv("RECORD_OUT"), "RECORD_OUT is not set, run this through record.sh")
local max_frames = tonumber(os.getenv("RECORD_FRAMES") or "4200")
local track_globals = os.getenv("RECORD_GLOBALS") == "1"

local key_presses = {}
for frame_text, key in (os.getenv("RECORD_KEYS") or ""):gmatch("(%d+):(%w+)") do
    key_presses[tonumber(frame_text)] = key
end

local probe_source = os.getenv("RECORD_PROBE")
local probe_every = tonumber(os.getenv("RECORD_PROBE_EVERY") or "60")
local probe_fn = probe_source and assert(loadstring("return " .. probe_source))

local run_at = {}
for frame_text, code in (os.getenv("RECORD_AT") or ""):gmatch("(%d+)=([^;]+)") do
    run_at[tonumber(frame_text)] = assert(loadstring(code))
end

local dump_frames = {}
for frame_text in (os.getenv("RECORD_DUMP") or ""):gmatch("%d+") do
    dump_frames[tonumber(frame_text)] = true
end

local function write_file(path, data)
    local fh = assert(io.open(path, "wb"))
    fh:write(data)
    fh:close()
end

-- Logs every global set, and every read of an undefined global, once for
-- each place in the code that does it
local function watch_globals(log_fh)
    local seen = {}

    local function report(kind, name)
        -- Level 1 is report(), 2 the metamethod, 3 the code touching _G
        local info = debug.getinfo(3, "Sl")
        local where = info and (info.short_src .. ":" .. (info.currentline or "?")) or "?"
        local entry = kind .. " " .. tostring(name) .. " " .. where

        if not seen[entry] then
            seen[entry] = true
            log_fh:write(entry, "\n")
            log_fh:flush()
        end
    end

    setmetatable(_G, {
        __newindex = function(t, name, value)
            report("SET", name)
            rawset(t, name, value)
        end,
        __index = function(_, name)
            report("GET-UNDEFINED", name)
            return nil
        end,
    })
end

-- Hashes the pixels of the frame just drawn, and saves the frame when it is
-- one of those to dump. The screenshot is taken at the next present().
local function capture_frame(frame, hashes_fh)
    love.graphics.captureScreenshot(function(image_data)
        local raw_pixels = image_data:getString()
        local digest = love.data.encode("string", "hex", love.data.hash("md5", raw_pixels))
        hashes_fh:write(frame, " ", digest, "\n")

        if dump_frames[frame] then
            local base = string.format("%s/frame-%05d", out_dir, frame)
            write_file(base .. ".rgba", raw_pixels)
            write_file(base .. ".png", image_data:encode("png"):getString())
        end
    end)
end

function love.run()
    love.load(love.arg.parseGameArguments(arg), arg)
    love.window.setVSync(0)

    local hashes_fh = assert(io.open(out_dir .. "/hashes.txt", "w"))
    local probe_fh = assert(io.open(out_dir .. "/probe.txt", "w"))
    local globals_fh = nil

    if track_globals then
        globals_fh = assert(io.open(out_dir .. "/globals.txt", "w"))
        for name in pairs(_G) do
            if not globals_before_game[name] then
                globals_fh:write("LOADED ", name, "\n")
            end
        end
        watch_globals(globals_fh)
    end

    local frame = 0

    return function()
        love.event.pump()
        for name, a, b, c, d, e, f in love.event.poll() do
            if name == "quit" then
                return 0
            end
            love.handlers[name](a, b, c, d, e, f)
        end

        frame = frame + 1

        if key_presses[frame] then
            love.handlers.keypressed(key_presses[frame], key_presses[frame], false)
        end

        if run_at[frame] then
            run_at[frame]()
        end

        love.update(FRAME_SECONDS)

        if probe_fn and frame % probe_every == 0 then
            local _, probe_value = pcall(probe_fn)
            probe_fh:write(frame, " ", tostring(probe_value), "\n")
        end

        love.graphics.origin()
        love.graphics.clear(love.graphics.getBackgroundColor())
        love.draw()
        capture_frame(frame, hashes_fh)
        love.graphics.present()

        if frame < max_frames then
            return nil
        end

        hashes_fh:close()
        probe_fh:close()
        if globals_fh then
            globals_fh:close()
        end
        return 0
    end
end
