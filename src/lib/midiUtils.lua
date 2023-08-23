local constants = require("constants")
local stringUtils = require("stringUtils")
local hexUtils = require("hexUtils")

-- makes a midi message object that displays a specified message in the lower half of the LC displays below the knobs
-- on the SL MkIII; you can specify row number 1 or 2; 1 is default
local function makeDebugMsgEvent(msg, row)
    local row_hex = row == 1 and "02" or "03"
    local chunks = stringUtils.splitToChunks(msg, 8, 8)
    local event = constants.sysexHeader .. " 02 "
    for i, chunk in ipairs(chunks) do
        event = event .. hexUtils.decToTex(i - 1) .. " 01 " .. row_hex .. " " .. hexUtils.textToHex(chunk) .. " 00 "
    end
    return remote.make_midi(event .. "F7")
end

-- makes a midi message object that display a notification in the fifth LC display, between the knobs and the faders
local function makeNotification(line_1, line_2)
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

return {
    makeDebugMsgEvent = makeDebugMsgEvent,
    makeNotification = makeNotification
}
