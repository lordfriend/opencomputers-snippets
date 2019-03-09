local robot = require("robot");
local inv_ctrl = require("component").inventory_controller;
local sides = require("sides");
local event = require("event");
local keyboard = require("keyboard");
local tractor = require("component").tractor_beam;
-- local computer = require("computer");
-- local os = require("os");

local isRunning = true;
-- sleep time (seconds)
local WAIT_TIME = 60

local totalRows = 6;
local totalCols = 6;

local function moveForward()
    local isFail = true;
    while isFail do
        isFail = robot.forward()
    end
end

local function doJob()
    for r = 1, totalRows do
        for c = 1, totalCols do
            local hasBlock = robot.detect();
            if hasBlock then
                robot.swing();
                tractor.suck();
            end
            moveForward();
            moveForward();
            -- place on cactus block at the original position
            robot.place(sides.back);
        end
        if r % 2 == 0 then
            robot.turnLeft();
            moveForward();
            moveForward();
            robot.Left();
        else
            robot.turnRight();
            moveForward();
            moveForward();
            robot.turnRight();
        end
    end
    -- put all item into chest.
    -- TODO
    -- move back to start position
    if totalRows % 2 == 0 then
        -- robot is at the same row column with the start position.
        robot.turnLeft();
        for i = 1, totalRows do
            moveForward();
            moveForward();
        end
    else
        for i = 1, totalCols do
            moveForward();
            moveForward();
        end
        robot.turnLeft();
        for i = 1, totalRows - 1 do
            moveForward();
            moveForward();
        end
    end
    robot.turnRight();
end

local function unknownEvent()
    -- dummy event handler that does nothing.
end
-- table that holds all event handlers
-- in case no match can be found returns the dummy function unknownEvent
local eventHandlers = setmetatable({}, { __index = function() return unknownEvent end});

function eventHandlers.key_up(address, char, code, playerName)
    if code == keyboard.keys.q then
        isRunning = false;
    end
end

local function handleEvent(event_name, ...)
    if event_name then
        eventHandlers[event_name](...);
    end
end

-- select the first slot
robot.select(1)

while isRunning do
    doJob();
    -- checkEnergy();
    -- handleEvent(event.pull(WAIT_TIME));
    handleEvent(event.pull(WAIT_TIME, "key_up"));
end