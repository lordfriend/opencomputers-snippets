local component = require("component");
local sides = require("sides");
local event = require("event");
local keyboard = require("keyboard");
local robot = component.robot;
local rs = component.redstone;

local MIN_LEVEL = 2;
local MAX_LEVEL = 15

local isRunning = true;

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
    moveClockwise();
    robot.use(sides.bottom);
    -- always drain bucket before get fluid front tank
    for i = 1, 500 do
        if not isRunning then
            break;
        end
        robot.use(sides.front);
        robot.use(sides.bottom);
    end
end

local function detectRedstoneSignal()
    local signal = rs.getOutput(sides.front);
    if signal > MAX_LEVEL then
        startDrainTank();
        moveCounterClockwise();
    end
end

while isRunning do
    detectRedstoneSignal();
    local _, _, charCode, code, _ = even.pull("key_up", 1);
    if code == keyboard.keys.q then
        isRunning = false;
    end
end