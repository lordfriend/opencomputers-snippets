local component = require("component");
local event = require("event");
local keyboard = require("keyboard");
local sides = require("sides");
-- 0d411ba is redstone_card
local redstone_io_1 = component.get("63b63a3d-3924-434b-8a06-82cea5a67097");
local redstone_io_2 = component.get("fe568506-7199-4b97-97df-78d6848fc0f9");

local args = {...};

local WAIT_TIME = 3 * 60;

local isRunning = true;

for i, v in pairs(args) do
    if v == 1 then
        redstone_io_1.setOutput(sides.west, 1);
        redstone_io_1.setOutput(sides.east, 1);
        redstone_io_1.setOutput(sides.top, 1);
    else if v == 2 then
        redstone_io_2.setOutput(sides.west, 1);
        redstone_io_2.setOutput(sides.east, 1);
        redstone_io_2.setOutput(sides.top, 1);
    end
end

function handleEvent(name, address, char, code, playerName)
    if code == keyboard.keys.q then
        isRunning = false;
    end
end

while isRunning do
    handleEvent(event.pull(WAIT_TIME, "key_up"));
end

for i, v in pairs(args) do
    if v == 1 then
        redstone_io_1.setOutput(sides.west, 0);
        redstone_io_1.setOutput(sides.east, 0);
        redstone_io_1.setOutput(sides.top, 0);
    else if v == 2 then
        redstone_io_2.setOutput(sides.west, 0);
        redstone_io_2.setOutput(sides.east, 0);
        redstone_io_2.setOutput(sides.top, 0);
    end
end
