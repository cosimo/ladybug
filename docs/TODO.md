# TODO

Last updated: 2026-11-17 Cosimo

- [collision, gameboard] The ladybug walks over everything but the dots.
  Skulls and enemies should kill it, hearts and letters should give bonus
  points and light a multiplier or a SPECIAL or EXTRA letter. There's a TODO
  in `collision.between()`.
- [playdemo2, pathfinder, maze] The demo never pushes a turnstile, the
  arcade's does. `maze.push()` works already. The ladybug crossing an arm
  would need to call it, and turn the sprite in `gameboard.gate_entities`.
- [attractmode] `st.input:get("move")` is always true. baton returns the x
  and y of a pair, and 0 is true in Lua. It's harmless, the `down()` checks
  below it decide what moves, but the lane snapping runs on every update.
- [timeblocks] The green count in the MAME capture stops twice for 0.8s,
  around 57.7s and 62.4s into `docs/video-capture/ladybug.mkv`, and I don't
  know why (**? to be validated**). `LAP_SECONDS` (14.6) includes both
  pauses, so the timer here fills at a steady pace, a bit slower than the
  arcade between the pauses, and ends the lap at the same time.
