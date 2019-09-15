local component = require('component');
local sides = require('sides');

local com_helper = require('register_component');

local coms_table = com_helper.table.load('all_coms');

local coms_count = 0;
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
end

function emit.simutaneously_line(side)
    for i = 0, coms_count - 1 do
        emit.redstone(coms_array, 'on', side);
    end
    os.sleep(PULSE_INTERVAL);
    for i = 0, coms_count - 1 do
        emit.redstone(coms_array, 'off', side);
    end
end

function emit.simutaneously_all()
    for s = 0, 5 do
        if s != sides.bottom then
            for i = 0, coms_count - 1 do
                emit.redstone(coms_array, 'on', s);
            end
        end
    end
    os.sleep(PULSE_INTERVAL);
    for s = 0, 5 do
        if s != sides.bottom then
            for i = 0, coms_count - 1 do
                emit.redstone(coms_array, 'off', s);
            end
        end
    end
end

function emit.sequencial_line(side)
    for i = 0, coms_count do
        emit.redstone(coms_array, 'pulse', side);
        os.sleep(0.5);
    end
end

emit.simutaneously_line(north);
emit.simutaneously_all();
emit.sequencial_line(south);