local constants = require("lib.constants")
local stringUtils = require("lib.stringUtils")
local hexUtils = require("lib.hexUtils")

-- Makes a MIDI event object that displays a specified message in the lower half of the LC displays below the knobs
-- on the SL MkIII. You can specify row number 1 or 2; 1 is default.
local function makeDebugMsgEvent(msg, row)
    local rowHex = row == 2 and "03" or "02"
    local chunks = stringUtils.splitToChunks(msg, 8, 8)
    local event = constants.sysexHeader .. " 02 "
    for i, chunk in ipairs(chunks) do
        event = event .. hexUtils.decToHex(i - 1) .. " 01 " .. rowHex .. " " .. hexUtils.textToHex(chunk) .. " 00 "
    end
    return remote.make_midi(event .. "F7")
end

-- Makes a MIDI event object that displays a notification in the fifth LC display, between the knobs and the faders.
local function makeNotificationEvent(line1, line2)
    line1hex = " "
    line2hex = " "
    begin = constants.sysexHeader .. " 04 "

    for i = 1, math.min(string.len(line1), 18) do
        line1hex = line1hex .. string.format("%X", tostring(string.byte(line1, i))) .. " "
    end

    for i = 1, string.len(line2) do
        line2hex = line2hex .. string.format("%X", tostring(string.byte(line2, i))) .. " "
    end

    msg = begin .. line1hex .. " 00 " .. line2hex .. " 00 " .. " F7"

    return remote.make_midi(msg)
end

-- Makes a MIDI event that sets the colour of the rotary graphics in the LC displays below the knob or hides the knobs.
-- If no arguments are provided, resets the knob LC displays.
--
-- statuses: list of 8 boolean values, each determining if the corresponding knob is active
-- colour: string with hex value of a colour
local function makeKnobsStatusEvent(statuses, colour)
    if statuses ~= nil then
        local event = constants.sysexHeader .. " 02 "
        for i, knobIsActive in ipairs(statuses) do
            if knobIsActive then
                event = event .. hexUtils.decToHex(i - 1) .. " 02 01 " .. colour .. " " -- make knob visible
            else
                event = event .. hexUtils.decToHex(i - 1) .. " 02 01 00 " -- make knob invisible
            end
        end
        event = event .. "F7"
        return remote.make_midi(event)
    else
        return remote.make_midi(constants.sysexKnobLayout)
    end
end

-- Makes a MIDI event that sets the text displayed in the 4 LC displays between the rotary knob and the buttons above
-- the drum pads.
--
-- statuses: list of 8 boolean values, each determining if the corresponding remote surface element is active
-- texts: list of 8 strings, each representing the text to be displayed below the corresponding knob or above the
--        corresponding button
-- row: row number 1-4; defaults to 1
--      row 1: rotary knob label
--      row 2: rotary knob value
--      row 3: (currently not used)
--      row 4: button label
local function makeDisplayEvent(statuses, texts, row)
    local rowHex = row ~= nil and hexUtils.decToHex(row - 1) or "00"
    local event = constants.sysexHeader .. " 02 "
    for i, knobIsActive in ipairs(statuses) do
        if knobIsActive then
            event = event .. hexUtils.decToHex(i - 1) .. " 01 " .. rowHex .. " " .. hexUtils.textToHex(texts[i]) ..
                        " 00 "
        else
            event = event .. hexUtils.decToHex(i - 1) .. " 01 " .. rowHex .. " 00 "
        end
    end
    event = event .. "F7"
    return remote.make_midi(event)
end

-- Makes a MIDI event that creates a knob with the specified colour
--
-- knobNumber: the number of the knob to create (1-8)
-- colour: string with hex value of a colour
local function makeCreateKnobEvent(knobNumber, colour)
    return remote.make_midi(
        constants.sysexHeader .. " 02 " .. hexUtils.decToHex(knobNumber - 1) .. " 02 01 " .. colour .. " F7")
end

local function makeControlChangeEvent(controllerNumber, value)
    return remote.make_midi("BF " .. hexUtils.decToHex(controllerNumber) .. " " .. hexUtils.decToHex(value))
end

return {
    makeDebugMsgEvent = makeDebugMsgEvent,
    makeNotificationEvent = makeNotificationEvent,
    makeKnobsStatusEvent = makeKnobsStatusEvent,
    makeCreateKnobEvent = makeCreateKnobEvent,
    makeDisplayEvent = makeDisplayEvent,
    makeControlChangeEvent = makeControlChangeEvent
}
