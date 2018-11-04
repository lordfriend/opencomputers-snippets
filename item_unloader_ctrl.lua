local component = require("component");
local event = require("event");
local keyboard = require("keyboard");
local sides = require("sides");
local proxy = require("proxy");
-- 0d411ba is redstone_card
local redstone_io_addr = {
    "1": component.get("63b63a"), 
    "2": component.get("fe5685")
};

local function toggleActive(number, signal)
    proxy = component.proxy(redstone_io_addr);
    redstone_io_1.setOutput(sides.west, signal);
    redstone_io_1.setOutput(sides.east, signal);
    redstone_io_1.setOutput(sides.top, signal);
end

local args = {...};

local WAIT_TIME = 3 * 60;

local isRunning = true;

toggleActive("1", 2);
toggleActive("2", 2);

for i, v in ipairs(args) do
    toggleActive(v, 0);
end

function handleEvent(name, address, char, code, playerName)
    if code == keyboard.keys.q then
        isRunning = false;
    end
end

while isRunning do
    handleEvent(event.pull(WAIT_TIME, "key_up"));
end

for i, v in ipairs(args) do
    toggleActive(v, 2);
end
