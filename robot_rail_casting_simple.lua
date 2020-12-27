--[[
    robot use between a casting basin and track roller. this simple version do not check the chest do not move.
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

local function doJob()
    robot.useUp(sides.front);
    -- since the rail casting will drop into ground. we need to pick it up.
    tractor.suck();
    inv_ctrl.equip();
    robot.use(sides.back);
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
    -- handleEvent(event.pull(WAIT_TIME));
    handleEvent(event.pull(WAIT_TIME, "key_up"));
end