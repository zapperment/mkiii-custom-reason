local items = require("lib.items")

return function(event)
    if event.port == 2 then
        -- port 2 is piano keyboard, we let the auto inputs handle this
        return false
    end
    local ret = remote.match_midi(items.keyboard.midiMatcher, event)
    if ret == nil then
        -- it's not a key-on or key-off event triggered by a pad
        return false
    end

    -- ret.x: 1 (note on) | 0 (note off)
    -- ret.y: 112-119/96-103 (note number)
    -- ret.z: 0-127 (velocity)

    -- we change the note number so that the SL MkIII pads trigger corresponding
    -- pads on Reason's Kong drum machine
    local targetNote = ret.y <= 103 and ret.y - 52 or ret.y - 76
    remote.handle_input({
        item = items.keyboard.index,
        value = ret.x,
        note = targetNote,
        velocity = ret.z,
        time_stamp = event.time_stamp
    })
    return true
end
