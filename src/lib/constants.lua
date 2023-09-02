-- Header for InControl system exclusive messages
local sysexHeader = "F0 00 20 29 02 0A 01"
local debugSysexHeader = "F0 00 20 29 02 0A 02"

-- System exclusive message to reset knob layout
local sysexKnobLayout = sysexHeader .. "01 01 F7"
local buttonColourNumber = 9
local layerA = "layerA"
local layerB = "layerB"

return {
    sysexHeader = sysexHeader,
    debugSysexHeader = debugSysexHeader,
    sysexKnobLayout = sysexKnobLayout,
    buttonColourNumber = buttonColourNumber,
    layerA = layerA,
    layerB = layerB
}
