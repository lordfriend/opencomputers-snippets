local robot = require("robot");
local inv_ctrl = require("component").inventory_controller;
local sides = require("sides");

-- shall wait for 11 seconds because the casting basin need that long time to cast a railcasting
local WAIT_TIME = 10;

local function getRestStack()
    local totalSize = inv_ctrl.getInventorySize();
    assert(totalSize, "not an inventory ahead");
    local restStack = 0;
    for i = 1, totalSize do
        local slotInfo = inv_ctrl.getStackInSlot(sides.front, i);
        if not slotInfo then
            restStack = restStack + 64;
        else
            restStack = restStack + slotInfo.maxSize - slotInfo.size;
    end
    return restStack;
end

local function moveFromCrateToCastingBasin()
    robot.turnRight();
    robot.forward();
    robot.forward();
    robot.turnRight();
    for i = 1, 5 do
        robot.forward();
    end
end

local function moveFromCastingBasinToTrackRoller()
    robot.turnAround();
    for i = 1, 5 do
        robot.forward();
    end
end

local function moveFromTrackRollerToCrate()
    robot.turnLeft();
    robot.forward();
    robot.forward();
    robot.turnRight();
end

local function doJob()
    -- check chest
    local restStack = getRestStack();
    if restStack > 10 then
        moveFromCrateToCastingBasin();
        robot.useUp(sides.front);
        moveFromCastingBasinToTrackRoller();
        robot.use(sides.front);
        moveFromTrackRollerToCrate();
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

while isRunning do
    handleEvent(event.pull(WAIT_TIME));
end