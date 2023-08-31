local processMidi = require("processMidi._")
local setState = require("setState._")

local autoInputs = require("lib.mixerAutoInputs")
local colours = require("lib.colours")
local constants = require("lib.constants")
local hexUtils = require("lib.hexUtils")
local items = require("lib.mixerItems")
local midiUtils = require("lib.midiUtils")
local stateUtils = require("lib.stateUtils")

-- For the mixer, remote_probe does nothing - we have to set it up manually
function remote_probe(_, _, prober)
    return {}
end

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
end

function remote_process_midi()
    return false
end

function remote_set_state()
end

function remote_deliver_midi()
    return {}
end

function remote_prepare_for_use()
    return {}
end

function remote_release_from_use()
    return {}
end
