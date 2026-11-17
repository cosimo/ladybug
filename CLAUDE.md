# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

A remake of the 1981 Universal arcade game Lady Bug, written in Lua on LÖVE
11 (colors are 0..1 floats). There is no build step and no linter. LÖVE's
LuaJIT is the only Lua around, so the tests run under LÖVE too.

## Running

    love src            # from the repo root
    cd src && love .    # same thing

- `ESC` quits, `p` toggles a global pause from any state.
- `5` (coin) and `1`/`2` (start) are bound with baton but nothing acts on them
  yet. In `attractmode` the arrow keys or WASD move the ladybug.
- lovebird serves a live Lua console into the running game at
  http://127.0.0.1:4444. All the modules are globals, so they can be inspected
  from there.

To work on a single screen, change the `gs.switch(states.diagnostics)` call at
the end of `love.load()` in `src/main.lua`. `states/test.lua` is a pathfinder
sandbox that is only reachable this way.

Under WSLg, LÖVE sometimes hangs before opening its window, with PipeWire
errors in the output. The game has no sound, so `ALSOFT_DRIVERS=null love src`
works around it.

## Tests

    love tests              # all of them
    love tests test_maze    # only tests/test_maze.lua

`tests/main.lua` runs LÖVE without a window, and finds the game modules in
`src/`. Each `tests/test_<area>.lua` returns a table of `test_<what>`
functions that fail by raising an error, usually from `assert()`. The exit
status is 1 when any test fails. Only modules with no LÖVE calls at load time
can be tested this way, like `lib/maze.lua`, `lib/fixedstep.lua` and
`lib/gameboard.lua`.

### Frame recorder

    tools/frame-recorder/record.sh before HEAD    # or any git revision
    tools/frame-recorder/record.sh after          # the working tree
    python3 tools/frame-recorder/compare.py before after

`record.sh` runs the game in a window at a fixed 1/60s per frame, and writes
the md5 of each of 4200 frames (about 70s, the demo up to `playdemo2`) to
`tools/frame-recorder/runs/<label>/`. Runs of the same code give the same
hashes, so `compare.py` shows which frames a change affects, and none for a
pure refactor. The `RECORD_*` settings in `tools/frame-recorder/main.lua`
dump frames as PNG, press keys or run Lua at given frames, log a probe
expression, and track accidental globals. The recorder replaces `love.run`,
so it doesn't exercise the game's own loop.

## Architecture

### Globals

`love.load()` in `src/main.lua` requires most libraries into globals: `gs`,
`helpers`, `deeper`, `em`, `pathfinder`, `baton`, `push`, `lovebird`,
`inspect`, `animation`, `gameboard`, `timeblocks`, `collision`. Also `states`,
`paused`, `windowWidth`/`windowHeight`. Modules, states and objects reach each
other through these globals. The require order matters, `entityman` calls
`deeper.init()` at load time and `deeper` uses `helpers`.

`lib/maze.lua` and `lib/fixedstep.lua` are the exception: no globals and no
LÖVE calls, required with `local maze = require "lib.maze"` where needed.

### Game loop

`love.run` in `src/main.lua` runs the updates at a fixed 1/60s step, like the
arcade's logic runs once per 60Hz video frame, whatever the display refresh
rate. `fixedstep.updates_due()` says how many updates are due for the time
that passed. Everything per update (pathfinder speeds, per pixel collisions,
counters) is effectively per 1/60s, and `dt` is always 1/60. WSLg ignores
vsync, and the loop draws about 340 frames per second there.

### Screen

push scales a 192x240 virtual canvas, pixel perfect, nearest filtering. Every
coordinate in the code is in that space. Each state's `draw()` is wrapped in
`push:start()` / `push:finish()`. The font is `assets/fonts/lady-bug.ttf` at
size 8.

### States

`lib/gamestate.lua` is hump.gamestate, modified so that `registerEvents()`
skips the state `update` while `paused` is set. Each `src/states/*.lua` returns
a table with `init()` (runs once), `enter()` (runs on every switch, clears `em`
and `pathfinder` and rebuilds the screen), `update(self, dt)` and `draw()`. A
new state also needs an entry in the `states` table in `main.lua`.

States chain on timers through `st.next_state`:

    diagnostics -> attractmode -> instructions -> playdemo -> playdemo2

`playdemo` is the intro screen of the play demo. `playdemo2` is the CPU play on
the level 1 board, and it only moves on when `is_player_dead` is set, which
nothing does yet. `enter()` must reset everything the screen uses, re-entering
a state is expected to replay it exactly.

### Entities

Every entity is defined in the table in `src/obj/definitions.lua`: draw layer
(lowest drawn first), update layer, sprite sheet or static image, frame width
and timing, origin and start position. `em.init(name, x, y)` builds a new
entity from it, `em.init_with_type("letter", "s", x, y)` fills in the `%s` of
the letter sheet.

Every sprite is anchored on its center: `x, y` is the middle of the sprite.
The 9 pixel items (hearts, letters, skulls) have their origin at 5, 5, one
pixel off center, because the arcade draws them one pixel up and left of the
dots. `em.center(entity)` returns the exact middle, half a pixel off `x, y`
for odd sized sprites.

Setting `delete = true` on an entity removes it after the next `em.draw()`.
`em.update()` advances the animations, `em.draw()` draws by layer.

### Animation

`lib/animation.lua` cuts a horizontal strip from `assets/<path>.png` into
frames. `animation.image()` loads each image once. Each entity still gets its
own template (`anim.temp`), because states freeze single sprites with
`anim.temp.speed = 0` or `anim.temp.loop = animation.loop.NONE`, then pick
`anim.frame`. Passing `loop.NONE` to `newtemplate()` builds no frames at all,
so it's only ever set afterwards.

### Gameboard and maze

`lib/gameboard.lua` holds the board of the current level:

- `grid[x][y]` is what sits on each of the 11x11 cells, one of the board
  constants (`EMPTY`, `DOT`, `SKULL`, ...). `entities[x][y]` is the sprite
  drawn for it, nil for an empty cell. `clear_cell()` empties both.
- `cell_center(x, y)` is where any sprite goes to sit on a cell,
  `board_xy(screen_x, screen_y)` is its inverse, and `gate_center(x, y)` is
  the pivot of turnstile (x, y).
- `maze` is the parsed level maze, `gate_entities` the turnstile sprites.
- The HUD drawing (SPECIAL/EXTRA letters, multipliers, score, credits) and
  `player_score`. `all_unlit("EXTRA")` builds a table of unlit HUD letters.

`random_initialize()` currently hardcodes the play demo layout.

`lib/maze.lua` parses a maze from the ASCII art in `src/levels/level1.lua`
(walls read from the playfield image) and answers who can move where.
`maze.blocker()` returns `"border"`, `"wall"`, `"turnstile"` or nil,
`maze.can_move()` lets only who can push (the ladybug) through turnstile arms,
and `maze.push()` returns a new maze with the pushed turnstile turned. The
demo doesn't push turnstiles yet. `maze.snap_to_lane()` is the lane snapping
for player movement, used by the attract mode.

### Pathfinder

`lib/pathfinder.lua` drives the scripted movement of the demo. A path is a list
of steps:

    {end_time, action, speed, {stop_x, stop_y}, on_step_end}

`action` is one of the glyphs `←` `→` `↑` `↓`, `⚡` (teleport, x and y in
slots 3 and 4) or `🛑` (wait). A step ends when `end_time` passes, or when the
entity reaches the stop coordinate. `end_time` counts seconds since the path
started, not since the step started. Paths restart from the first step when
they run out, and are dropped once their entity is deleted. `speed` is in
pixels per update, which the fixed step makes pixels per 1/60s.

The optional move callback gets `(entity, x, y, prev_x, prev_y)` on every pixel
of movement. `playdemo2` passes `collision.detect`, which eats a dot when the
centers of the ladybug and the dot are within half a pixel, for 10 points.
Everything else on the board is ignored for now.

### Timeblocks

`lib/timeblocks.lua` draws the 92 green timer blocks around the maze border.
A lap takes `LAP_SECONDS` (14.6, measured on the MAME capture), and
`timeblocks.laps()` counts completed laps. The beetle leaves the center on the
first one. Call `timeblocks.render()` after `em.draw()`, or the playfield
sprite covers the blocks.

### Third party code

Vendored and best left alone: `gamestate` (hump, with the pause change above),
`baton` (input), `push` (scaling), `lovebird`, `inspect`, `deeper` (multi queue
version of deep). `entityman`, `animation` and `helpers` are adapted from
firekatana. `gameboard`, `maze`, `fixedstep`, `pathfinder`, `timeblocks` and
`collision` are this project's own.

## Reference material

- `docs/video-capture/`: a MAME capture of the original game, 30 fps. Screen
  positions and timings are matched against it, for example with ffmpeg to
  pull frames. The board maps to the capture as video x = 50 + 2 x, video
  y = 10 + 2 y. `demo.gif` is the progress gif shown in `README.md`.
- `docs/sprite-sheets/`: the source sprite sheets, from spriters-resource.
- `docs/universal-font/`: the arcade font recreation used in game.

## Commits

There's no ticket tracker for this project, so commit subjects skip the ticket
key: `<area>: <what changed>`, as in `lib/pathfinder: drop the paths of
deleted entities`. Older history uses plain sentences, like `Added initial
enemy movement for play demo`.
