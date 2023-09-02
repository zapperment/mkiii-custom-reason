local processMidi = require("processMidi._")
local setState = require("setState._")

local autoInputs = require("lib.mixerAutoInputs")
local autoOutputs = require("lib.mixerAutoOutputs")
local colours = require("lib.colours")
local constants = require("lib.constants")
local debugUtils = require("lib.debugUtils")
local hexUtils = require("lib.hexUtils")
local items = require("lib.mixerItems")
local midiUtils = require("lib.midiUtils")
local stateUtils = require("lib.stateUtils")

-- this needs to be global, it's used by auto outputs
buttonColourMute = colours.red.dec
buttonColourSolo = colours.green.dec

function remote_init()
    local itemsToDefine = {}

    for name, item in pairs(items) do
        table.insert(itemsToDefine, {
            name = name,
            input = item.input,
            output = item.output,
            min = item.min,
            max = item.max
        })
        item.index = #itemsToDefine
    end

    remote.define_items(itemsToDefine)
    remote.define_auto_inputs(autoInputs)
    remote.define_auto_outputs(autoOutputs)
    debugUtils.log("Novation SL MkIII Mixer remote control surface initialised successfully")
end

function remote_process_midi(event)
    return processMidi.colourButtons(event)
end

function remote_set_state()
end

function remote_deliver_midi(_, port)
    if (port == 2) then
        return debugUtils.dumpLog(events)
    end
    
    local events = {}

    if stateUtils.hasChanged("buttonColour") then
        local buttonColour = stateUtils.update("buttonColour")
        for i = 0, 7 do
            local controllerNumber = 41 + i
            table.insert(events, midiUtils.makeControlChangeEvent(controllerNumber, buttonColour))
        end
    end

    return events
end
