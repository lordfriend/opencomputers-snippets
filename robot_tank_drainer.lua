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
    local co = coroutine.create(function ()
        isExecutingTask = true;
        -- always drain bucket before get fluid front tank
        for i = 1, 512 do
            if not isRunning or current_level <= MIN_LEVEL then
                break;
            end
            robot.use(sides.front);
            robot.useDown();
        end
        isExecutingTask = false;
    end)
    coroutine.resume(co);
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
    handleEvent(event.pull());
end