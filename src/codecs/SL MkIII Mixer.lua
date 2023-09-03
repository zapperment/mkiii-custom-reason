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
local faderStates = require("lib.faderStates")

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
    return processMidi.faders(event)
end

function remote_set_state(changedItems)
    setState.faders(changedItems)
end

function remote_deliver_midi(_, port)
    if (port == 2) then
        return debugUtils.dumpLog(events)
    end

    local events = {}
    for i = 1, 8 do
        local fader = "fader" .. i
        if stateUtils.hasChanged(fader) then
            local state = stateUtils.update(fader)
            local controller = items[fader].controller
            local colour
            if state == faderStates.unknown then
                colour = colours.black.dec
            elseif state == faderStates.tooLow then
                colour = colours.midRed.dec
            elseif state == faderStates.tooHigh then
                colour = colours.midYellow.dec
            elseif state == faderStates.inSync then
                colour = colours.green.dec
            end
            table.insert(events, midiUtils.makeControlChangeEvent(controller, colour))
        end
    end

    return events
end
