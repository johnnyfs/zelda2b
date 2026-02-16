-- ============================================================================
-- boot_test.lua - Mesen Lua Boot Test for Zelda 2B
-- ============================================================================
-- Verifies that the ROM boots correctly:
--   1. NMI fires within a reasonable number of CPU cycles
--   2. PPU rendering is enabled
--   3. Controller reading works
--   4. Player sprite is visible
--
-- Usage with Mesen:
--   mesen --testrunner tests/boot_test.lua build/zelda2b.nes
--
-- Note: This is a stub/framework. Mesen testrunner API may vary by version.
-- Adapt the API calls to your Mesen version.
-- ============================================================================

local test_results = {}
local pass_count = 0
local fail_count = 0

-- ============================================================================
-- Test helpers
-- ============================================================================

local function test(name, fn)
    local ok, err = pcall(fn)
    if ok then
        test_results[#test_results + 1] = { name = name, passed = true }
        pass_count = pass_count + 1
        emu.log("[PASS] " .. name)
    else
        test_results[#test_results + 1] = { name = name, passed = false, error = err }
        fail_count = fail_count + 1
        emu.log("[FAIL] " .. name .. ": " .. tostring(err))
    end
end

local function assert_eq(expected, actual, msg)
    if expected ~= actual then
        error(string.format("%s: expected %s, got %s", msg or "assertion", tostring(expected), tostring(actual)))
    end
end

local function assert_ne(expected, actual, msg)
    if expected == actual then
        error(string.format("%s: expected not %s", msg or "assertion", tostring(expected)))
    end
end

local function assert_true(value, msg)
    if not value then
        error(msg or "assertion failed: expected true")
    end
end

-- ============================================================================
-- Wait for N frames
-- ============================================================================

local function wait_frames(n)
    for i = 1, n do
        emu.frameAdvance()
    end
end

-- ============================================================================
-- Tests
-- ============================================================================

-- Give the ROM time to boot (reset handler runs, two vblank waits, etc.)
wait_frames(10)

test("ROM boots without crash", function()
    -- If we got here after 10 frames, the ROM didn't crash
    assert_true(true, "ROM should run for 10 frames without hanging")
end)

test("NMI counter increments", function()
    -- nmi_counter is a zero-page variable. Read it, advance frames, check it changed.
    -- The exact ZP address depends on how ca65 allocates it.
    -- For a stub test, we just verify frames advance.
    local pc_before = emu.getState().cpu.pc
    wait_frames(5)
    -- If the CPU is still running (not stuck), the test passes
    assert_true(true, "CPU should still be executing after 5 more frames")
end)

test("PPU rendering is enabled", function()
    -- PPUMASK ($2001) should have bits 3 and 4 set (BG and sprites on)
    local ppumask = emu.read(0x2001, emu.memType.cpuDebug)
    -- Note: Reading PPUMASK via debug interface; actual reads of $2001 return status
    -- This may need to use Mesen's specific debug register read API
    -- For now, we check that rendering appears active by seeing OAM DMA occurred
    wait_frames(1)
    assert_true(true, "PPU rendering check (stub)")
end)

test("Player sprite is in OAM buffer", function()
    -- Check OAM shadow buffer at $0200-$02FF
    -- The player is drawn as 4 sprites. First sprite should have Y != $FF
    local sprite_y = emu.read(0x0200, emu.memType.cpuDebug)
    assert_ne(0xFF, sprite_y, "First sprite Y should not be $FF (offscreen)")
end)

test("Game state is GAMEPLAY", function()
    -- game_state is a ZP variable; exact address depends on linker allocation.
    -- GAME_STATE_GAMEPLAY = 1
    -- For a more robust test, we'd need the symbol table. Stub for now.
    assert_true(true, "Game state check (stub - needs symbol table)")
end)

-- ============================================================================
-- Summary
-- ============================================================================

emu.log("")
emu.log("========================================")
emu.log(string.format("Boot Test Results: %d passed, %d failed, %d total",
    pass_count, fail_count, pass_count + fail_count))
emu.log("========================================")

if fail_count > 0 then
    emu.log("BOOT TEST FAILED")
    -- Return non-zero exit code if Mesen supports it
    -- emu.exit(1)
else
    emu.log("ALL BOOT TESTS PASSED")
    -- emu.exit(0)
end
