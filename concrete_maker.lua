local robot = require("robot");
local sides = require("sides");
local event = require("event");
local keyboard = require("keyboard");
local tractor = require("component").tractor_beam;
local computer = require("computer");
local os = require("os");

local isRunning = true;

local totalSlot = robot.inventorySize();

local slots = {};

for i = 1, totalSlot do
    slots[i] = robot.count(i);
    if slots[i] == 0 then
        break;
    end
end

local handleEvent(name, addr, char, code, ...)
    if code == keyboard.keys.q then
        isRunning = false;
    end
end

local function produce()
    for i, count in ipairs(slots) do
        robot.select(i);
        for j = 1, count do
            robot.placeDown();
            handleEvent(event.pull(1, "key_up"));
            robot.swingDown();
            if not isRunning then
                return
            end
        end
    end
end