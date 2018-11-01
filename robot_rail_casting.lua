--[[
    robot use between a casting basin and track roller. this to machine must be put close to each other.
    upgrade require: inventory upgrade, inventory_controller upgrade, tractor beam upgrade
]]

local robot = require("robot");
local inv_ctrl = require("component").inventory_controller;
local sides = require("sides");
local event = require("event");
local keyboard = require("keyboard");
local tractor = require("component").tractor_beam;
local computer = require("computer");
local os = require("os");

local isRunning = true;
-- shall wait for 11 seconds because the casting basin need that long time to cast a railcasting
local WAIT_TIME = 10;

local function getRestStack()
    local totalSize = inv_ctrl.getInventorySize(sides.front);
    assert(type(totalSize) == "number", "not an inventory ahead");
    local restStack = 0;
    for i = 1, totalSize do
        local slotInfo = inv_ctrl.getStackInSlot(sides.front, i);
        if not slotInfo then
            restStack = restStack + 64;
        else
            restStack = restStack + slotInfo.maxSize - slotInfo.size;
        end
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
        -- since the rail casting will drop into ground. we need to pick it up.
        tractor.suck();
        moveFromCastingBasinToTrackRoller();
        inv_ctrl.equip();
        robot.use(sides.front);
        moveFromTrackRollerToCrate();
    end
end

local function charge()
    robot.turnLeft();
    for i = 1, 10 do
        robot.forward();
    end
    robot.turnLeft();
    robot.forward();
    robot.turnRight();
    robot.forward();
    robot.turnLeft();
    robot.use(sides.front);
    robot.turnLeft();
    robot.forward();
    robot.turnRight();
    robot.forward();
    os.sleep(30);
end

local function checkEnergy()
    local energyLevel = computer.energy() / computer.maxEnergy();
    if energyLevel < 0.1 then
        charge()
        -- get back
        robot.turnAround();
        robot.forward();
        robot.forward();
        robot.turnRight();
        for i = 1, 10 do
            robot.forward();
        end
        robot.turnLeft();
    end
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
    doJob();
    checkEnergy();
    -- handleEvent(event.pull(WAIT_TIME));
    handleEvent(event.pull(WAIT_TIME, "key_up"));
end