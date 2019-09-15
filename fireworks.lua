local component = require('component');
local sides = require('sides');
local thread = require('thread');

require('./register_component');

local coms_table = table.load('all_coms');

local coms_count = 0;
-- 0 is perserved for simutaneously dispenser
local coms_array = {};

local PULSE_INTERVAL = 0.1;

for k, v in pairs(coms_table) do
    coms_array[v] = k;
    coms_count = coms_count + 1;
end

local emit = {};

-- mode can be on, off, pulse
function emit.redstone(idx, mode, side)
    local com = coms_array[idx];
    local proxy = component.proxy(com);
    if mode == 'on' then
        proxy.setOutput(side, 1);
    elseif mode == 'off' then
        proxy.setOutput(side, 0);
    else
        proxy.setOutput(side, 1);
        os.sleep(PULSE_INTERVAL);
        proxy.setOutput(side, 0);
    end
end

function emit.randomly_line(side)
    local thread_collection = {};
    for i = 1, coms_count - 1 do
        local t = thread.create(emit.redstone, i, 'on', side);
        thread_collection[i + 1] = t;
        -- emit.redstone(i, 'on', side);
    end
    thread.waitForAll(thread_collection);
    os.sleep(PULSE_INTERVAL);
    thread_collection = {};
    for i = 1, coms_count - 1 do
        local t = thread.create(emit.redstone, i, 'off', side);
        thread_collection[i + 1] = t;
        -- emit.redstone(i, 'off', side);
    end
    thread.waitForAll(thread_collection);
end

function emit.randomly_all()
    local thread_collection = {};
    local j = 1;
    for s = 0, 5 do
        if s ~= sides.bottom then
            for i = 1, coms_count - 1 do
                local t = thread.create(emit.redstone, i, 'on', s);
                thread_collection[j] = t;
                -- emit.redstone(i, 'on', s);
                j = j + 1;
            end
        end
    end
    thread.waitForAll(thread_collection);
    os.sleep(PULSE_INTERVAL);
    thread_collection = {};
    j = 1;
    for s = 0, 5 do
        if s ~= sides.bottom then
            for i = 1, coms_count - 1 do
                local t = thread.create(emit.redstone, i, 'off', s);
                thread_collection[j] = t;
                j = j + 1;
                -- emit.redstone(i, 'off', s);
            end
        end
    end
    thread.waitForAll(thread_collection);
end

function emit.sequencial_line(side)
    for i = 1, coms_count - 1 do
        emit.redstone(i, 'pulse', side);
        os.sleep(0.5);
    end
end

function emit.reverse_sequencial_line(side)
    for i = coms_count - 1, 1 do
        emit.redstone(i, 'pulse', side);
        os.sleep(0.5);
    end
end

-- simutenously fire all dispenser within one unit
function emit.randomly_unit(unit_idx)
    local thread_collection = {};
    local j = 1;
    for s = 0, 5 do
        if s ~= sides.bottom then
            local t = thread.create(emit.redstone, unit_idx, 'on', s);
            thread_collection[j] = t;
            -- emit.redstone(unit_idx, 'on', s);
        end
    end
    thread.waitForAll(thread_collection);
    os.sleep(PULSE_INTERVAL);
    local j = 1;
    for s = 0, 5 do
        if s ~= sides.bottom then
            local t = thread.create(emit.redstone, unit_idx, 'off', s);
            thread_collection[j] = t;
            -- emit.redstone(unit_idx, 'off', s);
        end
    end
    thread.waitForAll(thread_collection);
end

function emit.sequencial_unit()
    for i = 1, coms_count - 1 do
        emit.simutaneously_unit(i);
    end
end

function emit.reverse_sequencial_unit()
    for i = coms_count - 1, 1 do
        emit.simutaneously_unit(i);
    end
end

function emit.smiutaneously_line(side)
    -- 0 is the simutaneous line
    emit.redstone(0, 'pulse', side);
end