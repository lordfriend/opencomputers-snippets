local sides = require('sides');
require('./fireworks');

local sl = emit.simutaneously_line;
local rl = emit.simutaneously_line;
local r = emit.redstone;
local rsl = emit.reverse_sequencial_line;
local su = emit.sequencial_unit;
local rsu = emit.reverse_sequencial_unit;

--[[
The following number represents the index of redstone I/O

   [*     *     *     *] = 0
    
    *     *     *     *
   *1*   *2*   *3*   *4*
    *     *     *     *

    one unit has north top, west, east, south sides.

    0 unit also has top, west, east, south sides
]]--

local function stage1()
    -- we assume we have 7 I/O, 1 simutaneously line I/O
    emit.simutaneously_line(sides.north); -- put 3 big ball into No. 2, 4, 6
    emit.simutaneously_line(sides.south); -- put 1 small ball into No.1 ~ 7 (2 height)
    os.sleep(2);
end
local function stage2()
    for i = 1, 3 do
        emit.randomly_line(sides.east); -- put 3 small ball into No.1 ~ 7 east with 3 stack (1, 2, 3 height);
    end
    os.sleep(2);
    for i = 1, 3 do
        emit.redstone(4, 'pulse', sides.west); -- put 1 big ball (trail) into No. 4 east with 3 stack.
        emit.simutaneously_line(sides.south); -- small ball 2 height
        os.sleep(0.2);
        emit.simutaneously_line(side.west); -- small ball 1 height
        os.sleep(0.5);
    end

    os.sleep(1.5);

    for i = 1, 5 do
        emit.sequencial_line(sides.north); -- big ball with flicker
        os.sleep(0.5);
        emit.sequencial_line(sides.west); -- big ball with trail
        os.sleep(0.5);
    end

    for i = 1, 5 do
        emit.reverse_sequencial_line(sides.north); -- big ball with flicker
        os.sleep(0.5);
        emit.reverse_sequencial_line(sides.west); -- big ball with trail
    end
    os.sleep(1.5);

    for i = 1, 5 do
        su();
        os.sleep(0.5);
        rsu();
    end;
end

stage1();
stage2();

function stage3()
    for i = 1, 10 do
        stage1();
        stage2();
    end
end