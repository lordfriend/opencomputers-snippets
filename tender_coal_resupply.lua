local component = require("component");
local sides = require("sides");
local keyboard = require("keyboard");
local event = require("event");

local ir_detector = component.ir_augment_detector;

local redstone_card_addr = component.get("0d411bba"); 
local rs = component.proxy(redstone_card_addr);

local isRunning = true;

local function detect()
    local overhead = ir_detector.info();
    local cargo_percent = overhead.cargo_percent;
    local name = overhead.name;
    if not string.find(name, "%stender$") then
        print("Overhead is not a tender");
        return false;
    end
    if cargo_percent > 80 then
        print("Overhead is nearly full");
        return false;
    end
    return true;
end

function handleEvent(name, address, char, code, playerName)
    if code == keyboard.keys.q then
        isRunning = false;
    end
end

if detect() then
    rs.setOutput(sides.west, 1);
    print("Start resupply coals to ", ir_detector.info().name);
    while isRunning do
        isRunning = detect();
        handleEvent(event.pull(10, "key_up"));
    end
    rs.setOutput(sides.west, 0);
    print("Resupply finished, please wait until the conveyor is empty");
end


