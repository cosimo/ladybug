--
-- Test runner
--
-- Run from anywhere with:
--
--     love tests
--
-- Each tests/test_<area>.lua returns a table of test functions, named
-- test_<what it proves>. A test fails by raising an error, usually from
-- assert(). The runner prints one line per test, and exits with status 1
-- when any test fails.
--
-- Pass test file names to run only those: love tests test_maze
--

-- Lets the tests require the game modules, as in require "lib.maze"
local source_dir = love.filesystem.getSource()
package.path = source_dir .. "/../src/?.lua;" .. package.path

-- Returns the test module names to run, all of them unless named on the
-- command line
local function test_modules(args)
    if #args > 0 then
        return args
    end

    local names = {}
    for _, filename in ipairs(love.filesystem.getDirectoryItems("")) do
        local name = filename:match("^(test_.+)%.lua$")
        if name then
            table.insert(names, name)
        end
    end

    table.sort(names)
    return names
end

-- Returns the names of the test functions in a module, in a stable order
local function test_names(tests)
    local names = {}
    for name in pairs(tests) do
        table.insert(names, name)
    end

    table.sort(names)
    return names
end

-- Runs one test, and returns its error message, or nil when it passes
local function run_test(test)
    local ok, err = xpcall(test, debug.traceback)
    if ok then
        return nil
    end
    return err
end

function love.load(args)
    local passed, failed = 0, 0

    for _, module_name in ipairs(test_modules(args)) do
        local loaded, tests = xpcall(require, debug.traceback, module_name)

        if not loaded then
            failed = failed + 1
            io.write("FAIL  ", module_name, " doesn't load\n", tests, "\n")
            tests = {}
        end

        for _, name in ipairs(test_names(tests)) do
            local err = run_test(tests[name])

            if err == nil then
                passed = passed + 1
                io.write("ok    ", module_name, ".", name, "\n")
            else
                failed = failed + 1
                io.write("FAIL  ", module_name, ".", name, "\n", err, "\n")
            end
        end
    end

    io.write(string.format("\n%d passed, %d failed\n", passed, failed))
    io.flush()
    love.event.quit(failed > 0 and 1 or 0)
end
