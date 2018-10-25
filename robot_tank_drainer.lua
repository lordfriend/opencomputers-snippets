--[[
    A robot which can dump liquids from a Tank of Immersive Engineering.

    To make it work. a robot must have a Tank Upgrade, Internet Card (download and update code), Redstone Card.
    Deploy position should be:
    X X X
    X X P
    X X X
      R C
    This is the first layer of the tank, X is the tank where P is a Redstone Probe Connector, R is the robot which facing the tank, C is a redstone connector set
    to output mode, R and P should be connected by wire.
]]

local component = require("component");
local sides = require("sides");
local event = require("event");
local keyboard = require("keyboard");
local robot = require("robot");
local rs = component.redstone;

local MIN_LEVEL = 2;
local MAX_LEVEL = 15;

isRunning = true;
current_level = 0;
isExecutingTask = false;

-- counter clockwise movement
-- local function moveCounterClockwise()
--     robot.turnRight();
--     robot.forward();
--     robot.forward();
--     robot.turnLeft();
--     robot.forward();
--     robot.forward();
--     robot.turnLeft();
-- end

-- local function moveClockwise()
--     robot.turnLeft();
--     robot.forward();
--     robot.forward();
--     robot.turnRight();
--     robot.forward();
--     robot.forward();
--     robot.turnRight();
-- end

local function startDrainTank()
    if isExecutingTask then
        return;
    end
    co = coroutine.create(function ()
        -- always drain bucket before get fluid front tank
        for i = 1, 512 do
            coroutine.yield(true);
            if not isRunning or current_level <= MIN_LEVEL then
                break;
            end
            robot.use(sides.front);
            robot.useDown();
        end
        return false;
    end)
    isExecutingTask = coroutine.resume(co);
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

function eventHandlers.redstone_changed(address, side, oldValue, newValue, color)
    current_level = newValue;
    print("current level: ", current_level);
    if newValue >= MAX_LEVEL then
        startDrainTank();
    end
end

local function handleEvent(event_name, ...)
    if event_name then
        eventHandlers[event_name](...);
    end
end

local signalStrength = rs.getInput(sides.right);
current_level = signalStrength;
print("initial level: ", current_level);
if current_level > MAX_LEVEL then
    startDrainTank();
end

while isRunning do
    handleEvent(event.pull(1));
    if isExecutingTask then
        coroutine.resume(co);
    end
end