--
-- Level 1 maze
--
-- Walls read from assets/obj/playfield-level1.png, sampling the pink wall
-- pixels in the middle of every edge between two cells. lib/maze.lua
-- explains the notation. H and V are the pivots of the turnstiles at the
-- start of the level, horizontal or vertical, and = and : draw their arms.
--

return [[
+---+---+---+---+---+---+---+---+---+---+---+
|                                           |
+   +===H===+   +---+   +---+   +===H===+   +
|   |       |   :   |   |   :   |       |   |
+   +---+   +   V   +   +   V   +   +---+   +
|   :           :           :           :   |
+   V   +===H===+---+   +---+===H===+   V   +
|   :   |           |   |           |   :   |
+   +---+   +===H===+   +===H===+   +---+   +
|           |                   |           |
+   +---+   +   +   +   +   +   +   +---+   +
|       |   :   |   |   |   |   :   |       |
+   +   +   V   +   +---+   +   V   +   +   +
|   |   :   :   :           :   :   :   |   |
+   +   V   +   V   +   +   V   +   V   +   +
|   |   :   |   :   |   |   :   |   :   |   |
+   +---+   +   +---+   +---+   +   +---+   +
|                                           |
+   +---+---+===H===+   +===H===+---+---+   +
|   |               |   |               |   |
+   +===H===+---+   +   +   +---+===H===+   +
|                                           |
+---+---+---+---+---+---+---+---+---+---+---+
]]
