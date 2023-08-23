local constants = require("constants")
local stringUtils = require("stringUtils")
local hexUtils = require("hexUtils")

-- Makes a MIDI event object that displays a specified message in the lower half of the LC displays below the knobs
-- on the SL MkIII. You can specify row number 1 or 2; 1 is default.
local function makeDebugMsgEvent(msg, row)
    local row_hex = row == 1 and "02" or "03"
    local chunks = stringUtils.splitToChunks(msg, 8, 8)
    local event = constants.sysexHeader .. " 02 "
    for i, chunk in ipairs(chunks) do
        event = event .. hexUtils.decToTex(i - 1) .. " 01 " .. row_hex .. " " .. hexUtils.textToHex(chunk) .. " 00 "
    end
    return remote.make_midi(event .. "F7")
end

-- Makes a MIDI event object that displays a notification in the fifth LC display, between the knobs and the faders.
local function makeNotificationEvent(line_1, line_2)
    l_1 = " "
    l_2 = " "
    begin = constants.sysexHeader .. " 04 "

    for i = 1, math.min(string.len(line_1), 18) do
        l_1 = l_1 .. string.format("%X", tostring(string.byte(line_1, i))) .. " "
    end

    for i = 1, string.len(line_2) do
        l_2 = l_2 .. string.format("%X", tostring(string.byte(line_2, i))) .. " "
    end

    msg = begin .. l_1 .. " 00 " .. l_2 .. " 00 " .. " F7"

    return remote.make_midi(msg)
end


-- Makes a MIDI event that sets the colour of the rotary graphics in the LC displays below the knob or hides the knobs.
-- If no arguments are provided, resets the knob LC displays.
--
-- statuses: list of boolean values
-- colour: string with hex value of a colour
local function makeKnobsStatusEvent(statuses, colour)
    if statuses ~= nil then
        local event = constants.sysexHeader .. " 02 "
        for i, knobIsActive in ipairs(statuses) do
            if knobIsActive then
                event = event .. hexUtils.decToHex(i - 1) .. " 02 01 " .. colour .. " " -- make knob visible
            else
                event = event .. hexUtils.decToHex(i - 1) .. " 02 01 " -- make knob invisible
            end
        end
        event = event .. "F7"
        return remote.make_midi(event)
    else
        return remote.make_midi(constants.sysexKnobLayout)
    end
end

-- Makes a MIDI event that creates a knob with the specified colour
--
-- knobNumber: the number of the knob to create (1-8)
-- colour: string with hex value of a colour
local function makeCreateKnobEvent(knobNumber, colour)
    return remote.make_midi(constants.sysexHeader .. " 02 " .. hexUtils.decToHex(knobNumber - 1) .. " 02 01 " .. colour .. " F7")
end

return {
    makeDebugMsgEvent = makeDebugMsgEvent,
    makeNotificationEvent = makeNotificationEvent,
    makeKnobsStatusEvent = makeKnobsStatusEvent,
    makeCreateKnobEvent = makeCreateKnobEvent
}
