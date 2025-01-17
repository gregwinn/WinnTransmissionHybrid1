--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

-- FOR HYBRID ENGINES ONLY

require("Helpers.counter")
require("Helpers.base")
-- Output
-- 1: Gearbox 1: Boalean
-- 2: Gearbox 2: Boalean
-- 3: Data Out: Composite
-- 4: Drive Clutch: Number
-- 5: Drive Mode: Number (1: Drive, 0: Neutral, -1: Reverse)
-- 6: Gearbox 3: Boalean
-- 7: Gearbox 4: Boalean
-- 8: Gearbox Reverse: Boalean
-- 9: Gearbox 5: Boalean

-- Inputs
-- Composites from ENG MCU
---- 27: Engine RPS: Number
---- 28: Idle RPS: Number
---- 29: Throttle: Number

-- Properties INPUT
-- 20: Number of gears (1-10)
-- 21: Reverse Gearbox (1 or 2)
-- 22: Set Gear up (bolean)
-- 23: Set Gear down (boloan)

ticks = 0
local currentGear = 0
local currentClutchOutput = 0
driveModeCounter = newUpDownCounter(0, -1, 3, 1)
clutchCounter = newUpDownCounter(0, 0, 1, 0.008)
function onTick()
    ticks = ticks + 1
    -- Inputs
    engRPS = input.getNumber(27)
    idleRPS = input.getNumber(28)
    throttle = input.getNumber(29)
    nGears = input.getNumber(20) or 8
    gearUp = input.getBool(22)
    gearDown = input.getBool(23)

    gearCounter = newUpDownCounter(currentGear, -1, nGears, 1)

    -- Gearing
    if gearUp then
        -- gear up
        gearCounter.increment(gearCounter)
    elseif gearDown then
        -- gear down
        gearCounter.decrement(gearCounter)
    end
    currentGear = gearCounter.getValue(gearCounter)

    if currentGear > 0 then
        -- Drive
        -- RPS >  idle + 4 # and throttle > 0
        if throttle > 0 then
            clutchCounter.increment(clutchCounter)
        --elseif engRPS < idleRPS + 1 then
            --clutchCounter.decrement(clutchCounter)
        elseif throttle == 0 then
            currentClutchOutput = 0
        end
        
        currentClutchOutput = clutchCounter.getValue(clutchCounter)

        if currentGear == 1 then
            -- All Gearboxes off
            output.setBool(1, false) -- Gearbox 1 <<
            output.setBool(2, false) -- Gearbox 2 <<
            output.setBool(6, false) -- Gearbox 3 >>
            output.setBool(7, false) -- Gearbox 4 >>
            output.setBool(9, false) -- Gearbox 5 >>
            output.setBool(3, false) -- Data Out (set true for reverse)
            output.setBool(8, false) -- Gearbox Reverse
        elseif currentGear == 2 then
            output.setBool(1, true) -- Gearbox 1
            output.setBool(2, false) -- Gearbox 2
            output.setBool(6, true) -- Gearbox 3
            output.setBool(7, false) -- Gearbox 4
            output.setBool(9, true) -- Gearbox 5
            output.setBool(3, false) -- Data Out (set true for reverse)
            output.setBool(8, false) -- Gearbox Reverse
        elseif currentGear == 3 then
            output.setBool(1, true) -- Gearbox 1
            output.setBool(2, false) -- Gearbox 2
            output.setBool(6, true) -- Gearbox 3
            output.setBool(7, false) -- Gearbox 4
            output.setBool(9, false) -- Gearbox 5
            output.setBool(3, false) -- Data Out (set true for reverse)
            output.setBool(8, false) -- Gearbox Reverse
        elseif currentGear == 4 then
            output.setBool(1, true) -- Gearbox 1
            output.setBool(2, false) -- Gearbox 2
            output.setBool(6, false) -- Gearbox 3
            output.setBool(7, true) -- Gearbox 4
            output.setBool(9, true) -- Gearbox 5
            output.setBool(3, false) -- Data Out (set true for reverse)
            output.setBool(8, false) -- Gearbox Reverse
        elseif currentGear == 5 then
            output.setBool(1, true) -- Gearbox 1
            output.setBool(2, true) -- Gearbox 2
            output.setBool(6, false) -- Gearbox 3
            output.setBool(7, false) -- Gearbox 4
            output.setBool(9, false) -- Gearbox 5
            output.setBool(3, false) -- Data Out (set true for reverse)
            output.setBool(8, false) -- Gearbox Reverse
        elseif currentGear == 6 then
            output.setBool(1, true) -- Gearbox 1
            output.setBool(2, true) -- Gearbox 2
            output.setBool(6, true) -- Gearbox 3
            output.setBool(7, false) -- Gearbox 4
            output.setBool(9, true) -- Gearbox 5
            output.setBool(3, false) -- Data Out (set true for reverse)
            output.setBool(8, false) -- Gearbox Reverse
        elseif currentGear == 7 then
            output.setBool(1, true) -- Gearbox 1
            output.setBool(2, false) -- Gearbox 2
            output.setBool(6, true) -- Gearbox 3
            output.setBool(7, true) -- Gearbox 4
            output.setBool(9, false) -- Gearbox 5
            output.setBool(3, false) -- Data Out (set true for reverse)
            output.setBool(8, false) -- Gearbox Reverse
        elseif currentGear == 8 then
            output.setBool(1, true) -- Gearbox 1
            output.setBool(2, true) -- Gearbox 2
            output.setBool(6, false) -- Gearbox 3
            output.setBool(7, true) -- Gearbox 4
            output.setBool(9, true) -- Gearbox 5
            output.setBool(3, false) -- Data Out (set true for reverse)
            output.setBool(8, false) -- Gearbox Reverse
        end

        output.setBool(3, false)
    elseif currentGear == -1 then
        -- Reverse
        if throttle > 0 then
            clutchCounter.increment(clutchCounter)
        --elseif engRPS < idleRPS + 1 then
            --clutchCounter.decrement(clutchCounter)
        elseif throttle == 0 then
            currentClutchOutput = 0
        end
        
        currentClutchOutput = clutchCounter.getValue(clutchCounter)

        output.setBool(1, false) -- Gearbox 1
        output.setBool(2, false) -- Gearbox 2
        output.setBool(6, false) -- Gearbox 3
        output.setBool(7, false) -- Gearbox 4
        output.setBool(9, false) -- Gearbox 5
        output.setBool(3, true) -- Data Out (set true for reverse)
        output.setBool(8, true) -- Gearbox Reverse
    else
        -- Neutral
        clutchCounter.setValue(clutchCounter, 0)
        currentClutchOutput = 0
        output.setBool(1, false) -- Gearbox 1
        output.setBool(2, false) -- Gearbox 2
        output.setBool(6, false) -- Gearbox 3
        output.setBool(7, false) -- Gearbox 4
        output.setBool(9, false) -- Gearbox 5
        output.setBool(3, false) -- Data Out (set true for reverse)
        output.setBool(8, false) -- Gearbox Reverse
    end

    currentClutchOutput = clamp(currentClutchOutput, 0, 1)

    output.setNumber(4, currentClutchOutput)
    output.setNumber(5, currentGear)
end

function onDraw()
end