local component = require("component");
local sides = require("sides");
local event = require("event");
local keyboard = require("keyboard");
local robot = component.robot;
local rs = component.redstone;

local MIN_LEVEL = 2;
local MAX_LEVEL = 15

local isRunning = true;
local current_level = 0;
local isExecutingTask = false;

-- counter clockwise movement
local function moveCounterClockwise()
    robot.turn(sides.right);
    robot.move(sides.front);
    robot.move(sides.front);
    robot.turn(sides.left);
    robot.move(sides.front);
    robot.move(sides.front);
    robot.turn(sides.left);
end

local function moveClockwise()
    robot.turn(sides.left);
    robot.move(sides.front);
    robot.move(sides.front);
    robot.turn(sides.right);
    robot.move(sides.front);
    robot.move(sides.front);
    robot.move(sides.right);
end

local function startDrainTank()
    if isExecutingTask then
        return;
    end
    local co = coroutine.create(function ()
        isExecutingTask = true;
        moveClockwise();
        robot.use(sides.bottom);
        -- always drain bucket before get fluid front tank
        for i = 1, 512 do
            if not isRunning or current_level <= MIN_LEVEL then
                break;
            end
            robot.use(sides.front);
            robot.use(sides.bottom);
        end
        moveCounterClockwise();
        isExecutingTask = false;
    end)
    co.resume();
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
    if newValue >= MAX_LEVEL then
        startDrainTank();
    end
end

local function handleEvent(event_name, ...)
    if event_name then
        eventHandlers[event_name](...);
    end
end

local signalStrength = rs.getInput(sides.front);
current_level = signalStrength;
if current_level > MAX_LEVEL then
    startDrainTank();
end

while isRunning do
    handleEvent(event.pull());
end