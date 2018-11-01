local sides = require("sides");
local event = require("event");
local keyboard = require("keyboard");
local component = require("component");
local arc = component.ie_arc_furnace;
local rs = component.redstone;

local additive_side = sides.north;
local input_side = sides.east;

local WAIT_TIME = 5;

-- signal strength for additive source
local additive_signal = {};
additive_signal.on = 1;
additive_signal.off = 0;
-- signal strength for input source
local input_signal = {};
input_signal.on = 0;
input_signal.off = 1;


local threshold = 16;
local isRunning = true;

local function isAdditiveSlotFull()
    local total = 64 * 4;
    local current = 0;
    for i = 1, 4 do
        local info = arc.getAdditiveStack(i);
        current = current + info.size;
    end
    return total - current < threshold;
end

local function isInputSlotFull()
    local total = 64 * 12;
    local current = 0;
    for i = 1, 12 do
        local info = arc.getInputStack(i);
        if info.size ~= nil then
            current = current + info.size;
        end
    end
    return total - current < threshold;
end

local function handleEvent(event_name, address, char, code, playerName)
    if code == keyboard.keys.q then
        isRunning = false;
    end
end

while isRunning do
    if isAdditiveSlotFull() then
        rs.setOutput(additive_side, additive_signal.off);
    else
        rs.setOutput(additive_side, additive_signal.on);
    end
    if isInputSlotFull() then
        rs.setOutput(input_side, input_signal.off);
    else
        rs.setOutput(input_side, input_signal.on);
    end
    handleEvent(event.pull(WAIT_TIME, "key_up"));
end