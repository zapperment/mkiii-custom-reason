-- Header for InControl system exclusive messages
local sysexHeader = "F0 00 20 29 02 0A 01"

-- System exclusive message to reset know layout
local sysexKnobLayout = sysexHeader .. "01 01 F7"

return {
    sysexHeader = sysexHeader,
    sysexKnobLayout = sysexKnobLayout
}
